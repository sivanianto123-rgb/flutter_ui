import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level_node.dart';

final worldMapProvider = StateNotifierProvider<WorldMapNotifier, List<LevelNode>>((ref) {
  return WorldMapNotifier();
});

class WorldMapNotifier extends StateNotifier<List<LevelNode>> {
  WorldMapNotifier() : super([]);

  void init(double screenW) {
    if (state.isEmpty) state = buildNodes(screenW);
  }

  int get currentNodeIndex =>
      state.indexWhere((n) => n.state == NodeState.current);
}
