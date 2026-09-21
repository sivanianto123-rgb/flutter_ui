import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class LetterComponent extends TextComponent {
  LetterComponent({
    required this.letter,
    Vector2? position,
  }) : super(
          text: letter,
          position: position,
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 140,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(4, 6),
                  blurRadius: 8,
                )
              ],
            ),
          ),
        );

  final String letter;

  Future<void> pulse() async {
    // A quick scale up and down
    add(
      ScaleEffect.to(
        Vector2.all(1.3),
        EffectController(
          duration: 0.2,
          reverseDuration: 0.2,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}
