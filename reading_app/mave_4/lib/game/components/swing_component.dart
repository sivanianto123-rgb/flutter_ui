import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart' show Color, Paint, Canvas, RRect, Rect, Radius;

import 'player_component.dart';

/// A pendulum swing hanging from a fixed pivot point.
///
/// Phase 1 coordinate estimates (1920×1080):
///   Left swing  — pivot (255, 302), armLength 385 → seat centre ≈ (255, 696)
///   Right swing — pivot (355, 302), armLength 385 → seat centre ≈ (355, 696)
///
/// The component's [anchor] is [Anchor.topCenter] so that Flame's rotation
/// transform pivots around the top of the rope (the fixed peg).
///
/// When the player's hitbox overlaps the seat hitbox, [_kick] fires a
/// realistic pendulum decay via a [SequenceEffect] of [RotateEffect] calls.
class SwingComponent extends PositionComponent with CollisionCallbacks {
  final Vector2 pivot;
  final double armLength;

  bool _isKicking = false;

  // ── Visual constants ────────────────────────────────────────────────────
  static const double _seatWidth = 72.0;
  static const double _seatHeight = 18.0;
  static const double _ropeWidth = 4.0;

  static const Color _ropeColor = Color(0xFF8B5E3C);
  static const Color _seatColor = Color(0xFF5C3317);

  SwingComponent({required this.pivot, required this.armLength})
      : super(
          anchor: Anchor.topCenter,
          priority: 2,
        );

  @override
  Future<void> onLoad() async {
    // Position the pivot at the supplied world coordinate.
    position = pivot;
    size = Vector2(_seatWidth, armLength + _seatHeight);

    // ── Seat hitbox ──────────────────────────────────────────────────────
    // Center of the seat in component-local space:
    //   x = size.x / 2  (horizontally centred)
    //   y = armLength + _seatHeight / 2  (at the bottom of the rope)
    add(
      RectangleHitbox(
        size: Vector2(_seatWidth, _seatHeight),
        position: Vector2(size.x / 2, armLength + _seatHeight / 2),
      )..anchor = Anchor.center,
    );
  }

  // ── Rendering ────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2; // horizontal centre in local space

    // Rope
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, armLength / 2),
        width: _ropeWidth,
        height: armLength,
      ),
      Paint()..color = _ropeColor,
    );

    // Seat plank
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, armLength, _seatWidth, _seatHeight),
        const Radius.circular(4),
      ),
      Paint()..color = _seatColor,
    );
  }

  // ── Collision ────────────────────────────────────────────────────────────

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is PlayerComponent) _kick();
  }

  // ── Pendulum animation ───────────────────────────────────────────────────

  void _kick() {
    if (_isKicking) return;
    _isKicking = true;

    // Five-step decaying oscillation that ends back at angle 0.
    // Total duration: 0.35 + 0.50 + 0.38 + 0.32 + 0.28 = 1.83 s
    add(
      SequenceEffect([
        RotateEffect.to(
          0.38,
          EffectController(duration: 0.35, curve: Curves.easeOut),
        ),
        RotateEffect.to(
          -0.26,
          EffectController(duration: 0.50, curve: Curves.easeInOut),
        ),
        RotateEffect.to(
          0.14,
          EffectController(duration: 0.38, curve: Curves.easeInOut),
        ),
        RotateEffect.to(
          -0.06,
          EffectController(duration: 0.32, curve: Curves.easeInOut),
        ),
        RotateEffect.to(
          0.00,
          EffectController(duration: 0.28, curve: Curves.easeIn),
        ),
      ]),
    );

    // Unlock kicking once the animation is fully complete.
    add(
      TimerComponent(
        period: 1.90,
        onTick: () => _isKicking = false,
        removeOnFinish: true,
      ),
    );
  }
}
