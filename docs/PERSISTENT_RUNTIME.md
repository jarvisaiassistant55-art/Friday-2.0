# Friday 4.1 — Persistent Assistant Runtime

Friday now uses one process-wide `AssistantRuntime` singleton. The runtime owns one `AssistantCore`, event bus, voice engine and wake controller. Screens reuse these instances instead of creating independent memory/conversation/voice stacks.

## Benefits
- Shared long-term memory and conversation state
- One event stream for the Command Center
- Shared voice/TTS lifecycle
- Shared wake-phrase controller
- One-time core initialization
- Cleaner foundation for agents, plugins and proactive automation

## Scope
The wake phrase remains foreground/app-active. This runtime does not claim to provide an always-on background hotword service.
