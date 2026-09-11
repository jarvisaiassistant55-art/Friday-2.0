# Friday 2.4 — JARVIS AI Assistant

Production-oriented Flutter foundation for a futuristic personal assistant.

## Included
- Premium dark/glass UI
- Home, Chat, Tools, Profile, Settings
- Voice assistant foundation (speech-to-text + TTS)
- Persistent local memory
- Automation command router
- Flashlight, volume and battery actions
- Runtime permission layer
- Task scheduler foundation
- Android MethodChannel-ready architecture

## Run
1. Install Flutter, Android Studio, and JDK 17.
2. Run `flutter pub get`.
3. Run `flutter analyze`.
4. Connect an Android device/emulator and run `flutter run`.

The Android module is configured to compile Java and Kotlin with Java 17.

If Gradle reports that Java is missing or the Java version is unsupported, point
`JAVA_HOME` to a JDK 17 installation before running Flutter:

```bash
export JAVA_HOME=/path/to/jdk-17
export PATH="$JAVA_HOME/bin:$PATH"
flutter doctor -v
flutter clean
flutter pub get
flutter run
```

## AI provider
`lib/core/services/ai_service.dart` is intentionally provider-neutral. Add your preferred API/backend there and keep API keys out of source control.

## Friday 2.1 AI Engine
- Provider-neutral OpenAI-compatible REST integration
- Secure API-key storage with `flutter_secure_storage`
- Memory-aware context building
- Conversation persistence
- Non-streaming and SSE streaming provider APIs
- AI Engine settings screen
- Tool registry foundation for future function calling

No API key is bundled with the project. Configure it in Settings → AI Engine.


## Friday 2.3 — Real Voice + Long-Term Memory

### Real voice engine
The voice module uses the device speech-recognition engine through `speech_to_text` and the platform text-to-speech engine through `flutter_tts`. The pipeline is: microphone → speech recognition → Jarvis AI → memory/tool execution → spoken response. No fake voice response is used.

### Real Jarvis memory
Memory is local-first and persistent. It stores explicit “remember that…” requests plus common stable facts/preferences, ranks memories using token relevance + importance + recency, injects relevant memories into the AI context, and provides a memory-management UI.

Examples:
- “Remember that I prefer concise answers.”
- “My name is Alex.”
- “I like dark themes.”
- “My favorite language is Dart.”

The API key remains in secure storage and is never committed to the project.


## Friday 2.4
Includes real device speech-to-text/TTS, persistent Jarvis memory, and an app-active “Hey Jarvis” wake phrase mode. See `docs/VOICE_AND_MEMORY.md`.
