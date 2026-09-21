import 'package:flutter/foundation.dart';

enum NodeStatus { locked, available, inProgress, mastered }

@immutable
class SoundNode {
  const SoundNode({
    required this.id,
    required this.label,
    required this.description,
    this.prerequisites    = const [],
    this.unlockThreshold  = 0.0,
  });

  final String     id;
  final String     label;
  final String     description;
  final List<String> prerequisites;
  final double     unlockThreshold;

  static const List<SoundNode> curriculum = [
    SoundNode(
      id:          'ma',
      label:       'Ma',
      description: 'Learn the Ma sound',
    ),
    SoundNode(
      id:          'pa',
      label:       'Pa',
      description: 'Learn the Pa sound',
    ),
    SoundNode(
      id:              'ma_pa',
      label:           'Ma + Pa',
      description:     'Combine Ma and Pa',
      prerequisites:   ['ma', 'pa'],
      unlockThreshold: 0.9,
    ),
  ];

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

  String get primarySound =>
      prerequisites.isEmpty ? id : prerequisites.first;
}
