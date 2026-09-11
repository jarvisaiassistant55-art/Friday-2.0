import 'package:flutter/material.dart';
import '../core/runtime/runtime_scope.dart';
import '../chat/chat_controller.dart';
import '../ui/widgets/jarvis_orb.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});
  @override State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  late final ChatController chat;
  String status = 'Tap the microphone';
  bool busy = false;

  @override
  void initState() {
    super.initState();
    chat = ChatController();
    jarvisRuntime.initialize();
  }

  Future<void> _runVoice() async {
    if (busy) return;
    setState(() { busy = true; status = 'Listening…'; });
    try {
      final text = await jarvisRuntime.voice.listenOnce();
      if (text.isEmpty) { setState(() => status = 'I didn’t hear anything'); return; }
      setState(() => status = 'You: $text');
      final reply = await chat.sendAndGet(text);
      if (!mounted) return;
      setState(() => status = reply.isEmpty ? 'I could not generate a response.' : reply);
      await jarvisRuntime.voice.speak(reply);
    } catch (e) {
      if (mounted) setState(() => status = 'Voice error: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF070A14),
    appBar: AppBar(title: const Text('Friday Voice Engine')),
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const JarvisOrb(size: 190),
        const SizedBox(height: 28),
        Text(status, textAlign: TextAlign.center, maxLines: 5, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 32),
        FloatingActionButton.large(onPressed: _runVoice, child: Icon(busy ? Icons.stop_rounded : Icons.mic_rounded)),
        const SizedBox(height: 12),
        const Text('Shared Voice → Jarvis Core → Memory → Tools → Voice', style: TextStyle(fontSize: 12, color: Colors.white54)),
      ]),
    )),
  );
}
