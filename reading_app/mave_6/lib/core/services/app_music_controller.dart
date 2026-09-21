import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/app_settings_provider.dart';

class AppMusicController {
  AudioPlayer? _player;
  bool _started = false;
  bool _disabled = false;

  Future<void> start() async {
    if (_started || _disabled) return;
    if (Platform.isIOS) {
      _disableMusic('Skipping background music on iOS runtime');
      return;
    }
    _started = true;
    try {
      _player = AudioPlayer(playerId: 'app_music');
      await _player!
          .setReleaseMode(ReleaseMode.loop)
          .timeout(const Duration(seconds: 6));
      final wavBytes = _buildCheerfulWav();
      final tempDir = await getTemporaryDirectory();
      final wavFile = File('${tempDir.path}/mave_bg_music.wav');
      await wavFile
          .writeAsBytes(wavBytes, flush: true)
          .timeout(const Duration(seconds: 6));
      await _player!
          .setSource(DeviceFileSource(wavFile.path, mimeType: 'audio/wav'))
          .timeout(const Duration(seconds: 6));
      await _player!.resume().timeout(const Duration(seconds: 6));
    } on TimeoutException catch (e) {
      _disableMusic('Music init timeout: $e');
    } on MissingPluginException catch (e) {
      _disableMusic('Missing plugin: ${e.message}');
    } catch (e) {
      _disableMusic('Music init failed: $e');
    }
  }

  Future<void> syncSettings(AppSettings settings) async {
    if (_disabled) return;
    if (!_started) {
      await start();
    }
    if (_disabled || _player == null) return;
    final volume = settings.isMuted ? 0.0 : (settings.volume * 0.35);
    try {
      await _player!
          .setVolume(volume.clamp(0.0, 1.0))
          .timeout(const Duration(seconds: 4));
    } on TimeoutException catch (e) {
      _disableMusic('Music volume timeout: $e');
    } on MissingPluginException catch (e) {
      _disableMusic('Missing plugin while setting volume: ${e.message}');
    } catch (e) {
      _disableMusic('Music volume failed: $e');
    }
  }

  Future<void> dispose() async {
    if (_player != null) {
      await _player!.dispose();
    }
  }

  void _disableMusic(String reason) {
    _disabled = true;
    _started = false;
    _player = null;
    debugPrint('[AppMusicController] $reason');
  }

  List<int> _buildCheerfulWav() {
    const sampleRate = 22050;
    const seconds = 120;
    final frameCount = sampleRate * seconds;
    final pcm = Int16List(frameCount);

    // Long, gentle progression so the restart point is rarely audible.
    const melody = [
      261.63,
      329.63,
      392.00,
      329.63,
      293.66,
      349.23,
      440.00,
      349.23,
      329.63,
      392.00,
      493.88,
      392.00,
      261.63,
      329.63,
      392.00,
      329.63,
    ];
    const noteDuration = 1.25; // slower changes for calmer ambience

    for (var i = 0; i < frameCount; i++) {
      final t = i / sampleRate;
      final noteIndex = ((t / noteDuration).floor()) % melody.length;
      final freq = melody[noteIndex];
      final localT = t % noteDuration;
      final phraseT = (t % 16.0) / 16.0;
      final pulse = 0.75 + 0.25 * math.sin(2 * math.pi * phraseT);
      final fade = 0.82 + 0.18 * math.sin(math.pi * (localT / noteDuration));
      final sample = math.sin(2 * math.pi * freq * t) * fade * pulse * 0.18;
      pcm[i] = (sample * 32767).toInt();
    }

    final bytes = BytesBuilder();
    final dataSize = pcm.lengthInBytes;
    final fileSize = 36 + dataSize;

    void writeString(String v) => bytes.add(v.codeUnits);
    void write32(int v) {
      bytes.addByte(v & 0xFF);
      bytes.addByte((v >> 8) & 0xFF);
      bytes.addByte((v >> 16) & 0xFF);
      bytes.addByte((v >> 24) & 0xFF);
    }

    void write16(int v) {
      bytes.addByte(v & 0xFF);
      bytes.addByte((v >> 8) & 0xFF);
    }

    writeString('RIFF');
    write32(fileSize);
    writeString('WAVE');
    writeString('fmt ');
    write32(16);
    write16(1); // PCM
    write16(1); // mono
    write32(sampleRate);
    write32(sampleRate * 2); // byte rate
    write16(2); // block align
    write16(16); // bits
    writeString('data');
    write32(dataSize);
    bytes.add(pcm.buffer.asUint8List());
    return bytes.toBytes();
  }
}

final appMusicControllerProvider = Provider<AppMusicController>((ref) {
  final controller = AppMusicController();
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
