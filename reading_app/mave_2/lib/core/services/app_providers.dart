import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../env/env.dart';
import '../controllers/microphone_controller.dart';
import '../hive/child_profile.dart';
import '../models/milestone_model.dart';
import '../models/sound_node.dart';
import 'audio_service.dart';
import 'data_service.dart';
import 'gemini_activity_service.dart';
import 'gemini_tts_service.dart';
import 'groq_tts_service.dart';
import 'sound_score_service.dart';

// Re-export for convenience so screens only need to import app_providers.dart.
export '../controllers/microphone_controller.dart' show MicrophoneController;
export '../providers/level_provider.dart'
    show
        levelProvider,
        activityAccuracyProvider,
        activityStatusProvider,
        ActivityStatus,
        LevelState,
        kActivityScoresBox;

// ── Gemini TTS ────────────────────────────────────────────────────────────────

/// gemini-2.5-flash-preview-tts — voice Kore, WAV output, Hive-vaulted.
/// Same API key as the activity generator — no second service needed.
final geminiTtsServiceProvider = Provider<GeminiTtsService>((ref) {
  return GeminiTtsService(apiKey: Env.geminiApiKey);
});

final groqTtsServiceProvider = Provider<GroqTtsService>((ref) {
  return GroqTtsService(apiKey: Env.groqApiKey);
});

/// Audio engine backed by [GeminiTtsService] with [GroqTtsService] fallback.
final audioServiceProvider = Provider<AudioService>((ref) {
  final tts     = ref.watch(geminiTtsServiceProvider);
  final groqTts = ref.watch(groqTtsServiceProvider);
  final service = AudioService(tts: tts, groqTts: groqTts);
  ref.onDispose(service.dispose);
  return service;
});

// ── Gemini Activity Generator ─────────────────────────────────────────────────

/// gemini-1.5-flash — generates {title, storyText, uiType} JSON per session.
final geminiActivityServiceProvider = Provider<GeminiActivityService>((ref) {
  return GeminiActivityService(apiKey: Env.geminiApiKey);
});

// ── Sound Scores ──────────────────────────────────────────────────────────────

/// Service that reads/writes per-sound rolling accuracy (Hive + Firestore).
final soundScoreServiceProvider = Provider<SoundScoreService>((ref) {
  return SoundScoreService();
});

/// Live accuracy map — updates after every game session.
/// Drives [SoundNode.statusFor] to compute lock/unlock state on the timeline.
final soundAccuracyProvider =
    StateNotifierProvider<SoundAccuracyNotifier, Map<String, double>>((ref) {
  final svc = ref.watch(soundScoreServiceProvider);
  return SoundAccuracyNotifier(svc);
});

class SoundAccuracyNotifier extends StateNotifier<Map<String, double>> {
  SoundAccuracyNotifier(this._svc) : super(_svc.allAccuracy());

  final SoundScoreService _svc;

  void record(String soundId, double accuracy) {
    _svc.record(soundId, accuracy);
    state = _svc.allAccuracy();
  }
}

// ── Microphone ────────────────────────────────────────────────────────────────

/// Session-scoped [MicrophoneController] backed by noise_meter.
final microphoneControllerProvider =
    ChangeNotifierProvider<MicrophoneController>((ref) {
  final controller = MicrophoneController();
  ref.onDispose(controller.dispose);
  return controller;
});

// ── Milestone data (Parent Dashboard) ─────────────────────────────────────────

final dataServiceProvider = Provider<DataService>((ref) => DataService());

final milestonesStreamProvider = StreamProvider<List<BabyDevelopment>>((ref) {
  return ref.watch(dataServiceProvider).streamMilestones();
});

// ── Hive Profile ──────────────────────────────────────────────────────────────

final profileBoxProvider = Provider<Box<ChildProfile>>((ref) {
  return Hive.box<ChildProfile>('profiles');
});

final childProfileProvider =
    StateNotifierProvider<ChildProfileNotifier, ChildProfile?>((ref) {
  final box = ref.watch(profileBoxProvider);
  return ChildProfileNotifier(box);
});

class ChildProfileNotifier extends StateNotifier<ChildProfile?> {
  ChildProfileNotifier(this._box) : super(null) {
    if (_box.isNotEmpty) state = _box.getAt(0);
  }

  final Box<ChildProfile> _box;

  Future<void> createProfile(String name, {String? parentEmail}) async {
    final profile = ChildProfile(name: name, parentEmail: parentEmail);
    await _box.clear();
    await _box.add(profile);
    state = profile;
  }

  void incrementLevel(String syllable, {int maxLevel = 3}) {
    final current = state?.getLevelFor(syllable) ?? 0;
    if (current >= maxLevel) return;
    state?.setLevelFor(syllable, current + 1);
    state = state;
  }

  void updateLevel(String syllable, int level) {
    state?.setLevelFor(syllable, level);
    state = state;
  }

  bool get hasProfile => state != null;
}
