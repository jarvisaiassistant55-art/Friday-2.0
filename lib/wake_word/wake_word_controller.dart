import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import '../voice/voice_controller.dart';

/// Hands-free wake phrase engine built on the device speech recognizer.
/// It listens for a configurable phrase such as "hey jarvis", then hands the
/// remaining words to the command callback. This is foreground/app-active
/// wake phrase detection; a true always-on background hotword service requires
/// a native hotword engine and Android foreground-service integration.
class WakeWordController {
  final SpeechToText speech = SpeechToText();
  final VoiceController voice;
  String wakePhrase = 'hey jarvis';
  bool _running = false;
  bool _handling = false;
  String _last = '';
  Timer? _restartTimer;

  WakeWordController(this.voice);

  bool get isRunning => _running;

  Future<bool> initialize() => speech.initialize();

  Future<void> start({required Future<void> Function(String command) onCommand}) async {
    if (_running) return;
    if (!await initialize()) return;
    _running = true;
    await _listen(onCommand);
  }

  Future<void> _listen(Future<void> Function(String command) onCommand) async {
    if (!_running || speech.isListening) return;
    _last = '';
    await speech.listen(
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      onResult: (result) async {
        _last = result.recognizedWords.trim();
        if (!result.finalResult || _handling || _last.isEmpty) return;
        final normalized = _last.toLowerCase();
        final phrase = wakePhrase.toLowerCase().trim();
        final at = normalized.indexOf(phrase);
        if (at < 0) return;
        final command = _last.substring(at + phrase.length).trim();
        if (command.isEmpty) {
          await voice.speak('Yes, I am listening.');
          return;
        }
        _handling = true;
        await speech.stop();
        try {
          await onCommand(command);
        } finally {
          _handling = false;
          if (_running) _scheduleRestart(onCommand);
        }
      },
      onDevice: (_) {},
    );
  }

  void _scheduleRestart(Future<void> Function(String command) callback) {
    _restartTimer?.cancel();
    _restartTimer = Timer(const Duration(milliseconds: 400), () => _listen(callback));
  }

  Future<void> stop() async {
    _running = false;
    _restartTimer?.cancel();
    if (speech.isListening) await speech.stop();
  }

  Future<void> dispose() async {
    await stop();
  }
}
