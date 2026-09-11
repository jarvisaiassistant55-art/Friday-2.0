# Friday 2.4 — Real Voice + Jarvis Memory

## Voice
Friday uses the device speech recognizer through `speech_to_text` and platform text-to-speech through `flutter_tts`.

Flow:
`Microphone -> Speech recognition -> AI/Chat -> Memory + Tools -> TTS`

## Wake phrase
`WakeWordController` provides an app-active foreground wake phrase mode. It detects **Hey Jarvis** from the speech recognizer and forwards the remaining words as a command.

A true always-on background hotword requires a dedicated native hotword engine and Android foreground-service/background execution policy. This release deliberately does not fake background behavior or drain the microphone continuously when the app is not active.

## Memory
`MemoryManager` stores durable memories locally, detects explicit `remember` requests and stable preferences, ranks relevant memories using lexical overlap + importance + recency, and supplies context to the AI layer.

No API key or secret is bundled with the project.
