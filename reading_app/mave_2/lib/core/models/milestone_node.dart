import 'package:flutter/foundation.dart';

/// Learning status of a single node on the Adaptive Milestone Timeline.
enum NodeStatus { locked, available, inProgress, mastered }

/// Whether the node teaches a standalone phoneme or combines two mastered ones.
enum NodeType { individual, bridge }

/// A single interactive node on the Adaptive Milestone Timeline.
///
/// [individual] nodes (e.g. 'Ma', 'Pa') are always available to start.
/// [bridge] nodes (e.g. 'Ma + Pa') unlock only when every [prerequisites]
/// entry has reached [NodeStatus.mastered] in the child's profile.
@immutable
class MilestoneNode {
  const MilestoneNode({
    required this.id,
    required this.label,
    required this.type,
    required this.emoji,
    this.prerequisites = const [],
  });

  /// Canonical identifier, also used as the syllable key (e.g. 'ma', 'ma_pa').
  final String id;

  /// Human-readable display label (e.g. 'Ma', 'Ma + Pa').
  final String label;

  final NodeType type;
  final String emoji;

  /// For [NodeType.bridge]: the IDs that must reach [NodeStatus.mastered] first.
  final List<String> prerequisites;

  // ── Fixed curriculum ───────────────────────────────────────────────────────

  static const List<MilestoneNode> curriculum = [
    MilestoneNode(id: 'ma', label: 'Ma', type: NodeType.individual, emoji: '🐻'),
    MilestoneNode(id: 'pa', label: 'Pa', type: NodeType.individual, emoji: '🦋'),
    MilestoneNode(
      id: 'ma_pa',
      label: 'Ma + Pa',
      type: NodeType.bridge,
      emoji: '✨',
      prerequisites: ['ma', 'pa'],
    ),
    MilestoneNode(id: 'ba', label: 'Ba', type: NodeType.individual, emoji: '🎈'),
    MilestoneNode(id: 'da', label: 'Da', type: NodeType.individual, emoji: '🌟'),
    MilestoneNode(
      id: 'ba_da',
      label: 'Ba + Da',
      type: NodeType.bridge,
      emoji: '🎵',
      prerequisites: ['ba', 'da'],
    ),
    MilestoneNode(id: 'na', label: 'Na', type: NodeType.individual, emoji: '🌈'),
    MilestoneNode(id: 'ka', label: 'Ka', type: NodeType.individual, emoji: '🎀'),
    MilestoneNode(
      id: 'na_ka',
      label: 'Na + Ka',
      type: NodeType.bridge,
      emoji: '🌺',
      prerequisites: ['na', 'ka'],
    ),
  ];

  // ── Status computation ─────────────────────────────────────────────────────

  /// Derives this node's status from the child's [levelProgress] map.
  ///
  /// A syllable is considered [mastered] at level ≥ 3 (all three activity
  /// tiers completed with a passing score). Bridge nodes are [locked] until
  /// every prerequisite is mastered.
  NodeStatus statusFor(Map<String, int> levelProgress) {
    if (type == NodeType.bridge) {
      final allMastered =
          prerequisites.every((p) => (levelProgress[p] ?? 0) >= 3);
      if (!allMastered) return NodeStatus.locked;
    }

    final level = levelProgress[id] ?? 0;
    if (level >= 3) return NodeStatus.mastered;
    if (level > 0) return NodeStatus.inProgress;
    return NodeStatus.available;
  }

  /// The phoneme passed to the AI activity generator and audio engine.
  /// Bridge nodes exercise the first prerequisite sound primarily.
  String get primarySyllable =>
      type == NodeType.bridge ? prerequisites.first : id;
}
