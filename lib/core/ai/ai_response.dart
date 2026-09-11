class AiToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  const AiToolCall({required this.id, required this.name, required this.arguments});
}

class AiResponse {
  final String text;
  final String? model;
  final Map<String, dynamic> raw;
  final List<AiToolCall> toolCalls;
  const AiResponse({required this.text, this.model, this.raw = const {}, this.toolCalls = const []});
}
