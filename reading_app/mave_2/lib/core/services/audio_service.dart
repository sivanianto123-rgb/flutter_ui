import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'gemini_tts_service.dart';
import 'groq_tts_service.dart';

/// Audio engine backed by [GeminiTtsService].
///
/// Cache hierarchy (fastest → slowest):
///   1. Session in-memory cache — zero overhead for within-session repeats.
///   2. File cache / Hive vault (inside TTS) — zero API calls for cached phrases.
///   3. Gemini TTS API — called once per unique phrase, ever.
///
/// Offline mode:
///   A single [GeminiTts403Exception] permanently sets [isOffline] = true.
///   All subsequent [speak] calls become silent no-ops so the app never
///   enters a retry crash-loop. The UI should watch [offlineModeNotifier]
///   and show a one-time "Offline Mode — no audio" SnackBar.
class AudioService {
  AudioService({
    required GeminiTtsService tts,
    GroqTtsService? groqTts,
  })  : _tts = tts,
        _groqTts = groqTts;

  final GeminiTtsService _tts;
  final GroqTtsService? _groqTts;

  final AudioPlayer _player    = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  final Map<String, Uint8List> _sessionCache = {};

  // ── Offline mode ───────────────────────────────────────────────────────────

  bool get isOffline => _isOffline;
  bool _isOffline = false;

  /// Fires with a user-friendly message the first time a 403 is detected.
  /// Widgets add a listener and show a SnackBar; call [offlineModeNotifier]
  /// .removeListener in dispose.
  final ValueNotifier<String?> offlineModeNotifier = ValueNotifier(null);

  void _enterOfflineMode(String detail) {
    if (_isOffline) return; // only notify once
    _isOffline = true;
    const msg = 'Audio unavailable — check your API key or internet connection.';
    debugPrint('[AudioService] OFFLINE MODE: $detail');
    offlineModeNotifier.value = msg;
  }

  // ── Preloading ─────────────────────────────────────────────────────────────

  Future<Uint8List> _getAudioBytesWithFallback(String text) async {
    try {
      return await _tts.getAudioBytes(text);
    } on GeminiTtsException catch (e) {
      if (e.message.contains('429') && _groqTts != null) {
        debugPrint('[AudioService] Gemini TTS 429 Limit reached. Falling back to Groq...');
        return await _groqTts!.getAudioBytes(text);
      }
      rethrow;
    }
  }

  Future<void> preload(List<String> texts) async {
    for (final text in texts) {
      if (_isOffline || _sessionCache.containsKey(text)) continue;
      try {
        final alreadyVaulted = _tts.hasCached(text);
        final bytes          = await _getAudioBytesWithFallback(text);
        _sessionCache[text]  = bytes;
        if (!alreadyVaulted) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      } on GeminiTts403Exception catch (e) {
        _enterOfflineMode(e.message);
        return; // stop preloading — no point continuing
      } catch (e) {
        debugPrint('[AudioService] preload failed for "$text": $e');
      }
    }
  }

  // ── Playback ───────────────────────────────────────────────────────────────

  /// Speaks [text].  Silently returns if [isOffline].
  /// Never throws — all exceptions are caught and logged.
  Future<void> speak(String text) async {
    if (_isOffline) return;
    try {
      final bytes = _sessionCache[text] ?? await _getAudioBytesWithFallback(text);
      _sessionCache[text] = bytes;
      await _player.stop();
      await _player.setAudioSource(_MemoryAudioSource(bytes));
      await _player.seek(Duration.zero);
      await _player.play();
    } on GeminiTts403Exception catch (e) {
      _enterOfflineMode(e.message);
      // Do NOT rethrow — app continues in silent mode.
    } on GeminiTtsException catch (e) {
      debugPrint('[AudioService] TTS error for "$text": $e');
      // Transient failures are logged but do not crash the app.
    } catch (e) {
      debugPrint('[AudioService] Unexpected error for "$text": $e');
    }
  }

  Future<void> speakTitle(String title) => speak(title);
  Future<void> speakStory(String story) => speak(story);

  /// Plays each [text] in sequence with [gap] between items.
  Future<void> speakSequence(
    List<String> texts, {
    Duration gap = const Duration(milliseconds: 300),
  }) async {
    for (final text in texts) {
      if (_isOffline) return;
      await speak(text);
      await waitForCompletion();
      await Future.delayed(gap);
    }
  }

  /// Fire-and-forget sound effect.
  Future<void> playSfx(String text) async {
    if (_isOffline) return;
    try {
      final bytes = _sessionCache[text] ?? await _getAudioBytesWithFallback(text);
      _sessionCache[text] = bytes;
      await _sfxPlayer.stop();
      await _sfxPlayer.setAudioSource(_MemoryAudioSource(bytes));
      await _sfxPlayer.seek(Duration.zero);
      _sfxPlayer.play(); // intentionally not awaited
    } on GeminiTts403Exception catch (e) {
      _enterOfflineMode(e.message);
    } on GeminiTtsException catch (e) {
      debugPrint('[AudioService] playSfx error for "$text": $e');
    } catch (e) {
      debugPrint('[AudioService] playSfx unexpected error for "$text": $e');
    }
  }

  // ── State ──────────────────────────────────────────────────────────────────

  Future<void> waitForCompletion({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_isOffline) return;
    await _player.playerStateStream
        .firstWhere((s) => s.processingState == ProcessingState.completed)
        .timeout(
          timeout,
          onTimeout: () => PlayerState(false, ProcessingState.idle),
        );
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  bool get isPlaying {
    final s = _player.playerState;
    return s.playing &&
        s.processingState != ProcessingState.completed &&
        s.processingState != ProcessingState.idle;
  }

  Future<void> stop() async {
    await _player.stop();
    await _sfxPlayer.stop();
  }

  Future<void> dispose() async {
    offlineModeNotifier.dispose();
    await _player.dispose();
    await _sfxPlayer.dispose();
  }
}

// ── In-memory WAV source ──────────────────────────────────────────────────────

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
