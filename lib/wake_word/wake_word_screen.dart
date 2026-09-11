import 'package:flutter/material.dart';
import '../core/runtime/runtime_scope.dart';
import '../chat/chat_controller.dart';
import '../ui/widgets/jarvis_orb.dart';

class WakeWordScreen extends StatefulWidget {
  const WakeWordScreen({super.key});
  @override State<WakeWordScreen> createState() => _WakeWordScreenState();
}

class _WakeWordScreenState extends State<WakeWordScreen> {
  late final ChatController chat;
  String status = 'Wake phrase standby';
  bool running = false;

  @override
  void initState() {
    super.initState();
    chat = ChatController();
    jarvisRuntime.initialize();
  }

  Future<void> _toggle() async {
    if (running) {
      await jarvisRuntime.wake.stop();
      if (mounted) setState(() { running = false; status = 'Wake phrase standby'; });
      return;
    }
    await jarvisRuntime.wake.start(onCommand: _handleCommand);
    if (mounted) setState(() { running = jarvisRuntime.wake.isRunning; status = running ? 'Listening for “Hey Jarvis”…' : 'Microphone permission or speech service unavailable'; });
  }

  Future<void> _handleCommand(String command) async {
    if (!mounted) return;
    setState(() => status = 'Thinking: $command');
    final reply = await chat.sendAndGet(command);
    if (!mounted) return;
    setState(() => status = reply.isEmpty ? 'I could not generate a response.' : reply);
    await jarvisRuntime.voice.speak(reply);
    if (mounted && running) setState(() => status = 'Listening for “Hey Jarvis”…');
  }

  @override
  void dispose() {
    // The runtime owns wake/voice. Stopping here prevents a page change from
    // leaving an active recognizer running, without destroying the singleton.
    jarvisRuntime.wake.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF050712),
    appBar: AppBar(title: const Text('Jarvis Wake Word')),
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedScale(scale: running ? 1.04 : 1.0, duration: const Duration(milliseconds: 500), child: const JarvisOrb(size: 170)),
      const SizedBox(height: 24),
      Text(running ? 'HEY JARVIS' : 'JARVIS', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 3)),
      const SizedBox(height: 8),
      Text(status, textAlign: TextAlign.center, maxLines: 6, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
      const SizedBox(height: 28),
      SizedBox(width: 190, height: 52, child: FilledButton.icon(onPressed: _toggle, icon: Icon(running ? Icons.stop_rounded : Icons.mic_rounded), label: Text(running ? 'Stop Standby' : 'Start Standby'))),
      const SizedBox(height: 14),
      const Text('Say “Hey Jarvis” followed by your command.', style: TextStyle(fontSize: 12, color: Colors.white45)),
      const SizedBox(height: 6),
      const Text('Foreground/app-active wake phrase mode', style: TextStyle(fontSize: 11, color: Colors.white30)),
    ]))))),
  );
}
