import 'package:flutter/material.dart';
import '../../memory/memory_manager.dart';
import '../../core/models/memory_item.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});
  @override State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final memory = MemoryManager();
  final input = TextEditingController();
  List<MemoryItem> items = [];

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { await memory.load(); if (mounted) setState(() => items = memory.recent(limit: 100)); }
  Future<void> _add() async { final text = input.text.trim(); if (text.isEmpty) return; await memory.remember(text, category: 'manual', importance: .9); input.clear(); await _load(); }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jarvis Memory')),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Expanded(child: TextField(controller: input, decoration: const InputDecoration(hintText: 'Add something Jarvis should remember…'))),
        IconButton(onPressed: _add, icon: const Icon(Icons.add_circle_outline)),
      ])),
      Expanded(child: items.isEmpty
        ? const Center(child: Text('No memories yet. Tell Jarvis “remember that…”'))
        : ListView.builder(itemCount: items.length, itemBuilder: (_, i) { final m = items[i]; return ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: Text(m.text), subtitle: Text('${m.category} • importance ${(m.importance * 100).round()}%'),
            trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await memory.forget(m.id); await _load(); }),
          ); }))
    ]),
  );

  @override void dispose() { input.dispose(); super.dispose(); }
}
