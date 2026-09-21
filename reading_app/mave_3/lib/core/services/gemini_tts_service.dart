import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../helpers/phonetic_helper.dart';
import 'audio_cache_service.dart';

class GeminiTtsService {
  GeminiTtsService({required String apiKey}) : _apiKey = apiKey;

  final String _apiKey;

  static const String _model   = 'gemini-2.5-flash-preview-tts';
  static const String _baseUrl  =
      'https://generativelanguage.googleapis.com/v1beta/models'
      '/$_model:generateContent';
  static const String _voice    = 'Puck';
  static const int _sampleRate  = 24000;
  static const int _numChannels = 1;
  static const int _bitsPerSample = 16;

  final Map<String, Future<Uint8List>> _inFlight = {};
  Box<List<int>> get _vault => Hive.box<List<int>>('mave_audio_vault');

  String _hiveKey(String text) =>
      sha256.convert(utf8.encode('$_voice|$text')).toString();

  bool hasCached(String text) {
    final cleaned = _clean(text);
    return AudioCacheService.instance.has(_voice, cleaned) ||
        _vault.containsKey(_hiveKey(cleaned));
  }

  Future<Uint8List> getAudioBytes(String text) async {
    if (_apiKey.isEmpty) {
      throw const GeminiTts403Exception('GEMINI_API_KEY is not set');
    }
    final cleaned = _clean(PhoneticHelper.sanitize(text));
    if (cleaned.isEmpty) throw GeminiTtsException('Empty text after cleaning');

    final fileCached = await AudioCacheService.instance.get(_voice, cleaned);
    if (fileCached != null) return fileCached;

    final hiveKey    = _hiveKey(cleaned);
    final hiveCached = _vault.get(hiveKey);
    if (hiveCached != null) {
      final bytes = Uint8List.fromList(hiveCached);
      await AudioCacheService.instance.put(_voice, cleaned, bytes);
      return bytes;
    }

    if (_inFlight.containsKey(cleaned)) return _inFlight[cleaned]!;

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
    final bytes = await _synthesize(toSynthesize);
    await AudioCacheService.instance.put(_voice, cleaned, bytes);
    await _vault.put(hiveKey, bytes.toList());
    return bytes;
  }

  Future<Uint8List> _synthesize(String text) async {
    const maxAttempts = 4;
    // Backoff delays: 2 s, 5 s, 12 s
    const backoff = [
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 12),
    ];

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [{'parts': [{'text': text}]}],
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

      if (response.statusCode == 200) {
        final body     = jsonDecode(response.body) as Map<String, dynamic>;
        final audioB64 = _extractAudio(body);
        if (audioB64 == null || audioB64.isEmpty) {
          throw GeminiTtsException('No audio in response');
        }
        return _wrapInWav(base64Decode(audioB64));
      }

      if (response.statusCode == 403) {
        throw GeminiTts403Exception('Gemini TTS 403: ${response.body}');
      }

      if (response.statusCode == 429) {
        final wait = attempt < backoff.length ? backoff[attempt] : backoff.last;
        debugPrint(
          '[GeminiTTS] 429 rate-limited — attempt ${attempt + 1}/$maxAttempts, '
          'retrying in ${wait.inSeconds}s…',
        );
        if (attempt < maxAttempts - 1) {
          await Future.delayed(wait);
          continue;
        }
        throw GeminiTtsException(
          'Gemini TTS rate-limited (429) after $maxAttempts attempts',
        );
      }

      throw GeminiTtsException('Gemini TTS HTTP ${response.statusCode}');
    }

    throw GeminiTtsException('Gemini TTS failed after $maxAttempts attempts');
  }

  static Uint8List _wrapInWav(Uint8List pcm) {
    final dataSize   = pcm.length;
    final byteRate   = _sampleRate * _numChannels * _bitsPerSample ~/ 8;
    final blockAlign = _numChannels * _bitsPerSample ~/ 8;

    final header = ByteData(44)
      ..setUint32(0, 0x52494646, Endian.big)
      ..setUint32(4, 36 + dataSize, Endian.little)
      ..setUint32(8, 0x57415645, Endian.big)
      ..setUint32(12, 0x666d7420, Endian.big)
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, _numChannels, Endian.little)
      ..setUint32(24, _sampleRate, Endian.little)
      ..setUint32(28, byteRate, Endian.little)
      ..setUint16(32, blockAlign, Endian.little)
      ..setUint16(34, _bitsPerSample, Endian.little)
      ..setUint32(36, 0x64617461, Endian.big)
      ..setUint32(40, dataSize, Endian.little);

    final wav = Uint8List(44 + dataSize);
    wav.setRange(0, 44, header.buffer.asUint8List());
    wav.setRange(44, 44 + dataSize, pcm);
    return wav;
  }

  static String? _extractAudio(Map<String, dynamic> body) {
    try {
      final candidates = body['candidates'] as List<dynamic>;
      final parts      = candidates[0]['content']['parts'] as List<dynamic>;
      return parts[0]['inlineData']['data'] as String?;
    } catch (_) {
      return null;
    }
  }

  static String _clean(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();
  static bool _needsCarrier(String text) => text.length < 8 && !text.contains(' ');
}

class GeminiTtsException implements Exception {
  const GeminiTtsException(this.message);
  final String message;
  @override
  String toString() => 'GeminiTtsException: $message';
}

class GeminiTts403Exception extends GeminiTtsException {
  const GeminiTts403Exception(super.message);
}
