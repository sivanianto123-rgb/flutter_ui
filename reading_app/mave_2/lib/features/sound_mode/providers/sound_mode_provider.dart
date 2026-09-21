import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/models/milestone_model.dart';
import '../../../core/models/story_page.dart';
import '../../../core/services/app_providers.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/data_service.dart';

enum SoundLevel { level1, level2, level3, level4, level5, level6, level7, level8, level9, level10, level11 }

/// Which phoneme is currently being spoken — used by Level 1 to
/// animate individual letters in sync with TTS playback.
enum PlayingPhase { idle, full, consonant, vowel }

class SoundModeState {
  const SoundModeState({
    required this.syllable,
    required this.currentLevel,
    this.isPlaying = false,
    this.levelComplete = false,
    this.audioReady = false,
    this.playingPhase = PlayingPhase.idle,
    this.storyPages = const [],
  });

  final String syllable;
  final SoundLevel currentLevel;
  final bool isPlaying;
  final bool levelComplete;

  /// True once the level's primary audio has finished — this is when the
  /// Next button becomes visible.
  final bool audioReady;

  /// Tracks which phoneme is currently speaking for the L1 letter animation.
  final PlayingPhase playingPhase;

  /// Populated asynchronously when the story screen is reached.
  /// Empty list = still loading.
  final List<StoryPage> storyPages;

  SoundModeState copyWith({
    String? syllable,
    SoundLevel? currentLevel,
    bool? isPlaying,
    bool? levelComplete,
    bool? audioReady,
    PlayingPhase? playingPhase,
    List<StoryPage>? storyPages,
  }) {
    return SoundModeState(
      syllable: syllable ?? this.syllable,
      currentLevel: currentLevel ?? this.currentLevel,
      isPlaying: isPlaying ?? this.isPlaying,
      levelComplete: levelComplete ?? this.levelComplete,
      audioReady: audioReady ?? this.audioReady,
      playingPhase: playingPhase ?? this.playingPhase,
      storyPages: storyPages ?? this.storyPages,
    );
  }
}

class SoundModeNotifier extends StateNotifier<SoundModeState> {
  SoundModeNotifier(this._audio, this._data)
      : super(const SoundModeState(syllable: 'ma', currentLevel: SoundLevel.level1));

  final AudioService _audio;
  final DataService  _data;

  // ── Session metrics ────────────────────────────────────────────────────────
  // Accumulated across all three levels and flushed to DataService when the
  // final level completes.

  double   _vocalizationQuality  = 0.0; // set by recordVocalization()
  double   _visualAttention      = 0.0; // normalised 0–1 from level1 dwell time
  int      _totalTaps            = 0;   // all taps on level3
  int      _correctTaps          = 0;   // target-bubble taps on level3
  DateTime? _level1Start;               // set when intro starts

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Resets state for [syllable] synchronously so the UI can render
  /// immediately without waiting for any network calls.
  void initSync(String syllable) {
    _vocalizationQuality = 0.0;
    _visualAttention     = 0.0;
    _totalTaps           = 0;
    _correctTaps         = 0;
    _level1Start         = null;
    state = SoundModeState(syllable: syllable, currentLevel: SoundLevel.level1);
  }

  /// Warms the audio cache for [syllable] in the background.
  Future<void> preloadAudio(String syllable) async {
    try {
      await _audio.preload([
        _stretch(syllable),
        _stutter(syllable),
      ]);
    } catch (e) {
      debugPrint('[SoundMode] background preload error (non-fatal): $e');
    }
  }

  // ── Level 1: Listen & repeat ───────────────────────────────────────────────

  /// Plays the intro sequence for Level 1, updating [playingPhase] between
  /// each phrase so the UI can highlight the correct letter.
  Future<void> playIntroSequence() async {
    if (state.isPlaying) return;

    // Capture when the baby first hears the sound so we can measure attention.
    _level1Start ??= DateTime.now();

    state = state.copyWith(isPlaying: true, playingPhase: PlayingPhase.full);
    await _audio.speak(_stretch(state.syllable));
    await _audio.waitForCompletion();
    await Future.delayed(const Duration(milliseconds: 600));

    state = state.copyWith(playingPhase: PlayingPhase.consonant);
    await _audio.speak(_stutter(state.syllable));
    await _audio.waitForCompletion();
    await Future.delayed(const Duration(milliseconds: 400));

    state = state.copyWith(
      isPlaying: false,
      playingPhase: PlayingPhase.idle,
      audioReady: true,
    );
  }

  // ── Performance recording ──────────────────────────────────────────────────

  /// Called by Level 1 when the speech-to-text engine returns a result.
  ///
  /// Scores [recognizedWords] against the current syllable (0–1), stores the
  /// result, and triggers a Gemini TTS praise response calibrated to quality:
  ///   ≥ 0.7 → "You're doing great!"  (strong match)
  ///   < 0.7 → "Great job!"           (any attempt is rewarded)
  Future<void> recordVocalization(String recognizedWords) async {
    _vocalizationQuality = _scoreVocalization(recognizedWords, state.syllable);
    debugPrint(
      '[SoundMode] Vocalization quality for "${state.syllable}": '
      '${(_vocalizationQuality * 100).round()}% '
      '(recognized: "${recognizedWords.isEmpty ? '<sound only>' : recognizedWords}")',
    );

    final praise =
        _vocalizationQuality >= 0.7 ? "You're doing great!" : 'Great job!';
    _audio.speak(praise).ignore();
  }

