import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/models/milestone_model.dart';
import '../../../core/models/story_page.dart';
import '../../../core/services/app_providers.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/data_service.dart';

enum PlayingPhase { idle, full, consonant, vowel }

class SoundModeState {
  const SoundModeState({
    required this.syllable,
    this.isPlaying    = false,
    this.levelComplete= false,
    this.audioReady   = false,
    this.playingPhase = PlayingPhase.idle,
    this.storyPages   = const [],
  });

  final String         syllable;
  final bool           isPlaying;
  final bool           levelComplete;
  final bool           audioReady;
  final PlayingPhase   playingPhase;
  final List<StoryPage>storyPages;

  SoundModeState copyWith({
    String? syllable,
    bool? isPlaying,
    bool? levelComplete,
    bool? audioReady,
    PlayingPhase? playingPhase,
    List<StoryPage>? storyPages,
  }) => SoundModeState(
    syllable:      syllable      ?? this.syllable,
    isPlaying:     isPlaying     ?? this.isPlaying,
    levelComplete: levelComplete ?? this.levelComplete,
    audioReady:    audioReady    ?? this.audioReady,
    playingPhase:  playingPhase  ?? this.playingPhase,
    storyPages:    storyPages    ?? this.storyPages,
  );
}

class SoundModeNotifier extends StateNotifier<SoundModeState> {
  SoundModeNotifier(this._audio, this._data)
      : super(const SoundModeState(syllable: 'ma'));

  final AudioService _audio;
  final DataService  _data;

  double   _vocalizationQuality = 0.0;
  double   _visualAttention     = 0.0;
  int      _totalTaps           = 0;
  int      _correctTaps         = 0;
  DateTime?_level1Start;

  void initSync(String syllable) {
    _vocalizationQuality = 0.0;
    _visualAttention     = 0.0;
    _totalTaps           = 0;
    _correctTaps         = 0;
    _level1Start         = null;
    state = SoundModeState(syllable: syllable);
  }

  Future<void> preloadAudio(String syllable) async {
    try {
      await _audio.preload([_stretch(syllable), _stutter(syllable)]);
    } catch (e) {
      debugPrint('[SoundMode] Preload error (non-fatal): $e');
    }
  }

  Future<void> playIntroSequence() async {
    if (state.isPlaying) return;
    _level1Start ??= DateTime.now();

    state = state.copyWith(isPlaying: true, playingPhase: PlayingPhase.full);
    await _audio.speak(_stretch(state.syllable));
    await _audio.waitForCompletion();
    await Future.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(playingPhase: PlayingPhase.consonant);
    await _audio.speak(_stutter(state.syllable));
    await _audio.waitForCompletion();
    await Future.delayed(const Duration(milliseconds: 400));

    state = state.copyWith(isPlaying: false, playingPhase: PlayingPhase.idle, audioReady: true);
  }

  Future<void> recordVocalization(String recognizedWords) async {
    _vocalizationQuality = _scoreVocalization(recognizedWords, state.syllable);
    final praise = _vocalizationQuality >= 0.7 ? "You're doing great!" : 'Great job!';
    _audio.speak(praise).ignore();
  }

  double _scoreVocalization(String recognized, String target) {
    final r = recognized.toLowerCase().trim();
    final t = target.toLowerCase().trim();
    if (r.isEmpty) return 0.0;
    if (r.contains(t)) return 1.0;
    final matched = t.split('').where(r.contains).length;
    return matched / t.split('').length;
  }

  void recordTap({required bool wasTarget}) {
    _totalTaps++;
    if (wasTarget) _correctTaps++;
  }

  void markAudioReady() => state = state.copyWith(audioReady: true);

  void markLevelComplete() {
    if (_level1Start != null) {
      final secs = DateTime.now().difference(_level1Start!).inSeconds.toDouble();
      _visualAttention = (secs / 120.0).clamp(0.0, 1.0);
    }
    state = state.copyWith(levelComplete: true);
  }

  void advanceLevel() {
    state = state.copyWith(
      levelComplete: false,
      audioReady:    false,
      playingPhase:  PlayingPhase.idle,
      storyPages:    [],
    );
  }

  void generateStory() {
    state = state.copyWith(storyPages: StoryPage.forSyllable(state.syllable));
  }

  String _stretch(String s) {
    const map = {
      'ma': 'Mama!', 'pa': 'Papa!', 'ba': 'Baby!', 'da': 'Dada!',
      'ta': 'Taco!', 'na': 'Nana!', 'sa': 'Safari!',
    };
    return map[s.toLowerCase()] ?? '${s[0].toUpperCase()}${s.substring(1)}!';
  }

  String _stutter(String s) {
    const map = {
      'm': 'Moo moo moo', 'p': 'Puppy puppy puppy',
      'b': 'Baby baby baby', 'd': 'Dada dada dada',
    };
    return map[s[0].toLowerCase()] ?? 'La la la';
  }
}

final soundModeProvider =
    StateNotifierProvider<SoundModeNotifier, SoundModeState>((ref) {
  return SoundModeNotifier(
    ref.watch(audioServiceProvider),
    ref.watch(dataServiceProvider),
  );
});
