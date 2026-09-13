import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../ui/widgets/glass_card.dart';
import 'chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController c;
  final TextEditingController input = TextEditingController();

  @override
  void initState() {
    super.initState();

    c = ChatController();

    c.load().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.cyan,
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'J.A.R.V.I.S',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.circle,
                  size: 10,
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                const Text('Online'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: c.messages.length,
              itemBuilder: (context, i) {
                final message = c.messages[i];

                return Align(
                  alignment: message.fromUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(message.text),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: AppTheme.cyan,
                  ),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = input.text.trim();

    if (text.isEmpty || c.loading) {
      return;
    }

    input.clear();

    setState(() {});

    await c.send(text);

    if (mounted) {
      setState(() {});
    }
  }
}
