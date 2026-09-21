---
name: gemini-tts
description: Gemini TTS integration for Mave. Use when implementing any voice
  playback, phonics sound generation, story narration, or mic input (STT).
  Covers API calls, audio caching, and COPPA-safe handling.
---

# Gemini TTS / Voice Integration — Mave

## Package Dependencies
```yaml
# pubspec.yaml
dependencies:
  http: ^1.2.0
  just_audio: ^0.9.38    # audio playback
  path_provider: ^2.1.2  # local cache
  record: ^5.1.2         # mic input (STT flow)
  crypto: ^3.0.3         # cache key hashing
```

## TTS Service Pattern
```dart
// lib/core/services/tts_service.dart
class TtsService {
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  final _player = AudioPlayer();
  final Map<String, String> _cache = {}; // sound → local file path

  /// Play a phonics sound for a given letter/phoneme.
  /// Caches audio locally to avoid repeated API calls (COPPA: no user data sent).
  Future<void> playPhonicsSound(String phoneme) async {
    final cacheKey = _phonemeHash(phoneme);
    if (_cache.containsKey(cacheKey)) {
      await _player.setFilePath(_cache[cacheKey]!);
    } else {
      final audioBytes = await _callGeminiTts(
        text: phoneme,
        voice: 'Kore',          // child-friendly voice
        speakingRate: 0.8,       // slower for toddlers
      );
      final path = await _saveToDisk(cacheKey, audioBytes);
      _cache[cacheKey] = path;
      await _player.setFilePath(path);
    }
    await _player.play();
  }

  Future<Uint8List> _callGeminiTts({
    required String text,
    String voice = 'Kore',
    double speakingRate = 1.0,
  }) async {
    // POST to Gemini TTS endpoint
    // Model: gemini-2.5-flash or gemini-2.0-flash-preview-tts
    // Return raw audio bytes (PCM / WAV)
    throw UnimplementedError('implement with actual API key from env');
  }
}
```

## Prompt Guidelines for Phonics Sounds
- Single phoneme: `"Say only the sound /m/ as in 'mat', no word, just the sound /mmm/"`
- Word narration: `"Read this word slowly and clearly for a toddler: 'mat'"`
- Story narration: `"Read this story in a warm, slow, engaging voice for a 2-year-old: [STORY]"`

## COPPA Compliance
- Never send child name, age, or any PII to Gemini API
- Only send: phoneme strings, anonymised story text
- All audio cached locally — no cloud storage of audio
- API key stored in `.env` / Flutter `--dart-define`, never hardcoded

## Error Handling
```dart
try {
  await ttsService.playPhonicsSound('m');
} on SocketException {
  // Offline: play cached fallback or show visual-only mode
} catch (e) {
  // Log to Crashlytics (non-PII), show retry UI
}
```
