class PhoneticHelper {
  PhoneticHelper._();

  static const Map<String, String> _phoneticMap = {
    'm': 'mmmm', 'p': 'puh', 'b': 'buh', 'd': 'duh', 'n': 'nnn',
    't': 'tuh', 'k': 'kuh', 'g': 'guh', 's': 'ssss', 'f': 'fff',
    'h': 'huh', 'l': 'lll', 'r': 'rrr', 'w': 'wuh', 'y': 'yuh',
    'ma': 'mmm-ah', 'pa': 'pah', 'ba': 'bah', 'da': 'dah', 'na': 'nah',
    'ta': 'tah', 'ka': 'kah', 'ga': 'gah', 'sa': 'sah', 'fa': 'fah',
    'ha': 'hah', 'la': 'lah', 'ra': 'rah', 'wa': 'wah', 'ya': 'yah',
    'ma+pa': 'mmm-ah and pah', 'ma_pa': 'mmm-ah and pah',
  };

  static String toPhonetic(String sound) =>
      _phoneticMap[sound.toLowerCase().trim()] ?? sound;

  static String sayPrompt(String sound)   => 'Say ${toPhonetic(sound)}';
  static String praiseFor(String sound)   => 'Great job saying ${toPhonetic(sound)}!';
  static String tryPrompt(String sound)   => 'Try saying ${toPhonetic(sound)}';
  static String listenPrompt(String sound)=> 'Listen. ${toPhonetic(sound)}';
  static String yourTurnPrompt(String sound) => 'Now you say ${toPhonetic(sound)}';

  static String sanitize(String text) {
    return text.replaceAllMapped(RegExp(r'\b([A-Z])\b'), (m) {
      final letter = m.group(1)!.toLowerCase();
      return _phoneticMap[letter] ?? m.group(1)!;
    });
  }
}
