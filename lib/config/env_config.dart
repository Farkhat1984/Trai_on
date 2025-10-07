/// Environment configuration for API keys and secrets
///
/// In production, these values should be loaded from environment variables
/// or secure storage. Never commit actual API keys to version control.
class EnvConfig {
  EnvConfig._();

  /// Google AI API key for Gemini API
  ///
  /// To set this:
  /// 1. Create a .env file in the project root
  /// 2. Add: GOOGLE_AI_API_KEY=your_api_key_here
  /// 3. Use flutter_dotenv to load it
  ///
  /// For now, this is a placeholder that should be replaced with proper env loading
  static const String googleAiApiKey = String.fromEnvironment(
    'GOOGLE_AI_API_KEY',
    defaultValue: 'AIzaSyDwmmtN5K8GM5t4DKVy9ZBJ0z7sfBtdIUk',
  );

  /// Base URL for Google Gemini API
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Model name for image generation
  static const String geminiModel = 'gemini-2.5-flash-image-preview';

  /// Full API endpoint
  static String get geminiEndpoint =>
      '$geminiBaseUrl/$geminiModel:generateContent';
}
