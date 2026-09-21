import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

/// Groq Speech API wrapper using the Orpheus TTS model.
///
/// Recitation sequence for every activity:
///   Step A — Title    : speak("[friendly] Learning the Ma sound!")
///   Step B — Story    : speak("[cheerful] Mama bear is looking for…")
///
/// The Groq Speech endpoint returns raw MP3 bytes directly in the response
/// body — no base64 decoding needed.  Bytes are stored as-is in the Hive vault
/// and served to just_audio via a [StreamAudioSource] with content-type
/// 'audio/mpeg'.
///
/// mave_audio_vault (Hive box of List of int):
///   Key   : SHA-256(cleaned text)
///   Value : raw MP3 bytes as List of int
///   On a vault hit the Groq API is NEVER called — zero latency, zero cost.
///   The vault survives app restarts and works fully offline.
class GroqTtsService {
  GroqTtsService({required String apiKey}) : _apiKey = apiKey;

  final String _apiKey;

  // ── Endpoint ───────────────────────────────────────────────────────────────

  static const String _url =
      'https://api.groq.com/openai/v1/audio/speech';

  /// Orpheus TTS model hosted on Groq.
  static const String _model = 'canopylabs/orpheus-v1-english';

  /// Warm, child-friendly Orpheus voice persona.
  static const String _voice = 'hannah';

  // ── Vocal direction tags ───────────────────────────────────────────────────

  /// Prepended to module titles ("Learning the Ma sound!").
  static const String _titleTag = '[friendly] ';

  /// Prepended to story text ("Mama bear is looking…").
  static const String _storyTag = '[cheerful] ';

  // ── Hive vault ─────────────────────────────────────────────────────────────

  Box<List<int>> get _vault => Hive.box<List<int>>('mave_audio_vault');

  String _cacheKey(String text) =>
      sha256.convert(utf8.encode(text)).toString();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns raw MP3 [Uint8List] for [text].
  ///
  /// Check order:
  ///   1. Hive vault hit → return immediately (zero API calls).
  ///   2. Call Groq Speech API → store result in vault → return bytes.
  ///
  /// Throws [GroqTtsException] when all retries are exhausted.
  Future<Uint8List> getAudioBytes(String text) async {
    final preparedText = _prepareText(text);
    final cleaned = _clean(preparedText);
    if (cleaned.isEmpty) {
      throw GroqTtsException('Text empty after cleaning: "$text"');
    }

    final key    = _cacheKey(cleaned);
    final cached = _vault.get(key);

    // ── Vault hit ────────────────────────────────────────────────────────────
    if (cached != null) {
      debugPrint('[GroqTTS] Vault hit for "${_preview(cleaned)}"');
      return Uint8List.fromList(cached);
    }

    // ── Vault miss: call API ─────────────────────────────────────────────────
    final bytes = await _synthesise(cleaned);
    await _vault.put(key, bytes.toList());
    debugPrint(
      '[GroqTTS] Stored ${bytes.length} B in vault for "${_preview(cleaned)}"',
    );
    return bytes;
  }

  /// Convenience wrapper for module titles — prepends [_titleTag].
  Future<Uint8List> getTitleAudioBytes(String title) =>
      getAudioBytes('$_titleTag$title');

  /// Convenience wrapper for story text — prepends [_storyTag].
  Future<Uint8List> getStoryAudioBytes(String story) =>
      getAudioBytes('$_storyTag$story');

  /// True when [text] (with its vocal-direction tag, if any) is already
  /// in the Hive vault.
  bool hasCached(String text) {
    final preparedText = _prepareText(text);
    return _vault.containsKey(_cacheKey(_clean(preparedText)));
  }

  // ── Synthesis ──────────────────────────────────────────────────────────────

  static const int _maxAttempts = 3;

  Future<Uint8List> _synthesise(String text) async {
    for (int attempt = 0; attempt < _maxAttempts; attempt++) {
      if (attempt > 0) {
        final wait = 1 << (attempt - 1); // 1 s, 2 s
        debugPrint(
          '[GroqTTS] Retry ${attempt + 1}/$_maxAttempts in ${wait}s '
          'for "${_preview(text)}"',
        );
        await Future.delayed(Duration(seconds: wait));
      }

      try {
        return await _singleRequest(text);
      } on _TransientError catch (e) {
        if (attempt == _maxAttempts - 1) {
          throw GroqTtsException(
              'Groq TTS server error after $_maxAttempts attempts: ${e.msg}');
        }
        debugPrint('[GroqTTS] Transient: ${e.msg} (attempt ${attempt + 1})');
      }
    }
    throw GroqTtsException(
        'All $_maxAttempts attempts failed for "${_preview(text)}".');
  }

  Future<Uint8List> _singleRequest(String text) async {
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_url),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type':  'application/json',
            },
            body: jsonEncode({
              'model':           _model,
              'voice':           _voice,
              'input':           text,
              'response_format': 'mp3',
            }),
          )
          .timeout(const Duration(seconds: 25));
    } on Exception catch (e) {
      throw _TransientError('Network error: $e');
    }

    if (response.statusCode >= 500) {
      throw _TransientError('HTTP ${response.statusCode}');
    }

    if (response.statusCode == 429) {
      throw _TransientError('Rate-limited (429) — backing off');
    }

    if (response.statusCode != 200) {
      final snippet = response.body.length > 300
          ? '${response.body.substring(0, 300)}…'
          : response.body;
      throw GroqTtsException(
          'Groq TTS ${response.statusCode}: $snippet');
    }

    // Groq Speech API returns raw MP3 bytes directly in the response body.
    final bytes = response.bodyBytes;
    if (bytes.isEmpty) {
      throw GroqTtsException(
          'Groq TTS returned empty body for "${_preview(text)}".');
    }

    debugPrint('[GroqTTS] OK — ${bytes.length} B MP3 for "${_preview(text)}"');
    return bytes;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _prepareText(String text) {
    var prepared = text.trim();
    if (!prepared.startsWith('[')) {
      prepared = '[cheerful] $prepared';
    }
    return prepared;
  }

  static String _clean(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

  String _preview(String t) => t.length > 60 ? '${t.substring(0, 60)}…' : t;
}

// ── Exceptions ────────────────────────────────────────────────────────────────

class GroqTtsException implements Exception {
  const GroqTtsException(this.message);
  final String message;

  @override
  String toString() => 'GroqTtsException: $message';
}

class _TransientError implements Exception {
  const _TransientError(this.msg);
  final String msg;
}
