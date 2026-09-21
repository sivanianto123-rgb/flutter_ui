import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Persistent file-based audio cache.
///
/// Layout on disk:
///   {appDocDir}/mave_audio_cache/{sha256(voice|text)}.wav
///
/// Flow for each phrase:
///   1. Compute SHA-256 key from voice + text.
///   2. If the .wav file exists and is non-empty → return its bytes (zero API).
///   3. Otherwise store bytes supplied by caller and return them.
///
/// This supplements (and eventually replaces) the Hive vault approach, giving
/// true file-system persistence that survives Hive box schema changes and is
/// easier to inspect / purge during development.
class AudioCacheService {
  AudioCacheService._();

  static AudioCacheService? _instance;
  static AudioCacheService get instance {
    _instance ??= AudioCacheService._();
    return _instance!;
  }

  Directory? _cacheDir;

  /// Must be called once before any cache reads/writes (typically in main()).
  Future<void> init() async {
    final base = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${base.path}/mave_audio_cache');
    if (!_cacheDir!.existsSync()) {
      await _cacheDir!.create(recursive: true);
    }
    debugPrint('[AudioCache] Cache dir: ${_cacheDir!.path}');
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns cached WAV bytes for [voice]+[text], or null on a miss.
  ///
  /// If the cached file is found but is empty / corrupted it is deleted and
  /// null is returned so the caller can re-fetch from the API.
  Future<Uint8List?> get(String voice, String text) async {
    final file = _fileFor(voice, text);
    if (!file.existsSync()) return null;

    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        debugPrint('[AudioCache] Empty file — deleting: ${file.path}');
        await file.delete();
        return null;
      }
      debugPrint('[AudioCache] Hit: ${file.uri.pathSegments.last}');
      return bytes;
    } catch (e) {
      debugPrint('[AudioCache] Read error — deleting: $e');
      try { await file.delete(); } catch (_) {}
      return null;
    }
  }

  /// Stores [bytes] on disk for [voice]+[text].
  Future<void> put(String voice, String text, Uint8List bytes) async {
    final file = _fileFor(voice, text);
    try {
      await file.writeAsBytes(bytes, flush: true);
      debugPrint(
        '[AudioCache] Stored ${bytes.length} B → ${file.uri.pathSegments.last}',
      );
    } catch (e) {
      debugPrint('[AudioCache] Write error: $e');
    }
  }

  /// Returns true if a valid (non-empty) cache entry exists.
  bool has(String voice, String text) {
    final file = _fileFor(voice, text);
    return file.existsSync() && file.lengthSync() > 0;
  }

  /// Deletes all cached audio files (development helper).
  Future<void> clearAll() async {
    if (_cacheDir == null || !_cacheDir!.existsSync()) return;
    await for (final entity in _cacheDir!.list()) {
      if (entity is File) await entity.delete();
    }
    debugPrint('[AudioCache] Cache cleared.');
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  File _fileFor(String voice, String text) {
    assert(_cacheDir != null, 'AudioCacheService.init() was not called');
    final hash = sha256.convert(utf8.encode('$voice|$text')).toString();
    return File('${_cacheDir!.path}/$hash.wav');
  }
}