  /// Scores a STT result against [target] using phoneme overlap.
  ///
  /// Returns 1.0 when [recognized] contains the target, scales down to
  /// partial credit for partially matching phonemes, and 0.0 for empty input.
  double _scoreVocalization(String recognized, String target) {
    final r = recognized.toLowerCase().trim();
    final t = target.toLowerCase().trim();
    if (r.isEmpty) return 0.0;
    if (r.contains(t)) return 1.0;
    // Partial credit: count matching characters.
    final targetChars = t.split('');
    final matched = targetChars.where(r.contains).length;
    return matched / targetChars.length;
  }

  /// Called by Level 3 for every bubble tap.
  ///
  /// [wasTarget] is true when the tapped bubble matches the current syllable.
  void recordTap({required bool wasTarget}) {
    _totalTaps++;
    if (wasTarget) _correctTaps++;
  }

  // ── Level progression ──────────────────────────────────────────────────────

  void markAudioReady() => state = state.copyWith(audioReady: true);

  /// Marks the current level complete and, for Level 1, records the attention
  /// duration. When the final level completes, flushes the full session to
  /// [DataService].
  void markLevelComplete() {
    // Measure visual attention as time from first sound to level 1 completion.
    if (state.currentLevel == SoundLevel.level1 && _level1Start != null) {
      final seconds =
          DateTime.now().difference(_level1Start!).inSeconds.toDouble();
      _visualAttention = (seconds / 120.0).clamp(0.0, 1.0);
      debugPrint(
        '[SoundMode] Visual attention: ${seconds.round()}s '
        '(normalised: ${(_visualAttention * 100).round()}%)',
      );
    }

    state = state.copyWith(levelComplete: true);

    // Flush the complete session when the final level finishes.
    if (state.currentLevel == SoundLevel.level11) {
      _saveSession();
    }
  }

  /// Advances to the next level and fires any async setup (story generation).
  Future<void> advanceLevel() async {
    final nextIndex =
        (state.currentLevel.index + 1).clamp(0, SoundLevel.values.length - 1);
    final next = SoundLevel.values[nextIndex];

    state = state.copyWith(
      currentLevel: next,
      levelComplete: false,
      audioReady: false,
      playingPhase: PlayingPhase.idle,
      storyPages: [],
    );

    if (next == SoundLevel.level10) {
      _generateStory();
    }
  }

  Future<void> _generateStory() async {
    state = state.copyWith(storyPages: StoryPage.forSyllable(state.syllable));
  }

  // ── Session persistence ────────────────────────────────────────────────────

  double get _motorPrecision =>
      _totalTaps == 0 ? 0.0 : (_correctTaps / _totalTaps).clamp(0.0, 1.0);

  void _saveSession() {
    final session = BabyDevelopment(
      vocalizationQuality: _vocalizationQuality,
      visualAttention: _visualAttention,
      motorPrecision: _motorPrecision,
      timestamp: DateTime.now(),
      syllable: state.syllable,
    );

    debugPrint(
      '[SoundMode] Saving session — '
      'vocalisation: ${(_vocalizationQuality * 100).round()}%, '
      'attention: ${(_visualAttention * 100).round()}%, '
      'motor: ${(_motorPrecision * 100).round()}%, '
      'mastery: ${(session.overallMastery * 100).round()}%',
    );

    _data.recordSession(session).catchError((Object e) {
      debugPrint('[SoundMode] Failed to save session: $e');
    });
  }

  // ── Phoneme helpers ────────────────────────────────────────────────────────

  /// Full syllable — spoken as a real word example the TTS will definitely produce.
  String _stretch(String s) {
    // Map each syllable to a word that starts with it and is toddler-friendly.
    const map = <String, String>{
      'ma': 'Mama!',
      'pa': 'Papa!',
      'ba': 'Baby!',
      'da': 'Dada!',
      'ta': 'Taco!',
      'na': 'Nana!',
      'sa': 'Safari!',
      'fa': 'Family!',
      'la': 'Lala!',
      'ra': 'Rainbow!',
    };
    return map[s.toLowerCase()] ?? '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}!';
  }

  /// Consonant sound — real repeated words with no commas so TTS always produces audio.
  String _stutter(String s) {
    const map = <String, String>{
      'm': 'Moo moo moo',
      'p': 'Puppy puppy puppy',
      'b': 'Baby baby baby',
      'd': 'Dada dada dada',
      't': 'Tummy tummy tummy',
      'n': 'Nana nana nana',
      's': 'Sun sun sun',
      'f': 'Fun fun fun',
      'l': 'La la la',
      'r': 'Roar roar roar',
    };
    return map[s[0].toLowerCase()] ?? 'La la la';
  }
}

final soundModeProvider =
    StateNotifierProvider<SoundModeNotifier, SoundModeState>((ref) {
  final audio = ref.watch(audioServiceProvider);
  final data  = ref.watch(dataServiceProvider);
  return SoundModeNotifier(audio, data);
});
