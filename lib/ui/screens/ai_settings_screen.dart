import 'package:flutter/material.dart';
import '../../core/config/ai_config.dart';
import '../../core/config/ai_config_store.dart';
import '../../core/ai/providers/openai_compatible_provider.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});
  @override State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}
class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final store = AiConfigStore();
  final base = TextEditingController();
  final model = TextEditingController();
  final key = TextEditingController();
  bool obscure = true, busy = false;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final c = await store.load(); base.text=c.baseUrl; model.text=c.model; key.text=c.apiKey; if(mounted)setState((){}); }
  Future<void> _saveTest() async {
    setState(()=>busy=true);
    final c=AiConfig(baseUrl:base.text,model:model.text,apiKey:key.text);
    await store.save(c);
    final provider=OpenAiCompatibleProvider(c);
    final ok=await provider.testConnection();
    provider.dispose();
    if(mounted){setState(()=>busy=false);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(ok?'AI connection successful':'Saved, but the connection test failed.')));}
  }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('AI Engine')),body:ListView(padding:const EdgeInsets.all(20),children:[
    const Text('Real AI Engine',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),const Text('Configure an OpenAI-compatible chat API. Your API key is stored using secure device storage.'),const SizedBox(height:24),
    TextField(controller:base,decoration:const InputDecoration(labelText:'Base URL',hintText:'https://api.openai.com/v1')),const SizedBox(height:14),
    TextField(controller:model,decoration:const InputDecoration(labelText:'Model',hintText:'gpt-4o-mini')),const SizedBox(height:14),
    TextField(controller:key,obscureText:obscure,decoration:InputDecoration(labelText:'API key',suffixIcon:IconButton(onPressed:()=>setState(()=>obscure=!obscure),icon:Icon(obscure?Icons.visibility:Icons.visibility_off)))),const SizedBox(height:24),
    FilledButton.icon(onPressed:busy?null:_saveTest,icon:Icon(busy?Icons.hourglass_top:Icons.cloud_done),label:Text(busy?'Testing…':'Save & Test Connection')),
  ]));
  @override void dispose(){base.dispose();model.dispose();key.dispose();super.dispose();}
}
