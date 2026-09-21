/// Descriptor for a single mini-game activity within a sound node session.
class GameActivity {
  const GameActivity({
    required this.id,
    required this.title,
    required this.syllable,
    this.prerequisites    = const [],
    this.unlockThreshold  = 0.7,
  });

  final String       id;
  final String       title;
  final String       syllable;
  final List<String> prerequisites;
  final double       unlockThreshold;

  // ── Phase 1 activity catalogue ────────────────────────────────────────────

  static const List<GameActivity> all = [
    // Ma track
    GameActivity(id: 'ma_listen',      title: 'Listen & Watch',       syllable: 'ma'),
    GameActivity(id: 'ma_feed_monster',title: 'Feed the Monster',      syllable: 'ma', prerequisites: ['ma_listen'],       unlockThreshold: 0.6),
    GameActivity(id: 'ma_bubble_hunt', title: 'Bubble Hunt',           syllable: 'ma', prerequisites: ['ma_feed_monster'], unlockThreshold: 0.6),
    GameActivity(id: 'ma_sound_trace', title: 'Sound Tracing',         syllable: 'ma', prerequisites: ['ma_bubble_hunt'],  unlockThreshold: 0.6),
    GameActivity(id: 'ma_echo_animal', title: 'Echo the Animal',       syllable: 'ma', prerequisites: ['ma_sound_trace'],  unlockThreshold: 0.6),
    GameActivity(id: 'ma_tap_grow',    title: 'Tap & Grow',            syllable: 'ma', prerequisites: ['ma_echo_animal'],  unlockThreshold: 0.6),
    GameActivity(id: 'ma_door',        title: "Who's Behind the Door", syllable: 'ma', prerequisites: ['ma_tap_grow'],     unlockThreshold: 0.6),
    GameActivity(id: 'ma_train',       title: 'Phoneme Train',         syllable: 'ma', prerequisites: ['ma_door'],         unlockThreshold: 0.6),
    GameActivity(id: 'ma_storybook',   title: 'Storybook',             syllable: 'ma', prerequisites: ['ma_train'],        unlockThreshold: 0.6),
    GameActivity(id: 'ma_word_read',   title: 'Word Reading',          syllable: 'ma', prerequisites: ['ma_storybook'],    unlockThreshold: 0.6),

    // Pa track
    GameActivity(id: 'pa_listen',      title: 'Listen & Watch',       syllable: 'pa'),
    GameActivity(id: 'pa_feed_monster',title: 'Feed the Monster',      syllable: 'pa', prerequisites: ['pa_listen'],       unlockThreshold: 0.6),
    GameActivity(id: 'pa_bubble_hunt', title: 'Bubble Hunt',           syllable: 'pa', prerequisites: ['pa_feed_monster'], unlockThreshold: 0.6),
    GameActivity(id: 'pa_sound_trace', title: 'Sound Tracing',         syllable: 'pa', prerequisites: ['pa_bubble_hunt'],  unlockThreshold: 0.6),
    GameActivity(id: 'pa_echo_animal', title: 'Echo the Animal',       syllable: 'pa', prerequisites: ['pa_sound_trace'],  unlockThreshold: 0.6),
    GameActivity(id: 'pa_tap_grow',    title: 'Tap & Grow',            syllable: 'pa', prerequisites: ['pa_echo_animal'],  unlockThreshold: 0.6),
    GameActivity(id: 'pa_door',        title: "Who's Behind the Door", syllable: 'pa', prerequisites: ['pa_tap_grow'],     unlockThreshold: 0.6),
    GameActivity(id: 'pa_train',       title: 'Phoneme Train',         syllable: 'pa', prerequisites: ['pa_door'],         unlockThreshold: 0.6),
    GameActivity(id: 'pa_storybook',   title: 'Storybook',             syllable: 'pa', prerequisites: ['pa_train'],        unlockThreshold: 0.6),
    GameActivity(id: 'pa_word_read',   title: 'Word Reading',          syllable: 'pa', prerequisites: ['pa_storybook'],    unlockThreshold: 0.6),
  ];

  static List<GameActivity> get maActivities =>
      all.where((a) => a.syllable == 'ma').toList();

  static List<GameActivity> get paActivities =>
      all.where((a) => a.syllable == 'pa').toList();

  static GameActivity? byId(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
