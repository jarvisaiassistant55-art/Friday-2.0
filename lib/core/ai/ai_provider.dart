import 'ai_request.dart';
import 'ai_response.dart';
abstract class AiProvider {
  Future<AiResponse> complete(AiRequest request);
  Stream<String> stream(AiRequest request);
  Future<bool> testConnection();
  void dispose();
}
