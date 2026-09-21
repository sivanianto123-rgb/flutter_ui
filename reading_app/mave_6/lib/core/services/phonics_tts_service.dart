import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PhonicsTtsService {
  final AudioPlayer _player = AudioPlayer(playerId: 'phonics_tts_player');
  final Set<String> _supportedSounds = {
    'ba',
    'ma',
    'welcome',
    'great_job',
    'try_again',
  };
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _model = 'gemini-2.5-flash-preview-tts';
  static const String _voice = 'Aoede';
  final Map<String, Future<File?>> _inFlight = {};

  Uri get _ttsUri => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/'
    '$_model:generateContent?key=$_apiKey',
  );

  Future<String> _audioPathFor(String key) async {
    final dir = await getApplicationDocumentsDirectory();
    final hash = sha256
        .convert(utf8.encode('$_voice|$key|v2'))
        .toString()
        .substring(0, 12);
    return '${dir.path}/phonics_${key}_$hash.wav';
  }

  String _phraseFor(String key) {
    switch (key) {
      case 'welcome':
        return 'Welcome little star. Let us learn phonics sounds together.';
      case 'great_job':
        return 'Very good!';
      case 'try_again':
        return 'Try again, little star.';
      case 'ba':
        return 'bbb... aaa... ba!';
      default:
        return 'mmm... aaa... ma!';
    }
  }

  Future<File?> _ensureAudio(String key) async {
    if (_apiKey.isEmpty || !_supportedSounds.contains(key)) {
      debugPrint('[PhonicsTtsService] Missing key or unsupported sound: $key');
      return null;
    }
    final path = await _audioPathFor(key);
    final file = File(path);
    if (await file.exists() && await file.length() > 0) return file;

    if (_inFlight.containsKey(key)) return _inFlight[key]!;
    final future = _generateAndCache(key, file);
    _inFlight[key] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<File?> _generateAndCache(String key, File outFile) async {
    try {
      final response = await http
          .post(
            _ttsUri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': _phraseFor(key)},
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
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        debugPrint(
          '[PhonicsTtsService] Gemini TTS failed (${response.statusCode}): ${response.body}',
        );
        return null;
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final pcmB64 = _extractAudioData(json);
      if (pcmB64 == null || pcmB64.isEmpty) return null;
      final wav = _wrapPcmInWav(base64Decode(pcmB64));
      await outFile.writeAsBytes(wav, flush: true);
      return outFile;
    } catch (e) {
      debugPrint('[PhonicsTtsService] generate failed for $key: $e');
      return null;
    }
  }

  Future<void> playWelcome() async {
    await _playKey('welcome');
  }

  Future<void> playSound(String sound) async {
    await _playKey(sound.toLowerCase());
  }

  Future<void> playReadingIntro(String sound) async {
    final s = sound.toLowerCase();
    await _playDynamic('reading_intro_$s', 'Let us say $s. ${_phraseFor(s)}');
  }

  Future<void> playBubbleIntro(String sound) async {
    final s = sound.toLowerCase();
    await _playDynamic(
      'bubble_intro_$s',
      'Let us pop the $s bubble. Tap the $s sound!',
    );
  }

  Future<void> playBubblePrompt(String sound) async {
    final s = sound.toLowerCase();
    await _playDynamic('bubble_prompt_$s', 'Find $s. Tap $s now!');
  }

  Future<void> playPositiveFeedback() async {
    await _playKey('great_job');
  }

  Future<void> playTryAgainFeedback() async {
    await _playKey('try_again');
  }

  Future<void> playStoryIntro(String sound) async {
    final s = sound.toLowerCase();
    await _playDynamic(
      'story_intro_$s',
      'Story time. Listen and follow the $s sound in this story.',
    );
  }

  Future<double> playStoryLine(String text) async {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return 4.0;
    return _playDynamic('story_line_${_safeHash(cleaned)}', cleaned);
  }

  Future<void> _playKey(String key) async {
    final file = await _ensureAudio(key);
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      await _player.stop();
      await _player.play(BytesSource(bytes, mimeType: 'audio/wav'));
    } catch (e) {
      debugPrint('[PhonicsTtsService] play failed for $key: $e');
    }
  }

  Future<double> _playDynamic(String cacheKey, String phrase) async {
    if (_apiKey.isEmpty) return 0;
    final path = await _audioPathFor(cacheKey);
    final file = File(path);
    if (!(await file.exists() && await file.length() > 0)) {
      final generated = await _generateFromPhrase(cacheKey, phrase, file);
      if (generated == null) return 0;
    }
    try {
      final bytes = await file.readAsBytes();
      final seconds = _wavDurationSeconds(bytes);
      await _player.stop();
      await _player.play(BytesSource(bytes, mimeType: 'audio/wav'));
      return seconds;
    } catch (e) {
      debugPrint('[PhonicsTtsService] dynamic play failed for $cacheKey: $e');
      return 0;
    }
  }

  Future<File?> _generateFromPhrase(
    String key,
    String phrase,
    File outFile,
  ) async {
    if (_inFlight.containsKey(key)) return _inFlight[key]!;
    final future = () async {
      try {
        final response = await http
            .post(
              _ttsUri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': phrase},
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
            .timeout(const Duration(seconds: 20));
        if (response.statusCode != 200) {
          debugPrint(
            '[PhonicsTtsService] Gemini TTS dynamic failed (${response.statusCode}): ${response.body}',
          );
          return null;
        }
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final pcmB64 = _extractAudioData(json);
        if (pcmB64 == null || pcmB64.isEmpty) return null;
        final wav = _wrapPcmInWav(base64Decode(pcmB64));
        await outFile.writeAsBytes(wav, flush: true);
        return outFile;
      } catch (e) {
        debugPrint('[PhonicsTtsService] dynamic generate failed for $key: $e');
        return null;
      }
    }();
    _inFlight[key] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(key);
    }
  }

  String _safeHash(String input) =>
      sha256.convert(utf8.encode(input)).toString().substring(0, 12);

  double _wavDurationSeconds(Uint8List bytes) {
    if (bytes.length < 44) return 0;
    final data = ByteData.sublistView(bytes);
    final sampleRate = data.getUint32(24, Endian.little);
    final channels = data.getUint16(22, Endian.little);
    final bits = data.getUint16(34, Endian.little);
    final dataSize = data.getUint32(40, Endian.little);
    final bytesPerSecond = sampleRate * channels * (bits / 8);
    if (bytesPerSecond <= 0) return 0;
    return dataSize / bytesPerSecond;
  }

  static String? _extractAudioData(Map<String, dynamic> body) {
    try {
      final candidates = body['candidates'] as List<dynamic>;
      final parts = candidates.first['content']['parts'] as List<dynamic>;
      return parts.first['inlineData']['data'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Uint8List _wrapPcmInWav(Uint8List pcm) {
    const sampleRate = 24000;
    const channels = 1;
    const bitsPerSample = 16;
    final dataSize = pcm.length;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final header = ByteData(44)
      ..setUint32(0, 0x52494646, Endian.big)
      ..setUint32(4, 36 + dataSize, Endian.little)
      ..setUint32(8, 0x57415645, Endian.big)
      ..setUint32(12, 0x666d7420, Endian.big)
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little)
      ..setUint16(22, channels, Endian.little)
      ..setUint32(24, sampleRate, Endian.little)
      ..setUint32(28, byteRate, Endian.little)
      ..setUint16(32, blockAlign, Endian.little)
      ..setUint16(34, bitsPerSample, Endian.little)
      ..setUint32(36, 0x64617461, Endian.big)
      ..setUint32(40, dataSize, Endian.little);
    final wav = Uint8List(44 + dataSize);
    wav.setRange(0, 44, header.buffer.asUint8List());
    wav.setRange(44, 44 + dataSize, pcm);
    return wav;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

final phonicsTtsServiceProvider = Provider<PhonicsTtsService>((ref) {
  final service = PhonicsTtsService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
