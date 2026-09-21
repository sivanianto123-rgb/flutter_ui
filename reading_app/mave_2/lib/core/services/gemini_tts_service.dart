import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../helpers/phonetic_helper.dart';
import 'audio_cache_service.dart';

/// Gemini Text-to-Speech service using gemini-2.5-flash-preview-tts.
///
/// Single API key covers both activity generation and TTS — no second service
/// or GCP billing account needed beyond the standard Gemini quota.
///
/// Audio format:
///   Gemini returns raw Linear PCM (24 000 Hz, 16-bit, mono) encoded as
///   base64 in candidates[0].content.parts[0].inlineData.data.
///   We prepend a 44-byte RIFF/WAV header so just_audio can play it directly.
///
/// Cache hierarchy (fastest → slowest):
///   1. File cache ([AudioCacheService]) — SHA-256 keyed .wav files on disk.
///      Survives app restarts, works fully offline, zero quota usage.
///   2. Hive vault (mave_audio_vault) — legacy fallback, kept for backwards
///      compatibility until the file cache is fully warmed up.
///   3. Gemini TTS API — called once per unique phrase, ever.
///
/// Phonetic safety:
///   All text passes through [PhoneticHelper.sanitize] before synthesis to
///   ensure the model never speaks letter names ("Em", "Pee") instead of
///   pure phoneme sounds ("mmmm", "puh").
class GeminiTtsService {
  GeminiTtsService({required String apiKey}) : _apiKey = apiKey {
    if (apiKey.isEmpty) {
      debugPrint(
        '[GeminiTTS] WARNING: GEMINI_API_KEY is empty. '
        'Run with --dart-define=GEMINI_API_KEY=your_key. '
        'All TTS calls will fail until a key is supplied.',
      );
    }
  }

  final String _apiKey;

  static const String _model = 'gemini-2.5-flash-preview-tts';

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models'
      '/$_model:generateContent';

  /// Toddler-friendly, cheerful voice.
  static const String _voice = 'Puck';

  // PCM audio specs returned by the Gemini TTS endpoint.
  static const int _sampleRate    = 24000;
  static const int _numChannels   = 1;
  static const int _bitsPerSample = 16;

  // ── In-flight deduplication ────────────────────────────────────────────────
  // Prevents two concurrent callers (e.g. preload + speak) from both hitting
  // the API for the same text.  The second caller awaits the first's Future.

  final Map<String, Future<Uint8List>> _inFlight = {};

  // ── Hive vault (legacy, kept for migration) ────────────────────────────────

  Box<List<int>> get _vault => Hive.box<List<int>>('mave_audio_vault');

  String _hiveKey(String text) =>
      sha256.convert(utf8.encode('$_voice|$text')).toString();

  bool hasCached(String text) {
    final cleaned = _clean(text);
    return AudioCacheService.instance.has(_voice, cleaned) ||
        _vault.containsKey(_hiveKey(cleaned));
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns WAV bytes for [text].
  ///
  /// Check order:
  ///   1. File cache → instant, zero API call.
  ///   2. Hive vault → instant (legacy migration path).
  ///   3. Gemini TTS → decode PCM → wrap WAV → store everywhere → return.
  ///
  /// Text is sanitized through [PhoneticHelper.sanitize] to prevent letter
  /// names from reaching the TTS model.
  ///
  /// Throws [GeminiTtsException] on unrecoverable failure.
  Future<Uint8List> getAudioBytes(String text) async {
    if (_apiKey.isEmpty) {
      throw const GeminiTts403Exception(
        'GEMINI_API_KEY is not set — run with '
        '--dart-define=GEMINI_API_KEY=your_key',
      );
    }

    final cleaned  = _clean(PhoneticHelper.sanitize(text));
    if (cleaned.isEmpty) {
      throw GeminiTtsException('Text empty after cleaning: "$text"');
    }

    // ── File cache hit ───────────────────────────────────────────────────────
    final fileCached = await AudioCacheService.instance.get(_voice, cleaned);
    if (fileCached != null) {
      debugPrint('[GeminiTTS] File cache hit: "${_preview(cleaned)}"');
      return fileCached;
    }

    // ── Hive vault hit (legacy) ──────────────────────────────────────────────
    final hiveKey    = _hiveKey(cleaned);
    final hiveCached = _vault.get(hiveKey);
    if (hiveCached != null) {
      debugPrint('[GeminiTTS] Hive vault hit (migrating to file): "${_preview(cleaned)}"');
      final bytes = Uint8List.fromList(hiveCached);
      // Promote to file cache so future reads skip Hive.
      await AudioCacheService.instance.put(_voice, cleaned, bytes);
      return bytes;
    }

    // ── API call (deduplicated) ───────────────────────────────────────────────
    // If another caller is already fetching the same text, reuse its Future.
    if (_inFlight.containsKey(cleaned)) {
      debugPrint('[GeminiTTS] Awaiting in-flight request for "${_preview(cleaned)}"');
      return _inFlight[cleaned]!;
    }

    // Very short strings (e.g. "pp", "aaa") cause Gemini TTS to return no
    // audio.  Wrap them in a natural carrier phrase so the model speaks them,
    // but cache under the original cleaned key so repeated calls stay fast.
    final toSynthesize = _needsCarrier(cleaned) ? 'Say: $cleaned' : cleaned;

    final future = _fetchAndCache(cleaned, hiveKey, toSynthesize);
    _inFlight[cleaned] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(cleaned);
    }
  }

