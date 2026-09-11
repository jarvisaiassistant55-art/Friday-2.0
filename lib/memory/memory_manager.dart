import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import '../core/models/memory_item.dart';
import '../core/services/storage_service.dart';

/// Local-first long-term memory for Friday/Jarvis.
/// Memories survive app restarts and are ranked by lexical relevance,
/// importance and recency. No cloud database is required.
class MemoryManager {
  final StorageService storage;
  final List<MemoryItem> items = [];
  static const _key = 'friday_memory_v3';
  static const _uuid = Uuid();

  MemoryManager([StorageService? s]) : storage = s ?? StorageService();

  Future<void> load() async {
    items
      ..clear()
      ..addAll((await storage.readJsonList(_key)).map(MemoryItem.fromJson).where((m) => m.text.trim().isNotEmpty));
  }

  Future<MemoryItem> remember(
    String text, {
    String category = 'general',
    double importance = 0.6,
  }) async {
    final clean = _clean(text);
    final existing = items.where((m) => _similar(m.text, clean)).fold<MemoryItem?>(null, (best, m) {
      if (best == null || m.importance > best.importance) return m;
      return best;
    });
    if (existing != null) {
      final updated = existing.copyWith(category: category, importance: math.max(existing.importance, importance));
      items[items.indexWhere((m) => m.id == existing.id)] = updated;
      await _save();
      return updated;
    }
    final item = MemoryItem(id: _uuid.v4(), text: clean, category: category, importance: importance);
    items.add(item);
    await _save();
    return item;
  }

  /// Detects explicit long-term memory requests and useful stable preferences.
  /// Returns the memories created from this message.
  Future<List<MemoryItem>> learnFromUserMessage(String message) async {
    final text = message.trim();
    if (text.isEmpty) return [];
    final found = <MemoryItem>[];

    final explicit = RegExp(r'^(?:please\s+)?remember(?:\s+that)?\s+(.+)$', caseSensitive: false).firstMatch(text);
    if (explicit != null) {
      found.add(await remember(explicit.group(1)!, category: 'explicit', importance: 0.95));
      return found;
    }

    final rules = <RegExp, String>{
      RegExp(r'\bmy name is\s+(.+)', caseSensitive: false): 'identity',
      RegExp(r'\bcall me\s+(.+)', caseSensitive: false): 'identity',
      RegExp(r'\bi (?:like|love)\s+(.+)', caseSensitive: false): 'preference',
      RegExp(r'\bi (?:prefer|usually prefer)\s+(.+)', caseSensitive: false): 'preference',
      RegExp(r'\bmy favorite\s+(.+)', caseSensitive: false): 'preference',
      RegExp(r'\bi live in\s+(.+)', caseSensitive: false): 'location',
      RegExp(r'\bi work (?:at|for)\s+(.+)', caseSensitive: false): 'work',
    };
    for (final entry in rules.entries) {
      final match = entry.key.firstMatch(text);
      if (match != null) {
        final value = _trimSentence(match.group(1)!);
        if (value.isNotEmpty && value.length < 180) {
          found.add(await remember(_normalizeRule(entry.key.pattern, value), category: entry.value, importance: entry.value == 'identity' ? 0.95 : 0.8));
        }
      }
    }
    return found;
  }

  List<MemoryItem> search(String query, {int limit = 8}) {
    final q = _tokens(query);
    if (q.isEmpty) return _rankAll(limit);
    final now = DateTime.now();
    final scored = items.map((m) {
      final mt = _tokens('${m.text} ${m.category}');
      final overlap = q.where(mt.contains).length / q.length;
      final exact = m.text.toLowerCase().contains(query.toLowerCase().trim()) ? 0.35 : 0.0;
      final ageDays = now.difference(m.updatedAt).inHours / 24.0;
      final recency = 1 / (1 + ageDays / 30);
      final score = overlap * 0.55 + exact + m.importance * 0.25 + recency * 0.2;
      return (m, score);
    }).where((x) => x.$2 > 0.05).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return scored.take(limit).map((x) => x.$1).toList();
  }

  List<MemoryItem> recent({int limit = 20}) {
    final copy = [...items]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy.take(limit).toList();
  }

  Future<void> forget(String id) async {
    items.removeWhere((m) => m.id == id);
    await _save();
  }

  Future<void> forgetMatching(String query) async {
    final q = query.toLowerCase().trim();
    items.removeWhere((m) => m.text.toLowerCase().contains(q) || m.category.toLowerCase() == q);
    await _save();
  }

  Future<void> clear() async {
    items.clear();
    await _save();
  }

  String buildContext(String query, {int limit = 8}) {
    final relevant = search(query, limit: limit);
    if (relevant.isEmpty) return 'No saved memories are relevant to this request.';
    return relevant.map((m) => '- [${m.category}] ${m.text}').join('\n');
  }

  List<MemoryItem> _rankAll(int limit) {
    final copy = [...items]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy.take(limit).toList();
  }

  Set<String> _tokens(String value) => value.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((x) => x.length > 1).toSet();
  String _clean(String value) => _trimSentence(value.replaceAll(RegExp(r'\s+'), ' '));
  String _trimSentence(String value) => value.trim().replaceFirst(RegExp(r'[.!?]+$'), '');
  bool _similar(String a, String b) {
    final aa = _tokens(a), bb = _tokens(b);
    if (aa.isEmpty || bb.isEmpty) return false;
    final common = aa.intersection(bb).length;
    return common / math.max(aa.length, bb.length) >= 0.75;
  }
  String _normalizeRule(String pattern, String value) {
    if (pattern.contains('my name is') || pattern.contains('call me')) return 'User prefers to be called $value';
    if (pattern.contains('my favorite')) return 'Favorite: $value';
    if (pattern.contains('like|love')) return 'User likes $value';
    if (pattern.contains('prefer')) return 'User prefers $value';
    if (pattern.contains('live in')) return 'User lives in $value';
    if (pattern.contains('work')) return 'User works at $value';
    return value;
  }
  Future<void> _save() => storage.saveJsonList(_key, items.map((e) => e.toJson()).toList());
}
