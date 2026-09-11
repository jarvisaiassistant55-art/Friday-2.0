import '../orchestration/assistant_core.dart';
import '../orchestration/assistant_event_bus.dart';
import '../../voice/voice_controller.dart';
import '../../wake_word/wake_word_controller.dart';

/// Process-wide Jarvis runtime. Every screen talks to the same Core, memory,
/// conversation store, event bus and voice engine for the lifetime of the app.
class AssistantRuntime {
  AssistantRuntime._();
  static final AssistantRuntime instance = AssistantRuntime._();

  late final AssistantEventBus events = AssistantEventBus();
  late final AssistantCore core = AssistantCore(events: events);
  late final VoiceController voice = VoiceController();
  late final WakeWordController wake = WakeWordController(voice);

  bool _initialized = false;
  Future<void>? _initializing;

  bool get isInitialized => _initialized;

  Future<void> initialize() {
    if (_initialized) return Future.value();
    return _initializing ??= _initializeOnce();
  }

  Future<void> _initializeOnce() async {
    try {
      await core.initialize();
      _initialized = true;
    } finally {
      _initializing = null;
    }
  }

  Future<void> dispose() async {
    await wake.dispose();
    await voice.dispose();
    await core.dispose();
    _initialized = false;
  }
}
