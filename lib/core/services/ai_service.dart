import '../ai/ai_engine.dart';
import '../ai/context_builder.dart';
import '../ai/providers/openai_compatible_provider.dart';
import '../ai/tools/default_tools.dart';
import '../config/ai_config_store.dart';
import '../models/chat_message.dart';
import '../../memory/memory_manager.dart';

class AiService {
  final AiConfigStore configStore;
  final MemoryManager memory;
  AiService({AiConfigStore? configStore, MemoryManager? memory}) : configStore = configStore ?? AiConfigStore(), memory = memory ?? MemoryManager();

  Future<String> reply(String prompt, {List<ChatMessage> history = const []}) async {
    final c = await configStore.load();
    if (c.apiKey.trim().isEmpty) return 'AI is not configured yet. Open AI Settings and add your provider API key.';
    final p = OpenAiCompatibleProvider(c);
    try {
      final engine = AiEngine(provider: p, context: AiContextBuilder(memory), model: c.model, tools: buildDefaultToolRegistry());
      return (await engine.ask(prompt, history: history)).text;
    } finally { p.dispose(); }
  }
}
