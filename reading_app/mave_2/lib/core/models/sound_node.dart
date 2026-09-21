import 'package:flutter/foundation.dart';

/// Learning status of a single sound node on the timeline.
enum NodeStatus { locked, available, inProgress, mastered }

/// Which hardcoded game module this node runs.
enum ModuleType { feedTheMonster, soundTracing }

/// A single node in the Phase 1 (Ma / Pa) sound curriculum.
///
/// Phase 1 contains exactly three nodes:
///   1. Ma  → Feed the Monster (individual)
///   2. Pa  → Feed the Monster (individual)
///   3. Ma + Pa → Sound Tracing (combo, requires both at ≥ [unlockThreshold])
///
/// Combo unlock logic:
///   [statusFor] receives the rolling accuracy map from [SoundScoreService].
///   The Ma + Pa node stays [locked] until both 'ma' and 'pa' entries in
///   that map are ≥ [unlockThreshold] (default 0.9 = 90 %).
@immutable
class SoundNode {
  const SoundNode({
    required this.id,
    required this.label,
    required this.emoji,
    required this.moduleType,
    this.prerequisites    = const [],
    this.unlockThreshold  = 0.0,
  });

  /// Canonical identifier and Hive/Firestore key.
  final String     id;

  /// Human-readable label shown on the timeline tile.
  final String     label;

  final String     emoji;
  final ModuleType moduleType;

  /// IDs that must hit [unlockThreshold] accuracy before this node unlocks.
  final List<String> prerequisites;

  /// Rolling accuracy threshold (0.0–1.0) required on all [prerequisites].
  final double     unlockThreshold;

  // ── Phase 1 curriculum ─────────────────────────────────────────────────────

  static const List<SoundNode> curriculum = [
    SoundNode(
      id:         'ma',
      label:      'Ma',
      emoji:      '🐻',
      moduleType: ModuleType.feedTheMonster,
    ),
    SoundNode(
      id:         'pa',
      label:      'Pa',
      emoji:      '🦋',
      moduleType: ModuleType.feedTheMonster,
    ),
    SoundNode(
      id:              'ma_pa',
      label:           'Ma + Pa',
      emoji:           '✨',
      moduleType:      ModuleType.soundTracing,
      prerequisites:   ['ma', 'pa'],
      unlockThreshold: 0.9,
    ),
  ];

  // ── Status ─────────────────────────────────────────────────────────────────

  /// Derives this node's status given the rolling [accuracyMap].
  ///
  /// [accuracyMap] maps sound ID → rolling average accuracy (0.0–1.0),
  /// computed from the last [SoundScoreService.windowSize] sessions.
  NodeStatus statusFor(Map<String, double> accuracyMap) {
    if (!_isUnlocked(accuracyMap)) return NodeStatus.locked;
    final acc = accuracyMap[id] ?? 0.0;
    if (acc >= 0.9) return NodeStatus.mastered;
    if (acc > 0.0)  return NodeStatus.inProgress;
    return NodeStatus.available;
  }

  bool _isUnlocked(Map<String, double> accuracyMap) {
    if (prerequisites.isEmpty) return true;
    return prerequisites.every(
      (p) => (accuracyMap[p] ?? 0.0) >= unlockThreshold,
    );
  }

  /// The primary phoneme this node teaches (first prerequisite for combos).
  String get primarySound =>
      prerequisites.isEmpty ? id : prerequisites.first;
}
