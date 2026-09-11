import '../core/models/chat_message.dart';
import '../core/orchestration/assistant_core.dart';
import '../core/runtime/runtime_scope.dart';

class ChatController {
  final AssistantCore core;
  final List<ChatMessage> messages = [];
  bool loading = false;

  ChatController({AssistantCore? core}) : core = core ?? jarvisRuntime.core;

  Future<void> load() async {
    await jarvisRuntime.initialize();
    messages..clear()..addAll(await core.conversation.load());
  }

  Future<String> sendAndGet(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || loading) return '';
    loading = true;
    try {
      await jarvisRuntime.initialize();
      final reply = await core.ask(clean);
      await load();
      return reply;
    } finally {
      loading = false;
    }
  }

  Future<void> send(String text) async {
    await sendAndGet(text);
  }
}
