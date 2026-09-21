/// App secrets injected at compile time via --dart-define.
///
/// Usage:
///   flutter run --dart-define=GEMINI_API_KEY=your_key_here
///
/// One key covers everything:
///   • gemini-1.5-flash          — activity generation (title, story, uiType)
///   • gemini-2.5-flash-preview-tts — TTS for all game audio
///
/// Obtain from: https://aistudio.google.com/app/apikey
/// No .env file or build_runner step required.
abstract class Env {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );
}
