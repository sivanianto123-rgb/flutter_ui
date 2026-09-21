import 'package:flutter/foundation.dart';
import '../helpers/phonetic_helper.dart';

// ── Activity type enum ────────────────────────────────────────────────────────

/// Every unique game screen / mechanic in Mave.
enum ActivityType {
  // ── Single-sound activities (Ma or Pa) ────────────────────────────────────
  feedMonster,      // Drag bubbles to monster mouth
  soundMirror,      // Camera + echo recording (Phase 2 placeholder)
  syllablePop,      // Tap bubbles that match the target sound
  whosBehindDoor,   // Audio-visual matching: hear sound → open correct door
  phonemeTrain,     // Build words by connecting syllable wagons
  soundTracing,     // Bee flies across screen; mic amplitude drives progress
  danceOff,         // Rhythm game: Ma-Ba-Da patterns
  scavengerHunt,    // Find objects whose names start with target sound
  echoAnimal,       // Animal makes a sound; child echoes the matching phoneme
  tapAndGrow,       // Tap/hold to grow a plant (mic amplitude-driven)

  // ── Combo activities (Ma + Pa together) ───────────────────────────────────
  soundBridge,      // Step across bridge tiles: alternate Ma and Pa
  magneticSounds,   // Drag Ma/Pa magnets to attract matching pictures
  rhythmDrummer,    // Drum pads: tap correct sound for each beat
  soundPillar,      // Stack blocks labeled Ma/Pa in heard order
  photoReveal,      // Scratch-card: reveal image by saying correct sound
  soundCaterpillar, // Grow caterpillar segments by alternating Ma/Pa
  balloonSort,      // Sort Ma/Pa balloons into correct baskets
  soundSlide,       // Slide tiles to form Ma+Pa word patterns
  soundConversation,// Call-and-response dialogue using Ma and Pa
  bigBook,          // Storybook page-turn; child reads Ma/Pa words aloud
}

// ── Phase classification ──────────────────────────────────────────────────────

enum ActivityPhase {
  singleMa,    // Individual Ma sound activities
  singlePa,    // Individual Pa sound activities
  combo,       // Ma + Pa together
}

// ── Activity descriptor ───────────────────────────────────────────────────────

@immutable
class GameActivity {
  const GameActivity({
    required this.id,
    required this.type,
    required this.phase,
    required this.targetSounds,
    required this.displayTitle,
    required this.emoji,
    required this.description,
    this.unlockThreshold = 0.7,
    this.prerequisites = const [],
  });

  /// Unique identifier — stable across app versions (used as Hive/Firestore key).
  final String id;

  /// The game mechanic.
  final ActivityType type;

  /// Which curriculum phase this belongs to.
  final ActivityPhase phase;

  /// Phoneme(s) practised in this activity, e.g. ['ma'] or ['ma', 'pa'].
  final List<String> targetSounds;

  /// Human-readable name shown in the UI.
  final String displayTitle;

  /// Emoji badge for the activity tile.
  final String emoji;

  /// Short description for the parent dashboard.
  final String description;

  /// Accuracy threshold (0–1) that unlocks this activity.
  final double unlockThreshold;

  /// Activity IDs that must be completed before this one unlocks.
  final List<String> prerequisites;

  /// Phonetic version of all target sounds joined by "and".
  String get phoneticTargets =>
      targetSounds.map(PhoneticHelper.toPhonetic).join(' and ');

  // ── Full activity registry ─────────────────────────────────────────────────

