import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mave_state.dart';
import '../services/gemini_live_service.dart';
import '../services/audio_player_service.dart';
import '../services/hive_service.dart';

export 'mave_state.dart';

// ---------------------------------------------------------------------------
// Mave NPC state
// ---------------------------------------------------------------------------

final maveStateProvider = StateProvider<MaveState>((ref) => MaveState.idle);

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------

final progressProvider = StateNotifierProvider<ProgressNotifier, double>((ref) {
  return ProgressNotifier(ref.read(hiveServiceProvider));
});

class ProgressNotifier extends StateNotifier<double> {
  final HiveService _hive;

  ProgressNotifier(this._hive) : super(_hive.progressPercent);

  Future<void> markComplete(int levelIndex) async {
    await _hive.markLevelComplete(levelIndex);
    state = _hive.progressPercent;
  }

  void refresh() {
    state = _hive.progressPercent;
  }
}

// ---------------------------------------------------------------------------
// Touch tracking for Mave's eye gaze
// ---------------------------------------------------------------------------

final touchPositionProvider = StateProvider<(double, double)>((ref) => (0.5, 0.5));

// ---------------------------------------------------------------------------
// Gemini connection status
// ---------------------------------------------------------------------------

final geminiConnectedProvider = StateProvider<bool>((ref) => false);

// ---------------------------------------------------------------------------
// GeminiController — connects the service, wires NPC state & audio globally
// ---------------------------------------------------------------------------

final geminiControllerProvider = Provider<GeminiController>((ref) {
  final ctrl = GeminiController(ref);
  ref.onDispose(ctrl.dispose);
  return ctrl;
});

class GeminiController {
  final Ref _ref;
  StreamSubscription<MaveState>? _npcSub;
  StreamSubscription<Uint8List>? _audioSub;

  GeminiController(this._ref);

  GeminiLiveService get _gemini => _ref.read(geminiServiceProvider);

  /// Connect to Gemini, wire global audio routing and NPC state, then greet.
  Future<void> connect(String apiKey) async {
    _gemini.init(apiKey);
    await _gemini.connect();

    if (_gemini.isReady) {
      _ref.read(geminiConnectedProvider.notifier).state = true;
    }

    // Route all Gemini audio output to the player — no per-level wiring needed.
    _audioSub?.cancel();
    _audioSub = _gemini.audioOutput.listen(
      _ref.read(audioPlayerServiceProvider).feedPcmChunk,
    );

    // Sync NPC animation state from server events (speaking / idle).
    _npcSub?.cancel();
    _npcSub = _gemini.npcStateEvents.listen((state) {
      _ref.read(maveStateProvider.notifier).state = state;
    });

    // Mave's greeting — the first voice heard when the app starts.
    if (_gemini.isReady) {
      _ref.read(maveStateProvider.notifier).state = MaveState.speaking;
      await _gemini.speak("Hi! I'm Mave! Let's learn to read!");
    }
  }

  Future<void> speak(String text) async {
    _ref.read(maveStateProvider.notifier).state = MaveState.speaking;
    await _gemini.speak(text);
  }

  Future<void> disconnect() async {
    await _gemini.disconnect();
    _ref.read(geminiConnectedProvider.notifier).state = false;
  }

  void dispose() {
    _npcSub?.cancel();
    _audioSub?.cancel();
    disconnect();
  }
}
