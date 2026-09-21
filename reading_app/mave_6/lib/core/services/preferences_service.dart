import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyName = 'child_name';
  static const _keyEmail = 'parent_email';
  static const _keyPendingAuthEmail = 'pending_auth_email';
  static const _keyReadingSessions = 'perf_reading_sessions';
  static const _keyBubbleCorrect = 'perf_bubble_correct';
  static const _keyBubbleTargetTotal = 'perf_bubble_target_total';
  static const _keyStorySessions = 'perf_story_sessions';
  static const _keyPhonicsSuccesses = 'perf_phonics_successes';
  static const _keyVowelZoneComplete = 'perf_vowel_zone_complete';
  static const _keyConsonantZoneComplete = 'perf_consonant_zone_complete';
  static const _keyWordCorrect = 'perf_word_correct';
  static const _keyWordTotal = 'perf_word_total';
  static const _keySentenceCorrect = 'perf_sentence_correct';
  static const _keySentenceTotal = 'perf_sentence_total';

  static Future<void> saveProfile(String name, {String? email}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyName, name);
      if (email != null && email.isNotEmpty) {
        await prefs.setString(_keyEmail, email);
      }
    } catch (_) {
      // Plugin not yet linked (e.g. first run before pod install) — ignore.
    }
  }

  static Future<({String? name, String? email})> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (
        name: prefs.getString(_keyName),
        email: prefs.getString(_keyEmail),
      );
    } catch (_) {
      // Plugin not yet linked — treat as no saved profile.
      return (name: null, email: null);
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyName);
      await prefs.remove(_keyEmail);
    } catch (_) {}
  }

  static Future<void> savePendingAuthEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPendingAuthEmail, email);
    } catch (_) {}
  }

  static Future<String?> loadPendingAuthEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyPendingAuthEmail);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearPendingAuthEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPendingAuthEmail);
    } catch (_) {}
  }

  static Future<void> savePerformance({
    required int readingSessions,
    required int bubbleCorrect,
    required int bubbleTargetTotal,
    required int storySessions,
    int phonicsSuccesses = 0,
    bool vowelZoneComplete = false,
    bool consonantZoneComplete = false,
    int wordCorrect = 0,
    int wordTotal = 0,
    int sentenceCorrect = 0,
    int sentenceTotal = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyReadingSessions, readingSessions);
      await prefs.setInt(_keyBubbleCorrect, bubbleCorrect);
      await prefs.setInt(_keyBubbleTargetTotal, bubbleTargetTotal);
      await prefs.setInt(_keyStorySessions, storySessions);
      await prefs.setInt(_keyPhonicsSuccesses, phonicsSuccesses);
      await prefs.setBool(_keyVowelZoneComplete, vowelZoneComplete);
      await prefs.setBool(_keyConsonantZoneComplete, consonantZoneComplete);
      await prefs.setInt(_keyWordCorrect, wordCorrect);
      await prefs.setInt(_keyWordTotal, wordTotal);
      await prefs.setInt(_keySentenceCorrect, sentenceCorrect);
      await prefs.setInt(_keySentenceTotal, sentenceTotal);
    } catch (_) {}
  }

  static Future<
    ({
      int readingSessions,
      int bubbleCorrect,
      int bubbleTargetTotal,
      int storySessions,
      int phonicsSuccesses,
      bool vowelZoneComplete,
      bool consonantZoneComplete,
      int wordCorrect,
      int wordTotal,
      int sentenceCorrect,
      int sentenceTotal,
    })
  >
  loadPerformance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (
        readingSessions: prefs.getInt(_keyReadingSessions) ?? 0,
        bubbleCorrect: prefs.getInt(_keyBubbleCorrect) ?? 0,
        bubbleTargetTotal: prefs.getInt(_keyBubbleTargetTotal) ?? 0,
        storySessions: prefs.getInt(_keyStorySessions) ?? 0,
        phonicsSuccesses: prefs.getInt(_keyPhonicsSuccesses) ?? 0,
        vowelZoneComplete: prefs.getBool(_keyVowelZoneComplete) ?? false,
        consonantZoneComplete: prefs.getBool(_keyConsonantZoneComplete) ?? false,
        wordCorrect: prefs.getInt(_keyWordCorrect) ?? 0,
        wordTotal: prefs.getInt(_keyWordTotal) ?? 0,
        sentenceCorrect: prefs.getInt(_keySentenceCorrect) ?? 0,
        sentenceTotal: prefs.getInt(_keySentenceTotal) ?? 0,
      );
    } catch (_) {
      return (
        readingSessions: 0,
        bubbleCorrect: 0,
        bubbleTargetTotal: 0,
        storySessions: 0,
        phonicsSuccesses: 0,
        vowelZoneComplete: false,
        consonantZoneComplete: false,
        wordCorrect: 0,
        wordTotal: 0,
        sentenceCorrect: 0,
        sentenceTotal: 0,
      );
    }
  }
}
