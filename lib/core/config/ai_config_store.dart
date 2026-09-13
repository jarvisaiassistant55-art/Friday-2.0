import 'package:shared_preferences/shared_preferences.dart';
import 'ai_config.dart';

class AiConfigStore {
  static const _base = 'ai_base_url';
  static const _model = 'ai_model';
  static const _temp = 'ai_temperature';
  static const _max = 'ai_max_tokens';
  static const _key = 'ai_api_key';

  Future<AiConfig> load() async {
    final p = await SharedPreferences.getInstance();

    return AiConfig(
      baseUrl: p.getString(_base) ?? 'https://api.openai.com/v1',
      model: p.getString(_model) ?? 'gpt-4o-mini',
      apiKey: p.getString(_key) ?? '',
      temperature: p.getDouble(_temp) ?? 0.7,
      maxTokens: p.getInt(_max) ?? 1024,
    );
  }

  Future<void> save(AiConfig c) async {
    final p = await SharedPreferences.getInstance();

    await p.setString(_base, c.baseUrl.trim());
    await p.setString(_model, c.model.trim());
    await p.setDouble(_temp, c.temperature);
    await p.setInt(_max, c.maxTokens);

    if (c.apiKey.trim().isEmpty) {
      await p.remove(_key);
    } else {
      await p.setString(_key, c.apiKey.trim());
    }
  }
}
