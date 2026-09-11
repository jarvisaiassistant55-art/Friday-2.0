import '../ai/ai_engine.dart';
import '../ai/context_builder.dart';
import '../ai/providers/openai_compatible_provider.dart';
import '../ai/tools/default_tools.dart';
import '../config/ai_config_store.dart';
import '../conversation/conversation_store.dart';
import '../models/chat_message.dart';
import '../../automation/automation_manager.dart';
import '../../memory/memory_manager.dart';
import 'assistant_event.dart';
import 'assistant_event_bus.dart';

class AssistantCore {
  final AiConfigStore configStore;
  final MemoryManager memory;
  final ConversationStore conversation;
  final AutomationManager automation;
  final AssistantEventBus events;

  AssistantCore({
    AiConfigStore? configStore,
    MemoryManager? memory,
    ConversationStore? conversation,
    AutomationManager? automation,
    AssistantEventBus? events,
  })  : configStore = configStore ?? AiConfigStore(),
        memory = memory ?? MemoryManager(),
        conversation = conversation ?? ConversationStore(),
        automation = automation ?? AutomationManager(),
        events = events ?? AssistantEventBus();

  Future<void> initialize() async {
    await memory.load();
    events.emit(AssistantEvent(
      type: AssistantEventType.statusChanged,
      message: 'Jarvis Core ready',
      data: {'memoryCount': memory.items.length},
    ));
  }

  Future<String> ask(String input) async {
    final prompt = input.trim();
    if (prompt.isEmpty) return '';

    events.emit(AssistantEvent(
      type: AssistantEventType.userInput,
      message: prompt,
    ));

    final learned = await memory.learnFromUserMessage(prompt);
    if (learned.isNotEmpty) {
      events.emit(AssistantEvent(
        type: AssistantEventType.memoryUpdated,
        message: 'Memory updated',
        data: {'count': learned.length},
      ));
    }

    events.emit(AssistantEvent(
      type: AssistantEventType.thinking,
      message: 'Thinking…',
    ));

    final history = await conversation.load();
    final updatedHistory = [...history, ChatMessage(text: prompt, fromUser: true)];
    await conversation.save(updatedHistory);

    final config = await configStore.load();
    if (config.apiKey.trim().isEmpty) {
      const message = 'AI is not configured yet. Open AI Settings and add your provider API key.';
      await conversation.save([...updatedHistory, ChatMessage(text: message, fromUser: false)]);
      events.emit(AssistantEvent(type: AssistantEventType.response, message: message));
      return message;
    }

    final provider = OpenAiCompatibleProvider(config);
    try {
      final engine = AiEngine(
        provider: provider,
        context: AiContextBuilder(memory),
        model: config.model,
        tools: buildDefaultToolRegistry(),
      );
      final result = await engine.ask(prompt, history: history);
      final response = result.text.trim();
      await conversation.save([...updatedHistory, ChatMessage(text: response, fromUser: false)]);
      events.emit(AssistantEvent(
        type: AssistantEventType.response,
        message: response,
        data: {'toolCalls': result.toolCalls.length},
      ));
      return response;
    } catch (e) {
      final message = 'I could not complete that request: $e';
      events.emit(AssistantEvent(
        type: AssistantEventType.error,
        message: message,
      ));
      return message;
    } finally {
      provider.dispose();
    }
  }

  Future<String> runAutomation(String command) async {
    events.emit(AssistantEvent(
      type: AssistantEventType.toolStarted,
      message: command,
    ));
    try {
      final result = await automation.execute(command);
      events.emit(AssistantEvent(
        type: AssistantEventType.toolFinished,
        message: result.message,
        data: {'success': result.success},
      ));
      return result.message;
    } catch (e) {
      events.emit(AssistantEvent(
        type: AssistantEventType.error,
        message: 'Automation failed: $e',
      ));
      rethrow;
    }
  }

  Future<void> remember(String text) async {
    await memory.remember(text, category: 'manual', importance: 0.8);
    events.emit(AssistantEvent(
      type: AssistantEventType.memoryUpdated,
      message: text,
    ));
  }

  Future<void> dispose() async {
    await events.dispose();
  }
}
