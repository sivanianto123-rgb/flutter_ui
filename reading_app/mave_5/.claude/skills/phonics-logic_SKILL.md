---
name: phonics-logic
description: Mave phonics game logic — mastery thresholds, bubble unlock
  sequence, Sound Pop challenge rules, and progression state. Auto-load when
  working on Phonics Zone features, game flow, or level unlock conditions.
---

# Phonics Logic — Mave

## Sound Sequence (starter set — 26 total)
```
Phase 1 (starter): m, a, s, t, i, p, n
Phase 2:           c/k, e, h, r, d, o, g
Phase 3:           u, l, f, b
Phase 4:           j, q, v, w, x, y, z
```
Each phase unlocks after the previous phase is fully mastered.

## Mastery Definition
A phoneme is "mastered" when the child correctly identifies it in the
Sound Pop Challenge with a score of **3 correct out of 4 attempts** in a
single session (or 2 consecutive sessions with ≥2/4).

## Riverpod State Model
```dart
// lib/features/phonics/providers/phonics_state.dart

@freezed
class PhonemeMastery with _$PhonemeMastery {
  const factory PhonemeMastery({
    required String phoneme,
    @Default(0) int correctAttempts,
    @Default(0) int totalAttempts,
    @Default(false) bool isMastered,
    DateTime? masteredAt,
  }) = _PhonemeMastery;
}

@riverpod
class PhonicsProgress extends _$PhonicsProgress {
  @override
  Map<String, PhonemeMastery> build() => {};

  void recordAttempt(String phoneme, bool correct) { ... }
  bool checkMastery(String phoneme) {
    final m = state[phoneme];
    if (m == null) return false;
    // 3/4 rule
    return m.correctAttempts >= 3 && m.totalAttempts <= 4;
  }
  List<String> get unlockedPhonemes => ...;
  List<String> get availablePhonemes => ...; // next 2 after mastered
}
```

## Sound Pop Challenge Rules
- Show 4 bubbles on screen at a time
- 1 bubble = target sound, 3 = distractors (similar sounds)
- Distractor selection: prefer phonetically similar sounds (e.g. for /m/: /n/, /b/, /p/)
- On correct tap: play reward sound + animate bubble burst + green flash
- On wrong tap: bubble shakes (400ms), replay target sound prompt, retry
- Mastery check: after each correct pop, check 3/4 threshold
- Max attempts per session: 8 (then show encouragement + exit)

## Bubble Unlock Logic
```dart
// After phoneme N is mastered → unlock phoneme N+1
// After 2 phonemes mastered → unlock Sound Pop for blend (e.g. "ma")
// Show max 2 bubbles on the selection screen at starter level
int get visibleBubbleCount {
  if (masteredCount < 4) return 2;
  if (masteredCount < 8) return 3;
  return 4; // max visible at once
}
```

## Word Zone Unlock Condition
```dart
bool get wordZoneUnlocked => masteredPhonemes.length >= 7; // all Phase 1
```
