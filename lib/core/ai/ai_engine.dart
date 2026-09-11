import 'ai_provider.dart';
import 'ai_request.dart';
import 'ai_response.dart';
import 'context_builder.dart';
import 'tool_registry.dart';
import '../models/chat_message.dart';

class AiEngine {
  final AiProvider provider;
  final AiContextBuilder context;
  final ToolRegistry tools;
  final String model;
  AiEngine({required this.provider, required this.context, required this.model, ToolRegistry? tools}) : tools = tools ?? ToolRegistry();

  Future<AiResponse> ask(String text, {List<ChatMessage> history = const []}) async {
    var request = AiRequest(messages: context.build(userText: text, history: history), model: model, tools: tools.all);
    var response = await provider.complete(request);
    for (var round = 0; round < 3 && response.toolCalls.isNotEmpty; round++) {
      final assistantRaw = response.raw['choices'] is List && (response.raw['choices'] as List).isNotEmpty
          ? (response.raw['choices'] as List).first['message'] as Map<String, dynamic>? : null;
      final messages = [...request.messages, AiMessage(role: 'assistant', content: response.text, toolCalls: (assistantRaw?['tool_calls'] as List?)?.cast<Map<String, dynamic>>())];
      for (final call in response.toolCalls) {
        final tool = tools.get(call.name);
        final result = tool == null ? 'Unknown tool: ${call.name}' : await _safeRun(tool, call.arguments);
        messages.add(AiMessage(role: 'tool', content: result, toolCallId: call.id));
      }
      request = AiRequest(messages: messages, model: model, tools: tools.all);
      response = await provider.complete(request);
    }
    return response;
  }

  Future<String> _safeRun(AiTool tool, Map<String, dynamic> args) async {
    try { return await tool.handler(args); } catch (e) { return 'Tool ${tool.name} failed: $e'; }
  }

  Stream<String> askStream(String text, {List<ChatMessage> history = const []}) =>
      provider.stream(AiRequest(messages: context.build(userText: text, history: history), model: model, stream: true, tools: tools.all));

  void dispose() => provider.dispose();
}
