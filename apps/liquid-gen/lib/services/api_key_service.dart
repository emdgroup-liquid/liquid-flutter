import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyService {
  static final ApiKeyService instance = ApiKeyService._();
  ApiKeyService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyOpenAI = 'api_key_openai';
  static const String _keyAnthropic = 'api_key_anthropic';
  static const String _keyOllama = 'api_key_ollama';
  static const String _keyGemini = 'api_key_gemini';

  String _getStorageKey(String provider) {
    return switch (provider.toLowerCase()) {
      'openai' => _keyOpenAI,
      'anthropic' => _keyAnthropic,
      'ollama' => _keyOllama,
      'gemini' => _keyGemini,
      _ => throw ArgumentError('Unknown provider: $provider'),
    };
  }

  Future<String?> getApiKey(String provider) async {
    final key = _getStorageKey(provider);
    return await _storage.read(key: key);
  }

  Future<void> setApiKey(String provider, String apiKey) async {
    final key = _getStorageKey(provider);
    await _storage.write(key: key, value: apiKey);
  }

  Future<void> deleteApiKey(String provider) async {
    final key = _getStorageKey(provider);
    await _storage.delete(key: key);
  }

  Future<bool> hasApiKey(String provider) async {
    final apiKey = await getApiKey(provider);
    return apiKey != null && apiKey.isNotEmpty;
  }
}
