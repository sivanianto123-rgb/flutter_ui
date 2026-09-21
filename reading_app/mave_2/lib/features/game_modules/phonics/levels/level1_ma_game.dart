import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../components/letter_component.dart';
import '../effects/star_explosion_effect.dart';
import '../phonics_game.dart';

class Level1MaGame extends PositionComponent {
  Level1MaGame({required this.engine});

  final PhonicsGame engine;

  late LetterComponent letterM;
  late LetterComponent letterA;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Position them separated initially
    final screenCenter = engine.size / 2;

    letterM = LetterComponent(
      letter: 'm',
      position: Vector2(screenCenter.x - 200, screenCenter.y),
    );
    letterA = LetterComponent(
      letter: 'a',
      position: Vector2(screenCenter.x + 200, screenCenter.y),
    );

    add(letterM);
    add(letterA);
  }

  void startAnimationSequence() async {
    engine.gameState.value = PhonicsGameState.animating;
    
    final screenCenter = engine.size / 2;

    // Move 'M' to the center-left
    letterM.add(
      MoveEffect.to(
        Vector2(screenCenter.x - 60, screenCenter.y),
        EffectController(duration: 1.0, curve: Curves.easeInOut),
      ),
    );

    // Move 'A' to the center-right
    letterA.add(
      MoveEffect.to(
        Vector2(screenCenter.x + 60, screenCenter.y),
        EffectController(duration: 1.0, curve: Curves.easeInOut),
      ),
    );

    // Complete animation phase
    await Future.delayed(const Duration(seconds: 1));
    engine.gameState.value = PhonicsGameState.playingAudio;
  }

  void pulseLetter(String letter) {
    if (letter.toLowerCase() == 'm') {
      letterM.pulse();
    } else if (letter.toLowerCase() == 'a') {
      letterA.pulse();
    } else if (letter.toLowerCase() == 'ma') {
      letterM.pulse();
      letterA.pulse();
    }
  }

  void triggerExplosion() {
    final screenCenter = engine.size / 2;
    // Add star explosion right in the middle
    add(StarExplosionEffect(screenCenter));
    
    // Play an inner pulse too
    pulseLetter('ma');
  }
}
