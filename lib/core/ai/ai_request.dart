import 'tool_registry.dart';

class AiMessage {
  final String role;
  final String content;
  final String? toolCallId;
  final List<Map<String, dynamic>>? toolCalls;
  const AiMessage({required this.role, required this.content, this.toolCallId, this.toolCalls});
  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    if (toolCallId != null) 'tool_call_id': toolCallId,
    if (toolCalls != null) 'tool_calls': toolCalls,
  };
}

class AiRequest {
  final List<AiMessage> messages;
  final String model;
  final double temperature;
  final int maxTokens;
  final bool stream;
  final List<AiTool> tools;
  const AiRequest({required this.messages, required this.model, this.temperature = 0.7, this.maxTokens = 1024, this.stream = false, this.tools = const []});
  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((e) => e.toJson()).toList(),
    'temperature': temperature,
    'max_tokens': maxTokens,
    'stream': stream,
    if (tools.isNotEmpty) 'tools': tools.map((e) => e.toProviderJson()).toList(),
    if (tools.isNotEmpty) 'tool_choice': 'auto',
  };
}
