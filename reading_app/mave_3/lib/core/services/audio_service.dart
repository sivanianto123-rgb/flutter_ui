import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'gemini_tts_service.dart';

class AudioService {
  AudioService({required GeminiTtsService tts}) : _tts = tts;

  final GeminiTtsService _tts;
  final AudioPlayer _player = AudioPlayer();
  final Map<String, Uint8List> _sessionCache = {};

  // Used by SoundModeScreen to show a SnackBar on auth errors
  final ValueNotifier<String?> offlineModeNotifier = ValueNotifier(null);

  // ── Preload ────────────────────────────────────────────────────────────────

  Future<void> preload(List<String> texts) async {
    for (final text in texts) {
      if (_sessionCache.containsKey(text)) continue;
      try {
        _sessionCache[text] = await _tts.getAudioBytes(text);
        // Respect Gemini TTS rate limits between preload requests
        await Future.delayed(const Duration(milliseconds: 800));
      } on GeminiTts403Exception catch (e) {
        debugPrint('[AudioService] preload 403 — check API key: $e');
        offlineModeNotifier.value =
            'TTS unavailable — verify your Gemini API key.';
        return; // stop preloading, key is invalid
      } catch (e) {
        debugPrint('[AudioService] preload failed for "$text": $e');
      }
    }
  }

  // ── Speak ──────────────────────────────────────────────────────────────────

  Future<void> speak(String text) async {
    try {
      final bytes =
          _sessionCache[text] ?? await _tts.getAudioBytes(text);
      _sessionCache[text] = bytes;
      await _player.stop();
      await _player.setAudioSource(_MemoryAudioSource(bytes));
      await _player.seek(Duration.zero);
      await _player.play();
      debugPrint('[AudioService] playing "${text.length > 30 ? text.substring(0, 30) : text}"');
    } on GeminiTts403Exception catch (e) {
      debugPrint('[AudioService] 403 — check Gemini API key: $e');
      offlineModeNotifier.value =
          'TTS unavailable — verify your Gemini API key.';
    } catch (e) {
      debugPrint('[AudioService] speak error for "$text": $e');
    }
  }

  // ── Sequence ───────────────────────────────────────────────────────────────

  Future<void> speakSequence(
    List<String> texts, {
    Duration gap = const Duration(milliseconds: 300),
  }) async {
    for (final text in texts) {
      await speak(text);
      await waitForCompletion();
      await Future.delayed(gap);
    }
  }

  // ── Playback control ───────────────────────────────────────────────────────

  Future<void> waitForCompletion({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    await _player.playerStateStream
        .firstWhere((s) => s.processingState == ProcessingState.completed)
        .timeout(
          timeout,
          onTimeout: () => PlayerState(false, ProcessingState.idle),
        );
  }

  bool get isPlaying {
    final s = _player.playerState;
    return s.playing &&
        s.processingState != ProcessingState.completed &&
        s.processingState != ProcessingState.idle;
  }

  Future<void> stop() async => _player.stop();

  Future<void> dispose() async {
    offlineModeNotifier.dispose();
    await _player.dispose();
  }
}

// ── In-memory audio source for just_audio ─────────────────────────────────

class _MemoryAudioSource extends StreamAudioSource {
  _MemoryAudioSource(this._bytes);
  final Uint8List _bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final from = start ?? 0;
    final to   = end   ?? _bytes.length;
    return StreamAudioResponse(
      sourceLength:  _bytes.length,
      contentLength: to - from,
      offset:        from,
      contentType:   'audio/wav',
      stream:        Stream.value(_bytes.sublist(from, to)),
    );
  }
}
