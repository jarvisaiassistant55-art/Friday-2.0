# Friday 4.0 — Unified AI OS Core

Friday 4.0 introduces a single orchestration layer for the assistant's major capabilities.

## Core pieces

- `AssistantCore`: unified entry point for text requests, automation and memory.
- `AssistantEventBus`: broadcast lifecycle events to UI, voice, notifications and future agents.
- `AssistantEvent`: typed events for input, thinking, responses, memory, tools, errors and status.

## Usage

```dart
final core = AssistantCore();
await core.initialize();
final reply = await core.ask('Remember that I prefer concise answers.');
```

Subscribe to `core.events.stream` to drive status indicators, activity history, voice feedback or the future Command Center.

### Architecture rule

UI screens should call `AssistantCore` instead of directly coordinating multiple AI, memory and automation services. This keeps future voice, vision, RAG, agents and plugins modular.

## Current scope

The 4.0 core is local-first and foreground-safe. It does not claim always-on background execution. Native Android services and background scheduling remain separate modules for the later Android integration milestone.
