import 'package:flutter/material.dart';

enum NodeState { completed, current, locked }

class LevelNode {
  final int id;
  final Offset position;
  final NodeState state;
  final int stars;

  const LevelNode({
    required this.id,
    required this.position,
    required this.state,
    required this.stars,
  });
}

const double canvasHeight = 1400.0;

List<LevelNode> buildNodes(double w) => [
      LevelNode(id: 1, position: Offset(w * 0.16, canvasHeight * 0.72), state: NodeState.completed, stars: 3),
      LevelNode(id: 2, position: Offset(w * 0.26, canvasHeight * 0.85), state: NodeState.completed, stars: 2),
      LevelNode(id: 3, position: Offset(w * 0.38, canvasHeight * 0.76), state: NodeState.current,   stars: 0),
      LevelNode(id: 4, position: Offset(w * 0.46, canvasHeight * 0.50), state: NodeState.completed, stars: 3),
      LevelNode(id: 5, position: Offset(w * 0.54, canvasHeight * 0.28), state: NodeState.completed, stars: 3),
      LevelNode(id: 6, position: Offset(w * 0.72, canvasHeight * 0.62), state: NodeState.locked,    stars: 0),
      LevelNode(id: 7, position: Offset(w * 0.84, canvasHeight * 0.70), state: NodeState.locked,    stars: 0),
      LevelNode(id: 8, position: Offset(w * 0.96, canvasHeight * 0.70), state: NodeState.locked,    stars: 0),
    ];
