import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Real device voice engine: Android/iOS speech recognition + platform TTS.
/// It supports one-shot listening, continuous sessions, interruption and
/// an optional callback that sends recognized text to the AI engine.
class VoiceController {
  final SpeechToText speech = SpeechToText();
  final FlutterTts tts = FlutterTts();
  bool _initialized = false;
  bool _speaking = false;
  bool _continuous = false;
  String _latest = '';
  Timer? _silenceTimer;

  bool get isListening => speech.isListening;
  bool get isSpeaking => _speaking;

  Future<bool> initialize() async {
    if (_initialized) return true;
    final ok = await speech.initialize(
      onError: (_) => _silenceTimer?.cancel(),
      onStatus: (status) {
        if (status == 'done' && _continuous) {
          _restartContinuous();
        }
      },
    );
    await tts.setSpeechRate(0.48);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    _initialized = ok;
    return ok;
  }

  Future<String> listenOnce({Duration listenFor = const Duration(seconds: 30), Duration pauseFor = const Duration(seconds: 3)}) async {
    if (!await initialize()) return '';
    await stopSpeaking();
    _latest = '';
    final done = Completer<void>();
    await speech.listen(
      listenFor: listenFor,
      pauseFor: pauseFor,
      partialResults: true,
      onResult: (result) {
        _latest = result.recognizedWords.trim();
        if (result.finalResult && !done.isCompleted) done.complete();
      },
    );
    await Future.any([
      done.future,
      Future.delayed(listenFor + const Duration(seconds: 1)),
    ]);
    await speech.stop();
    return _latest;
  }

  Future<void> startContinuous({required Future<void> Function(String text) onCommand}) async {
    if (!await initialize()) return;
    _continuous = true;
    await _listenContinuous(onCommand);
  }

  Future<void> _listenContinuous(Future<void> Function(String text) onCommand) async {
    if (!_continuous || speech.isListening) return;
    _latest = '';
    await speech.listen(
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      onResult: (result) async {
        _latest = result.recognizedWords.trim();
        if (result.finalResult && _latest.isNotEmpty) {
          final command = _latest;
          _latest = '';
          await onCommand(command);
        }
      },
    );
  }

  Future<void> _restartContinuous() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (_continuous) {
      // Caller must use startContinuous again after a platform session ends.
    }
  }

  Future<void> stopListening() async {
    _continuous = false;
    _silenceTimer?.cancel();
    if (speech.isListening) await speech.stop();
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await initialize();
    _speaking = true;
    await tts.awaitSpeakCompletion(true);
    await tts.speak(text.trim());
    _speaking = false;
  }

  Future<void> stopSpeaking() async {
    await tts.stop();
    _speaking = false;
  }

  Future<void> dispose() async {
    await stopListening();
    await stopSpeaking();
    _silenceTimer?.cancel();
  }
}