  Future<Uint8List> _fetchAndCache(
      String cleaned, String hiveKey, String toSynthesize) async {
    debugPrint('[GeminiTTS] Synthesizing: "${_preview(cleaned)}"');
    final bytes = await _synthesize(toSynthesize);

    // Store in both caches.
    await AudioCacheService.instance.put(_voice, cleaned, bytes);
    await _vault.put(hiveKey, bytes.toList());

    debugPrint(
      '[GeminiTTS] Stored ${bytes.length} B for "${_preview(cleaned)}"',
    );
    return bytes;
  }

  // ── Synthesis ──────────────────────────────────────────────────────────────

  Future<Uint8List> _synthesize(String text) async {
    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': text},
                  ],
                },
              ],
              'generationConfig': {
                'responseModalities': ['AUDIO'],
                'speechConfig': {
                  'voiceConfig': {
                    'prebuiltVoiceConfig': {'voiceName': _voice},
                  },
                },
              },
            }),
          )
          .timeout(const Duration(seconds: 25));
    } on Exception catch (e) {
      throw GeminiTtsException('Network error: $e');
    }

    if (response.statusCode == 403) {
      final snippet = response.body.length > 200
          ? '${response.body.substring(0, 200)}…'
          : response.body;
      throw GeminiTts403Exception(
        'Gemini TTS 403 – check your API key and that the '
        'Generative Language API is enabled in Google Cloud. '
        'Detail: $snippet',
      );
    }

    if (response.statusCode != 200) {
      final snippet = response.body.length > 300
          ? '${response.body.substring(0, 300)}…'
          : response.body;
      throw GeminiTtsException(
          'Gemini TTS HTTP ${response.statusCode}: $snippet');
    }

    final body     = jsonDecode(response.body) as Map<String, dynamic>;
    final audioB64 = _extractAudio(body);

    if (audioB64 == null || audioB64.isEmpty) {
      throw GeminiTtsException(
          'Gemini TTS returned no audio for "${_preview(text)}"');
    }

    final pcmBytes = base64Decode(audioB64);
    final wavBytes = _wrapInWav(pcmBytes);

    debugPrint(
      '[GeminiTTS] OK — ${pcmBytes.length} B PCM → '
      '${wavBytes.length} B WAV · voice=$_voice',
    );
    return wavBytes;
  }

  // ── WAV header ─────────────────────────────────────────────────────────────

  /// Wraps raw [pcm] bytes in a standard 44-byte RIFF/WAV header.
  ///
  /// Parameters match Gemini TTS output exactly:
  ///   24 000 Hz · 16-bit · mono
  static Uint8List _wrapInWav(Uint8List pcm) {
    final dataSize   = pcm.length;
    final byteRate   = _sampleRate * _numChannels * _bitsPerSample ~/ 8;
    final blockAlign = _numChannels * _bitsPerSample ~/ 8;

    final header = ByteData(44)
      // RIFF descriptor
      ..setUint32(0,  0x52494646, Endian.big)    // 'RIFF'
      ..setUint32(4,  36 + dataSize, Endian.little)
      ..setUint32(8,  0x57415645, Endian.big)    // 'WAVE'
      // fmt sub-chunk
      ..setUint32(12, 0x666d7420, Endian.big)    // 'fmt '
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)           // PCM = 1
      ..setUint16(22, _numChannels, Endian.little)
      ..setUint32(24, _sampleRate, Endian.little)
      ..setUint32(28, byteRate, Endian.little)
      ..setUint16(32, blockAlign, Endian.little)
      ..setUint16(34, _bitsPerSample, Endian.little)
      // data sub-chunk
      ..setUint32(36, 0x64617461, Endian.big)    // 'data'
      ..setUint32(40, dataSize, Endian.little);

    final wav = Uint8List(44 + dataSize);
    wav.setRange(0,  44,            header.buffer.asUint8List());
    wav.setRange(44, 44 + dataSize, pcm);
    return wav;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String? _extractAudio(Map<String, dynamic> body) {
    try {
      final candidates = body['candidates'] as List<dynamic>;
      final parts      = candidates[0]['content']['parts'] as List<dynamic>;
      return parts[0]['inlineData']['data'] as String?;
    } catch (_) {
      return null;
    }
  }

  static String _clean(String text) =>
      text.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Returns true for strings that are too short / non-word-like for Gemini
  /// TTS to synthesize without a carrier phrase.  Anything under 8 chars that
  /// contains no space (i.e. a single token) tends to return empty audio.
  static bool _needsCarrier(String text) =>
      text.length < 8 && !text.contains(' ');

  String _preview(String t) =>
      t.length > 55 ? '${t.substring(0, 55)}…' : t;
}

// ── Exceptions ────────────────────────────────────────────────────────────────

class GeminiTtsException implements Exception {
  const GeminiTtsException(this.message);
  final String message;

  @override
  String toString() => 'GeminiTtsException: $message';
}

/// Thrown specifically on HTTP 403 / missing API key so callers can
/// distinguish an auth failure from a transient network error and enter
/// offline mode instead of retrying indefinitely.
class GeminiTts403Exception extends GeminiTtsException {
  const GeminiTts403Exception(super.message);

  @override
  String toString() => 'GeminiTts403Exception: $message';
}
