import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class GroqTtsService {
  GroqTtsService({required String apiKey}) : _apiKey = apiKey;

  final String _apiKey;

  static const String _url   = 'https://api.groq.com/openai/v1/audio/speech';
  static const String _model = 'playai-tts';
  static const String _voice = 'Fritz-PlayAI';

  Box<List<int>> get _vault => Hive.box<List<int>>('mave_audio_vault');

  String _cacheKey(String text) =>
      sha256.convert(utf8.encode(text)).toString();

  Future<Uint8List> getAudioBytes(String text) async {
    final cleaned = _clean(text);
    final key     = _cacheKey(cleaned);
    final cached  = _vault.get(key);
    if (cached != null) return Uint8List.fromList(cached);

    final bytes = await _synthesize(cleaned);
    await _vault.put(key, bytes.toList());
    return bytes;
  }

  Future<Uint8List> _synthesize(String text) async {
    final response = await http
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
            'response_format': 'wav',
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 429) throw GroqTtsException('Rate-limited (429)');
    if (response.statusCode != 200) {
      debugPrint('[GroqTTS] HTTP ${response.statusCode} body: ${response.body}');
      throw GroqTtsException('Groq TTS HTTP ${response.statusCode}');
    }
    if (response.bodyBytes.isEmpty) throw GroqTtsException('Empty body');
    debugPrint('[GroqTTS] OK — ${response.bodyBytes.length} B');
    return response.bodyBytes;
  }

  static String _clean(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

class GroqTtsException implements Exception {
  const GroqTtsException(this.message);
  final String message;
  @override
  String toString() => 'GroqTtsException: $message';
}
