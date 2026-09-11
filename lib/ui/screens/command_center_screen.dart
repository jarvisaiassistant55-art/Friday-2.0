import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/orchestration/assistant_core.dart';
import '../../core/orchestration/assistant_event.dart';
import '../../core/orchestration/assistant_event_bus.dart';
import '../../memory/memory_manager.dart';
import '../../chat/chat_screen.dart';
import '../../voice/voice_screen.dart';
import '../../wake_word/wake_word_screen.dart';
import 'memory_screen.dart';
import 'tools_screen.dart';
import 'ai_settings_screen.dart';
import '../widgets/glass_card.dart';
import '../widgets/jarvis_orb.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});
  @override State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  late final AssistantCore _core;
  StreamSubscription<AssistantEvent>? _events;
  final List<AssistantEvent> _feed = [];
  int _memoryCount = 0;

  @override
  void initState() {
    super.initState();
    _core = AssistantCore(events: AssistantEventBus());
    _events = _core.events.stream.listen((event) {
      if (!mounted) return;
      setState(() {
        _feed.insert(0, event);
        if (_feed.length > 8) _feed.removeLast();
      });
    });
    _load();
  }

  Future<void> _load() async {
    await _core.initialize();
    if (!mounted) return;
    setState(() => _memoryCount = _core.memory.items.length);
  }

  @override
  void dispose() {
    _events?.cancel();
    _core.dispose();
    super.dispose();
  }

  void _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 380;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(compact ? 14 : 18, 14, compact ? 14 : 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('COMMAND CENTER', style: TextStyle(fontSize: 11, letterSpacing: 2.2, color: AppTheme.cyan, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('J.A.R.V.I.S', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
              ])),
              Container(width: 10, height: 10, decoration: BoxDecoration(color: AppTheme.cyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.cyan, blurRadius: 10)])),
            ]),
            const SizedBox(height: 14),
            GlassCard(child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                const SizedBox(width: 76, height: 76, child: JarvisOrb(size: 76)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Core online', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Unified intelligence layer is ready.', style: TextStyle(color: Colors.white.withValues(alpha: .62), fontSize: 12)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    _pill('MEMORY $_memoryCount'), _pill('VOICE'), _pill('TOOLS'),
                  ]),
                ])),
              ]),
            )),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _module(Icons.chat_bubble_rounded, 'Chat', 'Talk', () => _open(const ChatScreen()))),
              const SizedBox(width: 8),
              Expanded(child: _module(Icons.mic_rounded, 'Voice', 'Speak', () => _open(const VoiceScreen()))),
              const SizedBox(width: 8),
              Expanded(child: _module(Icons.hearing_rounded, 'Wake', 'Hey Jarvis', () => _open(const WakeWordScreen()))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _module(Icons.memory_rounded, 'Memory', 'Personal', () => _open(const MemoryScreen()))),
              const SizedBox(width: 8),
              Expanded(child: _module(Icons.extension_rounded, 'Tools', 'Actions', () => _open(const ToolsScreen()))),
              const SizedBox(width: 8),
              Expanded(child: _module(Icons.tune_rounded, 'AI', 'Provider', () => _open(const AiSettingsScreen()))),
            ]),
            const SizedBox(height: 16),
            const Text('LIVE SYSTEM FEED', style: TextStyle(fontSize: 11, letterSpacing: 1.7, color: Colors.white54, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (_feed.isEmpty)
              GlassCard(child: const Padding(padding: EdgeInsets.all(14), child: Row(children: [Icon(Icons.radar_rounded, color: AppTheme.cyan), SizedBox(width: 10), Expanded(child: Text('Waiting for assistant activity…', style: TextStyle(color: Colors.white60, fontSize: 12)))])))
            else
              ..._feed.map(_eventTile),
          ]),
        ),
      ),
    );
  }

  Widget _eventTile(AssistantEvent event) {
    final icon = switch (event.type) {
      AssistantEventType.thinking => Icons.psychology_rounded,
      AssistantEventType.response => Icons.auto_awesome_rounded,
      AssistantEventType.memoryUpdated => Icons.memory_rounded,
      AssistantEventType.toolStarted => Icons.play_arrow_rounded,
      AssistantEventType.toolFinished => Icons.check_circle_outline_rounded,
      AssistantEventType.error => Icons.error_outline_rounded,
      AssistantEventType.userInput => Icons.person_rounded,
      AssistantEventType.statusChanged => Icons.radio_button_checked_rounded,
    };
    return Padding(padding: const EdgeInsets.only(bottom: 7), child: GlassCard(child: ListTile(dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1), leading: Icon(icon, size: 20, color: AppTheme.cyan), title: Text(event.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)), subtitle: Text(_label(event.type), style: const TextStyle(fontSize: 10, color: Colors.white38)))));
  }

  String _label(AssistantEventType type) => type.name.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}').toUpperCase();

  Widget _module(IconData icon, String title, String subtitle, VoidCallback onTap) => Expanded(child: GlassCard(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Padding(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7), child: Column(children: [Icon(icon, color: AppTheme.cyan, size: 21), const SizedBox(height: 7), Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 9))])))));

  Widget _pill(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.cyan.withValues(alpha: .08), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.cyan.withValues(alpha: .16))), child: Text(text, style: const TextStyle(fontSize: 8, letterSpacing: .7, color: AppTheme.cyan, fontWeight: FontWeight.w700)));
}
