class ApiKeys {
  // Gemini AI API Key - Retrieved from environment variables for security
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '', // Empty default for security
  );

  // Validation method to ensure API key is available
  static bool get hasGeminiApiKey => geminiApiKey.isNotEmpty;

  // Error message for missing API key
  static String get geminiApiKeyError =>
      'Gemini API key not found. Please set GEMINI_API_KEY environment variable.';
}
