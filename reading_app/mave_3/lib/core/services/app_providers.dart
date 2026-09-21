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
import 'sound_score_service.dart';

export '../controllers/microphone_controller.dart' show MicrophoneController;
export '../providers/level_provider.dart'
    show
        levelProvider,
        activityAccuracyProvider,
        activityStatusProvider,
        ActivityStatus,
        LevelState,
        kActivityScoresBox;

// ── TTS ───────────────────────────────────────────────────────────────────────

final geminiTtsServiceProvider = Provider<GeminiTtsService>((ref) {
  return GeminiTtsService(apiKey: Env.geminiApiKey);
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(tts: ref.watch(geminiTtsServiceProvider));
  ref.onDispose(service.dispose);
  return service;
});

// ── Activity Generator ────────────────────────────────────────────────────────

final geminiActivityServiceProvider = Provider<GeminiActivityService>((ref) {
  return GeminiActivityService(apiKey: Env.geminiApiKey);
});

// ── Sound Scores ──────────────────────────────────────────────────────────────

final soundScoreServiceProvider = Provider<SoundScoreService>((ref) {
  return SoundScoreService();
});

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

final microphoneControllerProvider =
    ChangeNotifierProvider<MicrophoneController>((ref) {
  final controller = MicrophoneController();
  ref.onDispose(controller.dispose);
  return controller;
});

// ── Milestones ────────────────────────────────────────────────────────────────

final dataServiceProvider = Provider<DataService>((ref) => DataService());

final milestonesStreamProvider = StreamProvider<List<BabyDevelopment>>((ref) {
  return ref.watch(dataServiceProvider).streamMilestones();
});

// ── Profile ───────────────────────────────────────────────────────────────────

final profileBoxProvider = Provider<Box<ChildProfile>>((ref) {
  return Hive.box<ChildProfile>('profiles');
});

final childProfileProvider =
    StateNotifierProvider<ChildProfileNotifier, ChildProfile?>((ref) {
  return ChildProfileNotifier(ref.watch(profileBoxProvider));
});

class ChildProfileNotifier extends StateNotifier<ChildProfile?> {
  ChildProfileNotifier(this._box) : super(null) {
    if (_box.isNotEmpty) state = _box.getAt(0);
  }

  final Box<ChildProfile> _box;

  Future<void> createProfile(String name, String parentEmail) async {
    final profile = ChildProfile(name: name, parentEmail: parentEmail);
    await _box.clear();
    await _box.add(profile);
    state = profile;
  }

  void updateLevel(String syllable, int level) {
    state?.setLevelFor(syllable, level);
    state = state;
  }

  bool get hasProfile => state != null;
}
