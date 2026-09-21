/// Maps phonemes and syllables to child-friendly phonetic spellings.
///
/// The TTS model must NEVER say letter names ("Em", "Pee", "Bee").
/// It must always produce pure phonetic sounds ("mmm", "pah", "bah").
///
/// Usage:
///   PhoneticHelper.toPhonetic('Ma')  → 'mmm-ah'
///   PhoneticHelper.toPhonetic('Pa')  → 'pah'
///   PhoneticHelper.prompt('Ma')      → 'Say mmm-ah'
library;

class PhoneticHelper {
  PhoneticHelper._();

  /// Canonical phonetic spelling for each curriculum sound/syllable.
  static const Map<String, String> _phoneticMap = {
    // Single phonemes — pure consonant sounds
    'm': 'mmmm',
    'p': 'puh',
    'b': 'buh',
    'd': 'duh',
    'n': 'nnn',
    't': 'tuh',
    'k': 'kuh',
    'g': 'guh',
    's': 'ssss',
    'f': 'fff',
    'h': 'huh',
    'l': 'lll',
    'r': 'rrr',
    'w': 'wuh',
    'y': 'yuh',

    // CV syllables (Phase 1 Mave curriculum)
    'ma': 'mmm-ah',
    'pa': 'pah',
    'ba': 'bah',
    'da': 'dah',
    'na': 'nah',
    'ta': 'tah',
    'ka': 'kah',
    'ga': 'gah',
    'sa': 'sah',
    'fa': 'fah',
    'ha': 'hah',
    'la': 'lah',
    'ra': 'rah',
    'wa': 'wah',
    'ya': 'yah',

    // Combo labels
    'ma+pa': 'mmm-ah and pah',
    'ma pa': 'mmm-ah and pah',
    'ma_pa': 'mmm-ah and pah',
  };

  /// Returns the phonetic spelling for [sound] (case-insensitive).
  /// Falls back to the input unchanged if no mapping exists.
  static String toPhonetic(String sound) {
    final key = sound.toLowerCase().trim();
    return _phoneticMap[key] ?? sound;
  }

  /// Returns a prompt string like "Say mmm-ah" for use as TTS input.
  static String sayPrompt(String sound) => 'Say ${toPhonetic(sound)}';

  /// Returns "Great job saying mmm-ah!" praise.
  static String praiseFor(String sound) =>
      'Great job saying ${toPhonetic(sound)}!';

  /// Returns "Try saying mmm-ah" encouragement.
  static String tryPrompt(String sound) =>
      'Try saying ${toPhonetic(sound)}';

  /// Returns "Listen: mmm-ah" instruction.
  static String listenPrompt(String sound) =>
      'Listen. ${toPhonetic(sound)}';

  /// Returns "Now you say mmm-ah" turn-taking instruction.
  static String yourTurnPrompt(String sound) =>
      'Now you say ${toPhonetic(sound)}';

  /// Replaces bare letter-name tokens in [text] with their phonetic forms.
  ///
  /// Specifically guards against single uppercase letters (M, P, B…) that
  /// a language model might slip into generated text.
  static String sanitize(String text) {
    // Replace isolated uppercase single letters surrounded by word boundaries.
    return text.replaceAllMapped(
      RegExp(r'\b([A-Z])\b'),
      (m) {
        final letter = m.group(1)!.toLowerCase();
        return _phoneticMap[letter] ?? m.group(1)!;
      },
    );
  }
}
