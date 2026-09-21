import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Wraps [AudioPlayer] and provides a method to play raw PCM bytes
/// received from Gemini (audio/pcm;rate=24000, 16-bit, mono).
///
/// On Darwin (macOS/iOS) and Android, audio bytes are written to a temp file
/// with a `.wav` extension before playback so that AVFoundation / MediaPlayer
/// can correctly detect the format.
///
/// File cleanup: the previous file is deleted at the START of the next play
/// call (not immediately after play() — play() resolves when playback begins,
/// not when it ends, so deleting right after would truncate the stream).
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  // Buffer to accumulate PCM chunks before playback
  final List<int> _pcmBuffer = [];
  Timer? _flushTimer;
  int _playCount = 0;
  String? _prevPath; // path of the previously played file, safe to delete next call

  AudioPlayerService() {
    // ── Diagnostic logging ──────────────────────────────────────────────────
    _player.onPlayerStateChanged.listen((state) {
      debugPrint('[AudioPlayer] state → $state');
    });
    _player.onLog.listen((msg) {
      debugPrint('[AudioPlayer] log: $msg');
    });
    _player.onPositionChanged.listen((pos) {
      // Only log every 500 ms to avoid spam
      if (pos.inMilliseconds % 500 < 50) {
        debugPrint('[AudioPlayer] position: ${pos.inMilliseconds} ms');
      }
    });
    _player.onPlayerComplete.listen((_) {
      debugPrint('[AudioPlayer] COMPLETE');
    });
  }

  void feedPcmChunk(Uint8List chunk) {
    debugPrint('[AudioPlayer] feedPcmChunk: ${chunk.length} bytes');
    _pcmBuffer.addAll(chunk);
    // Debounce: flush after 300 ms of inactivity (turn complete)
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(milliseconds: 300), _flush);
  }

  Future<void> _flush() async {
    if (_pcmBuffer.isEmpty) return;
    debugPrint('[AudioPlayer] flush: ${_pcmBuffer.length} bytes → building WAV');
    final wav = _buildWav(Uint8List.fromList(_pcmBuffer), sampleRate: 24000);
    _pcmBuffer.clear();
    await _playWavBytes(wav);
  }

  /// Immediately play a WAV built from raw PCM bytes.
  Future<void> playPcm(Uint8List pcm, {int sampleRate = 24000}) async {
    final wav = _buildWav(pcm, sampleRate: sampleRate);
    await _playWavBytes(wav);
  }

  /// Play a simple synthesised "pop" sound effect (200 Hz, 0.1 s).
  Future<void> playPop() async {
    debugPrint('[AudioPlayer] playPop()');
    final wav = _buildPopWav();
    await _playWavBytes(wav);
  }

  /// Play a low "thump" sound (80 Hz, 0.2 s) for wrong-letter feedback.
  Future<void> playThump() async {
    debugPrint('[AudioPlayer] playThump()');
    final wav = _buildThumpWav();
    await _playWavBytes(wav);
  }

  /// Plays WAV bytes.
  /// On native platforms, writes to a temp `.wav` file first so that
  /// AVFoundation / Android MediaPlayer detect the format correctly.
  /// On web, uses in-memory [BytesSource] (no file system available).
  ///
  /// The PREVIOUS temp file is deleted at the start of each call so that
  /// we never delete a file that is still being streamed by AVFoundation.
  Future<void> _playWavBytes(Uint8List wav) async {
    if (kIsWeb) {
      await _player.play(BytesSource(wav));
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/mave_audio_${_playCount++}.wav';

    // Delete the PREVIOUS file (it's done playing by the time we get here).
    if (_prevPath != null) {
      _cleanOldFile(_prevPath!);
    }

    debugPrint('[AudioPlayer] writing WAV: ${wav.length} bytes → $path');
    final file = File(path);
    await file.writeAsBytes(wav, flush: true);

    // 100 ms ensures the OS has fully flushed the file before AVFoundation opens it.
    await Future.delayed(const Duration(milliseconds: 100));

    debugPrint('[AudioPlayer] calling play() on $path');
    _prevPath = path;
    await _player.play(DeviceFileSource(path));
    // DO NOT delete here — play() resolves when playback starts, not ends.
    // _prevPath will be cleaned on the next call to _playWavBytes.
  }

  void _cleanOldFile(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) {
        f.deleteSync();
        debugPrint('[AudioPlayer] deleted temp file: $path');
      }
    } catch (e) {
      debugPrint('[AudioPlayer] cleanup error: $e');
    }
  }

  Future<void> stop() async => _player.stop();

  void dispose() {
    _flushTimer?.cancel();
    if (_prevPath != null) _cleanOldFile(_prevPath!);
    _player.dispose();
  }

  // ---------------------------------------------------------------------------
  // WAV helpers
  // ---------------------------------------------------------------------------

  static Uint8List _buildWav(
    Uint8List pcmData, {
    int sampleRate = 24000,
    int channels = 1,
    int bitDepth = 16,
  }) {
    final dataSize = pcmData.length;
    final byteRate = sampleRate * channels * bitDepth ~/ 8;
    final blockAlign = channels * bitDepth ~/ 8;
    final header = ByteData(44);

    // RIFF chunk
    _writeString(header, 0, 'RIFF');
    header.setUint32(4, 36 + dataSize, Endian.little);
    _writeString(header, 8, 'WAVE');

    // fmt sub-chunk
    _writeString(header, 12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // sub-chunk size
    header.setUint16(20, 1, Endian.little); // PCM = 1
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitDepth, Endian.little);

    // data sub-chunk
    _writeString(header, 36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    final result = Uint8List(44 + dataSize);
    result.setAll(0, header.buffer.asUint8List());
    result.setAll(44, pcmData);
    return result;
  }

  static void _writeString(ByteData bd, int offset, String s) {
    for (int i = 0; i < s.length; i++) {
      bd.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  /// Generate a short 200 Hz sine-wave pop (0.1 s, 44100 Hz, 16-bit mono).
  static Uint8List _buildPopWav() {
    const int sr = 44100;
    const double dur = 0.1;
    const double freq = 200.0;
    final int numSamples = (sr * dur).round();
    final pcm = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      final t = i / sr;
      final envelope = 1.0 - (i / numSamples);
      pcm[i] = (32767 * envelope * _sin(2 * 3.14159 * freq * t)).round();
    }
    return _buildWav(pcm.buffer.asUint8List(), sampleRate: sr);
  }

  /// Generate a short 80 Hz sine-wave thump (0.2 s, 44100 Hz, 16-bit mono).
  static Uint8List _buildThumpWav() {
    const int sr = 44100;
    const double dur = 0.2;
    const double freq = 80.0;
    final int numSamples = (sr * dur).round();
    final pcm = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      final t = i / sr;
      final envelope = 1.0 - (i / numSamples);
      pcm[i] = (32767 * envelope * _sin(2 * 3.14159 * freq * t)).round();
    }
    return _buildWav(pcm.buffer.asUint8List(), sampleRate: sr);
  }

  static double _sin(double x) => _dartSin(x);

  static double _dartSin(double x) {
    // Normalise x into [-π, π]
    const pi = 3.14159265358979;
    x = x % (2 * pi);
    if (x > pi) x -= 2 * pi;
    // Bhaskara I approximation
    final x2 = x * x;
    return x * (pi * pi - 4 * x2) / (pi * pi + x2 * (1 - 4 / (pi * pi)));
  }
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final svc = AudioPlayerService();
  ref.onDispose(svc.dispose);
  return svc;
});
