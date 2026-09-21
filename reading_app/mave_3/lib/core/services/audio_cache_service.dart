import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class AudioCacheService {
  AudioCacheService._();

  static AudioCacheService? _instance;
  static AudioCacheService get instance {
    _instance ??= AudioCacheService._();
    return _instance!;
  }

  Directory? _cacheDir;

  Future<void> init() async {
    final base = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${base.path}/mave_audio_cache');
    if (!_cacheDir!.existsSync()) {
      await _cacheDir!.create(recursive: true);
    }
    debugPrint('[AudioCache] Cache dir: ${_cacheDir!.path}');
  }

  Future<Uint8List?> get(String voice, String text) async {
    final file = _fileFor(voice, text);
    if (!file.existsSync()) return null;
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) { await file.delete(); return null; }
      return bytes;
    } catch (e) {
      try { await file.delete(); } catch (_) {}
      return null;
    }
  }

  Future<void> put(String voice, String text, Uint8List bytes) async {
    final file = _fileFor(voice, text);
    try {
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint('[AudioCache] Write error: $e');
    }
  }

  bool has(String voice, String text) {
    final file = _fileFor(voice, text);
    return file.existsSync() && file.lengthSync() > 0;
  }

  File _fileFor(String voice, String text) {
    assert(_cacheDir != null, 'AudioCacheService.init() was not called');
    final hash = sha256.convert(utf8.encode('$voice|$text')).toString();
    return File('${_cacheDir!.path}/$hash.wav');
  }
}
