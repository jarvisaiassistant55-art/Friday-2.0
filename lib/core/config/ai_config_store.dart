import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_config.dart';
class AiConfigStore {
  static const _base='ai_base_url',_model='ai_model',_temp='ai_temperature',_max='ai_max_tokens',_key='ai_api_key';
  final FlutterSecureStorage secure;
  AiConfigStore({FlutterSecureStorage? secure}):secure=secure??const FlutterSecureStorage();
  Future<AiConfig> load() async { final p=await SharedPreferences.getInstance(); return AiConfig(baseUrl:p.getString(_base)??'https://api.openai.com/v1',model:p.getString(_model)??'gpt-4o-mini',apiKey:await secure.read(key:_key)??'',temperature:p.getDouble(_temp)??0.7,maxTokens:p.getInt(_max)??1024); }
  Future<void> save(AiConfig c) async { final p=await SharedPreferences.getInstance(); await p.setString(_base,c.baseUrl.trim()); await p.setString(_model,c.model.trim()); await p.setDouble(_temp,c.temperature); await p.setInt(_max,c.maxTokens); if(c.apiKey.trim().isEmpty){await secure.delete(key:_key);}else{await secure.write(key:_key,value:c.apiKey.trim());} }
}
