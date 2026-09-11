import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_provider.dart';
import '../ai_request.dart';
import '../ai_response.dart';
import '../../config/ai_config.dart';
class OpenAiCompatibleProvider implements AiProvider {
  final AiConfig config; final http.Client client;
  OpenAiCompatibleProvider(this.config,{http.Client? client}):client=client??http.Client();
  Uri get _endpoint { var base=config.baseUrl.trim().replaceFirst(RegExp(r'/+$'),''); if(base.endsWith('/chat/completions')) return Uri.parse(base); if(base.endsWith('/v1')) return Uri.parse('$base/chat/completions'); return Uri.parse('$base/v1/chat/completions'); }
  Map<String,String> get _headers=>{'Content-Type':'application/json',if(config.apiKey.trim().isNotEmpty)'Authorization':'Bearer ${config.apiKey.trim()}'};
  @override Future<AiResponse> complete(AiRequest request) async { final r=await client.post(_endpoint,headers:_headers,body:jsonEncode(request.toJson())); if(r.statusCode<200||r.statusCode>=300)throw Exception('AI request failed (${r.statusCode}): ${_error(r.body)}'); final j=jsonDecode(r.body) as Map<String,dynamic>; final c=(j['choices'] as List?)??const[]; if(c.isEmpty)throw Exception('AI provider returned no choices.'); final m=c.first['message'] as Map<String,dynamic>?; final calls=<AiToolCall>[]; for(final tc in (c.first['message']?['tool_calls'] as List?)??const[]){ final fn=tc['function'] as Map<String,dynamic>? ?? {}; Map<String,dynamic> args={}; try { final raw=fn['arguments']; final decoded=jsonDecode(raw is String ? raw : jsonEncode(raw)); if(decoded is Map) args=Map<String,dynamic>.from(decoded); } catch(_) {} calls.add(AiToolCall(id:tc['id']?.toString()??'',name:fn['name']?.toString()??'',arguments:args)); } return AiResponse(text:_content(m?['content']),model:j['model']?.toString(),raw:j,toolCalls:calls); }
  @override Stream<String> stream(AiRequest request) async* { final body=request.toJson()..['stream']=true; final req=http.Request('POST',_endpoint)..headers.addAll(_headers)..body=jsonEncode(body); final r=await client.send(req); if(r.statusCode<200||r.statusCode>=300)throw Exception('AI stream failed (${r.statusCode}): ${_error(await r.stream.bytesToString())}'); await for(final line in r.stream.transform(utf8.decoder).transform(const LineSplitter())){if(!line.startsWith('data:'))continue;final p=line.substring(5).trim();if(p=='[DONE]')break;try{final j=jsonDecode(p) as Map<String,dynamic>;final c=(j['choices'] as List?)??const[];if(c.isEmpty)continue;final d=c.first['delta'] as Map<String,dynamic>?;final t=_content(d?['content']);if(t.isNotEmpty)yield t;}catch(_){}} }
  @override Future<bool> testConnection() async {try{await complete(AiRequest(messages:const[AiMessage(role:'user',content:'Reply with OK.')],model:config.model,maxTokens:8));return true;}catch(_){return false;}}
  static String _content(dynamic v){if(v is String)return v;if(v is List)return v.map((e)=>e is Map?(e['text']??''):e.toString()).join();return v?.toString()??'';}
  static String _error(String b){try{final j=jsonDecode(b);return(j is Map&&j['error'] is Map?j['error']['message']:j).toString();}catch(_){return b.length>300?b.substring(0,300):b;}}
  @override void dispose()=>client.close();
}
