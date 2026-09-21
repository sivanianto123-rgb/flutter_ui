import 'dart:convert';
import 'package:flutter/foundation.dart';

// ── UI type whitelist ──────────────────────────────────────────────────────────

/// Whitelisted game modules that Gemini may assign to an activity.
///
/// Any value not in this list defaults to [feedMonster].
///   feedMonster   — drag bubbles to monster mouth (target-sound focus)
///   beeTrace      — bee moves while microphone detects vocalization
///   tapPop        — tap the floating bubble that matches the target sound
///   doorScavenger — open the correct door to find the target-sound friend
enum UiType { feedMonster, beeTrace, tapPop, doorScavenger }

// ── Activity spec ──────────────────────────────────────────────────────────────

/// AI-generated activity definition returned by [GeminiActivityService].
///
/// Recitation sequence (handled by [GameModuleShell]):
///   1. Google Cloud TTS speaks [title]     (expressive, full speed)
///   2. Google Cloud TTS speaks [storyText] (warm, slightly slower)
///   3. The [uiType]-whitelisted game renders.
@immutable
class ActivitySpec {
  const ActivitySpec({
    required this.uiType,
    required this.title,
    required this.storyText,
    required this.targetSound,
  });

  final UiType uiType;
  final String title;       // TTS step 1 — e.g. "Learning the MA sound!"
  final String storyText;   // TTS step 2 — 2-3 sentence warm story
  final String targetSound; // 'ma' | 'pa' | 'ma_pa'

  // ── Whitelist map ──────────────────────────────────────────────────────────

  static const Map<String, UiType> _whitelist = {
    'feed_monster':   UiType.feedMonster,
    'bee_trace':      UiType.beeTrace,
    'tap_pop':        UiType.tapPop,
    'door_scavenger': UiType.doorScavenger,
  };

  // ── Deserialisation ────────────────────────────────────────────────────────

  /// Parses a Gemini-returned JSON string.  Unknown [uiType] → [feedMonster].
  factory ActivitySpec.fromJson(String jsonStr, String targetSound) {
    final Map<String, dynamic> m;
    try {
      m = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return ActivitySpec.fallback(targetSound);
    }

    return ActivitySpec(
      uiType:      _whitelist[m['uiType'] as String? ?? ''] ?? UiType.feedMonster,
      title:       (m['title'] as String?)?.trim()     ?? _defaultTitle(targetSound),
      storyText:   (m['storyText'] as String?)?.trim() ?? _defaultStory(targetSound),
      targetSound: targetSound,
    );
  }

  /// Safe static fallback used when Gemini times out or returns bad JSON.
  factory ActivitySpec.fallback(String targetSound) => ActivitySpec(
        uiType:      UiType.feedMonster,
        title:       _defaultTitle(targetSound),
        storyText:   _defaultStory(targetSound),
        targetSound: targetSound,
      );

  static String _defaultTitle(String s) {
    final cap = s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;
    return 'Learning the $cap sound!';
  }

  static String _defaultStory(String s) =>
      'Mama loves to say ${s.toUpperCase()}! '
      'Can you say it too? ${s.toUpperCase()}, ${s.toUpperCase()}!';
}
