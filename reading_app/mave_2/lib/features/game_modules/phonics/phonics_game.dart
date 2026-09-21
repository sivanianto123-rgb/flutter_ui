import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'levels/level1_ma_game.dart';

enum PhonicsGameState { initial, animating, playingAudio, complete }

class PhonicsGame extends FlameGame {
  PhonicsGame({
    required this.onStateChanged,
  });

  /// Callback to sync state with Flutter UI
  final void Function(PhonicsGameState) onStateChanged;

  final ValueNotifier<PhonicsGameState> gameState =
      ValueNotifier(PhonicsGameState.initial);

  late Level1MaGame level1;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Listen to internal state changes and propagate to UI
    gameState.addListener(() {
      onStateChanged(gameState.value);
    });

    // Initialize Level 1
    level1 = Level1MaGame(engine: this);
    await add(level1);
  }

  void startSequence() {
    if (gameState.value == PhonicsGameState.initial) {
      level1.startAnimationSequence();
    }
  }

  /// Called from Flutter UI when loud noise / babble is detected
  void triggerStarExplosion() {
    level1.triggerExplosion();
  }
}
