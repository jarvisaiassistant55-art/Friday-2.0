# Friday 2.2 Tool Calling

Friday now exposes a provider-neutral tool registry to the AI engine.

## Built-in tool
`device_command` routes safe supported commands through the existing automation layer.

Examples:
- turn flashlight on/off
- increase/decrease volume
- check battery

The AI may request a tool, Friday executes it locally, then sends the result back to the model for a natural-language response.

Tool execution is capped to three AI/tool rounds per request and failures are returned as tool results instead of crashing the chat flow.
