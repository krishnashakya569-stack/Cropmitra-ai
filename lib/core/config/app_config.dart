/// Runtime configuration for the application.
///
/// Pass the Groq key only while running or building:
/// `flutter run --dart-define=GROQ_API_KEY=your_key`
///
/// Do not put a production API key in a GitHub repository or a web build.
abstract final class AppConfig {
  static const groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  static bool get hasGroqApiKey => groqApiKey.trim().isNotEmpty;
}