  static const List<GameActivity> all = [
    // ── Ma activities (10) ───────────────────────────────────────────────────

    GameActivity(
      id: 'ma_feed_monster',
      type: ActivityType.feedMonster,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Feed the Monster',
      emoji: '👾',
      description: 'Drag the mmm-ah bubbles into the monster\'s mouth.',
    ),
    GameActivity(
      id: 'ma_sound_mirror',
      type: ActivityType.soundMirror,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Sound Mirror',
      emoji: '🪞',
      description: 'Watch yourself in the camera and echo the mmm-ah sound.',
      prerequisites: ['ma_feed_monster'],
    ),
    GameActivity(
      id: 'ma_syllable_pop',
      type: ActivityType.syllablePop,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Syllable Pop',
      emoji: '🫧',
      description: 'Pop only the bubbles that say mmm-ah!',
      prerequisites: ['ma_feed_monster'],
    ),
    GameActivity(
      id: 'ma_whos_behind_door',
      type: ActivityType.whosBehindDoor,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Who\'s Behind the Door?',
      emoji: '🚪',
      description: 'Listen to the sound and open the right door.',
      prerequisites: ['ma_syllable_pop'],
    ),
    GameActivity(
      id: 'ma_phoneme_train',
      type: ActivityType.phonemeTrain,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Phoneme Train',
      emoji: '🚂',
      description: 'Connect the mmm-ah wagons to build a word train.',
      prerequisites: ['ma_syllable_pop'],
    ),
    GameActivity(
      id: 'ma_sound_tracing',
      type: ActivityType.soundTracing,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Sound Tracing',
      emoji: '🐝',
      description: 'Keep saying mmm-ah to help the bee fly across!',
      prerequisites: ['ma_phoneme_train'],
    ),
    GameActivity(
      id: 'ma_dance_off',
      type: ActivityType.danceOff,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Dance Off',
      emoji: '🕺',
      description: 'Follow the mmm-ah rhythm and dance along!',
      prerequisites: ['ma_sound_tracing'],
    ),
    GameActivity(
      id: 'ma_scavenger_hunt',
      type: ActivityType.scavengerHunt,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Scavenger Hunt',
      emoji: '🔍',
      description: 'Find things around the room that start with mmm-ah.',
      prerequisites: ['ma_dance_off'],
    ),
    GameActivity(
      id: 'ma_echo_animal',
      type: ActivityType.echoAnimal,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Echo the Animal',
      emoji: '🐄',
      description: 'The animal says mmm-ah — now you say it back!',
      prerequisites: ['ma_scavenger_hunt'],
    ),
    GameActivity(
      id: 'ma_tap_grow',
      type: ActivityType.tapAndGrow,
      phase: ActivityPhase.singleMa,
      targetSounds: ['ma'],
      displayTitle: 'Tap & Grow',
      emoji: '🌱',
      description: 'Say mmm-ah to make the plant grow taller!',
      prerequisites: ['ma_echo_animal'],
      unlockThreshold: 0.9,
    ),

    // ── Pa activities (10) ───────────────────────────────────────────────────

    GameActivity(
      id: 'pa_feed_monster',
      type: ActivityType.feedMonster,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Feed the Monster',
      emoji: '👾',
      description: 'Drag the pah bubbles into the monster\'s mouth.',
    ),
    GameActivity(
      id: 'pa_sound_mirror',
      type: ActivityType.soundMirror,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Sound Mirror',
      emoji: '🪞',
      description: 'Watch yourself in the camera and echo the pah sound.',
      prerequisites: ['pa_feed_monster'],
    ),
    GameActivity(
      id: 'pa_syllable_pop',
      type: ActivityType.syllablePop,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Syllable Pop',
      emoji: '🫧',
      description: 'Pop only the bubbles that say pah!',
      prerequisites: ['pa_feed_monster'],
    ),
    GameActivity(
      id: 'pa_whos_behind_door',
      type: ActivityType.whosBehindDoor,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Who\'s Behind the Door?',
      emoji: '🚪',
      description: 'Listen to the sound and open the right door.',
      prerequisites: ['pa_syllable_pop'],
    ),
    GameActivity(
      id: 'pa_phoneme_train',
      type: ActivityType.phonemeTrain,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Phoneme Train',
      emoji: '🚂',
      description: 'Connect the pah wagons to build a word train.',
      prerequisites: ['pa_syllable_pop'],
    ),
    GameActivity(
      id: 'pa_sound_tracing',
      type: ActivityType.soundTracing,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Sound Tracing',
      emoji: '🐝',
      description: 'Keep saying pah to help the bee fly across!',
      prerequisites: ['pa_phoneme_train'],
    ),
    GameActivity(
      id: 'pa_dance_off',
      type: ActivityType.danceOff,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Dance Off',
      emoji: '🕺',
      description: 'Follow the pah rhythm and dance along!',
      prerequisites: ['pa_sound_tracing'],
    ),
    GameActivity(
      id: 'pa_scavenger_hunt',
      type: ActivityType.scavengerHunt,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Scavenger Hunt',
      emoji: '🔍',
      description: 'Find things around the room that start with pah.',
      prerequisites: ['pa_dance_off'],
    ),
    GameActivity(
      id: 'pa_echo_animal',
      type: ActivityType.echoAnimal,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Echo the Animal',
      emoji: '🦜',
      description: 'The animal says pah — now you say it back!',
      prerequisites: ['pa_scavenger_hunt'],
    ),
    GameActivity(
      id: 'pa_tap_grow',
      type: ActivityType.tapAndGrow,
      phase: ActivityPhase.singlePa,
      targetSounds: ['pa'],
      displayTitle: 'Tap & Grow',
      emoji: '🌱',
      description: 'Say pah to make the plant grow taller!',
      prerequisites: ['pa_echo_animal'],
      unlockThreshold: 0.9,
    ),

    // ── Combo activities: Ma + Pa (10) ────────────────────────────────────────
    //  Phase 1: Bridge + Magnet
    //  Phase 2: Drummer + Pillar
    //  Phase 3: Photo Reveal + Caterpillar
    //  Phase 4: Balloon Sort + Sound Slide
    //  Phase 5: Conversation + Big Book

    GameActivity(
      id: 'combo_sound_bridge',
      type: ActivityType.soundBridge,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Sound Bridge',
      emoji: '🌉',
      description: 'Step across bridge tiles by alternating mmm-ah and pah.',
      prerequisites: ['ma_tap_grow', 'pa_tap_grow'],
    ),
    GameActivity(
      id: 'combo_magnetic_sounds',
      type: ActivityType.magneticSounds,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Magnetic Sounds',
      emoji: '🧲',
      description: 'Drag mmm-ah and pah magnets to matching pictures.',
      prerequisites: ['combo_sound_bridge'],
    ),
    GameActivity(
      id: 'combo_rhythm_drummer',
      type: ActivityType.rhythmDrummer,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Rhythm Drummer',
      emoji: '🥁',
      description: 'Tap the correct drum pad for each mmm-ah or pah beat.',
      prerequisites: ['combo_magnetic_sounds'],
    ),
    GameActivity(
      id: 'combo_sound_pillar',
      type: ActivityType.soundPillar,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Sound Pillar',
      emoji: '🏛️',
      description: 'Stack mmm-ah and pah blocks in the order you hear them.',
      prerequisites: ['combo_rhythm_drummer'],
    ),
    GameActivity(
      id: 'combo_photo_reveal',
      type: ActivityType.photoReveal,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Photo Reveal',
      emoji: '📸',
      description: 'Scratch away tiles by saying the right sound to reveal a photo.',
      prerequisites: ['combo_sound_pillar'],
    ),
    GameActivity(
      id: 'combo_sound_caterpillar',
      type: ActivityType.soundCaterpillar,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Sound Caterpillar',
      emoji: '🐛',
      description: 'Grow the caterpillar by alternating mmm-ah and pah.',
      prerequisites: ['combo_photo_reveal'],
    ),
    GameActivity(
      id: 'combo_balloon_sort',
      type: ActivityType.balloonSort,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Balloon Sort',
      emoji: '🎈',
      description: 'Sort mmm-ah and pah balloons into their baskets.',
      prerequisites: ['combo_sound_caterpillar'],
    ),
    GameActivity(
      id: 'combo_sound_slide',
      type: ActivityType.soundSlide,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Sound Slide',
      emoji: '🎢',
      description: 'Slide tiles to form mmm-ah and pah word patterns.',
      prerequisites: ['combo_balloon_sort'],
    ),
    GameActivity(
      id: 'combo_conversation',
      type: ActivityType.soundConversation,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Sound Conversation',
      emoji: '💬',
      description: 'Have a call-and-response chat using mmm-ah and pah.',
      prerequisites: ['combo_sound_slide'],
    ),
    GameActivity(
      id: 'combo_big_book',
      type: ActivityType.bigBook,
      phase: ActivityPhase.combo,
      targetSounds: ['ma', 'pa'],
      displayTitle: 'Big Book',
      emoji: '📖',
      description: 'Turn the storybook pages by reading mmm-ah and pah words aloud.',
      prerequisites: ['combo_conversation'],
      unlockThreshold: 0.95,
    ),
  ];

  // ── Convenience look-ups ───────────────────────────────────────────────────

  static GameActivity? byId(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<GameActivity> forPhase(ActivityPhase phase) =>
      all.where((a) => a.phase == phase).toList();

  static List<GameActivity> get maActivities =>
      forPhase(ActivityPhase.singleMa);

  static List<GameActivity> get paActivities =>
      forPhase(ActivityPhase.singlePa);

  static List<GameActivity> get comboActivities =>
      forPhase(ActivityPhase.combo);
}
