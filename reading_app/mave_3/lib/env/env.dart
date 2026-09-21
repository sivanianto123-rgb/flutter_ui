/// App secrets injected at compile time via --dart-define.
///
/// Usage:
///   flutter run --dart-define=GEMINI_API_KEY=your_key_here
abstract class Env {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

}
