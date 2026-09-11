class MemoryItem {
  final String id;
  final String text;
  final String category;
  final double importance;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemoryItem({
    required this.id,
    required this.text,
    required this.category,
    this.importance = 0.6,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  MemoryItem copyWith({String? text, String? category, double? importance, DateTime? updatedAt}) => MemoryItem(
        id: id,
        text: text ?? this.text,
        category: category ?? this.category,
        importance: importance ?? this.importance,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'category': category,
        'importance': importance,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static MemoryItem fromJson(Map<String, dynamic> j) => MemoryItem(
        id: j['id']?.toString() ?? '',
        text: j['text']?.toString() ?? '',
        category: j['category']?.toString() ?? 'general',
        importance: (j['importance'] as num?)?.toDouble() ?? 0.6,
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
        updatedAt: DateTime.tryParse(j['updatedAt']?.toString() ?? j['createdAt']?.toString() ?? ''),
      );
}
