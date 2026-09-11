# Architecture
UI -> Chat/Voice -> Core services -> Memory/Automation -> Android capabilities.

Keep AI networking, secrets and provider-specific code inside core/services. Device actions should always be permission-aware and constrained to supported Android APIs.

## AI Engine Layer
`ChatController -> AiService -> AiEngine -> AiProvider -> OpenAI-compatible REST API`

`AiContextBuilder` injects relevant saved memory and recent conversation history. `ToolRegistry` provides the extension point for future device/app tools. Secrets are kept out of source code and stored with secure device storage.
