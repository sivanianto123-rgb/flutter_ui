import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'
    show Canvas, Color, Colors, Offset, Paint, PaintingStyle, Path, RRect, Rect, Radius;
import 'package:flutter/services.dart' show KeyDownEvent, KeyEvent, LogicalKeyboardKey;

import '../enchanted_game.dart';
import 'ground_component.dart';

/// A simple rectangular player character with:
///
///  - Keyboard movement: ← → arrow keys to walk, Space to jump
///  - Manual gravity accumulated in [update]
///  - Collision with [GroundComponent] to land (+ a position-clamp failsafe)
///
/// The character is rendered as a rounded sky-blue rectangle with
/// cartoon eyes and a smile — replace with a [SpriteAnimationComponent]
/// once sprite sheets are available.
class PlayerComponent extends PositionComponent
    with CollisionCallbacks, KeyboardHandler, HasGameRef<MyEnchantedGame> {
  // ── Physics ───────────────────────────────────────────────────────────────
  static const double _walkSpeed = 320.0; // px / s
  static const double _jumpImpulse = -660.0; // negative = upward
  static const double _gravity = 920.0; // px / s²

  // ── State ─────────────────────────────────────────────────────────────────
  final Vector2 _velocity = Vector2.zero();
  bool _onGround = false;
  bool _moveLeft = false;
  bool _moveRight = false;

  PlayerComponent()
      : super(
          size: Vector2(58, 80),
          priority: 3,
        );

  @override
  Future<void> onLoad() async {
    // Spawn the player standing on the floor, left side of scene.
    position = Vector2(160, MyEnchantedGame.groundY - size.y);
    add(RectangleHitbox());
  }

  // ── Update loop ───────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    // Horizontal velocity
    if (_moveLeft) {
      _velocity.x = -_walkSpeed;
    } else if (_moveRight) {
      _velocity.x = _walkSpeed;
    } else {
      _velocity.x = 0;
    }

    // Gravity (accumulates while airborne)
    if (!_onGround) {
      _velocity.y += _gravity * dt;
    }

    position += _velocity * dt;

    // Clamp to left / right screen edges
    position.x = position.x.clamp(0.0, MyEnchantedGame.gameWidth - size.x);

    // ── Hard-floor failsafe ──────────────────────────────────────────────
    // Guards against tunnelling at low frame-rates or missed collision events.
    final floorY = MyEnchantedGame.groundY - size.y;
    if (position.y >= floorY) {
      position.y = floorY;
      _velocity.y = 0;
      _onGround = true;
    }
  }

  // ── Collision ─────────────────────────────────────────────────────────────

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is GroundComponent) {
      _onGround = true;
      _velocity.y = 0;
      position.y = MyEnchantedGame.groundY - size.y;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is GroundComponent) {
      _onGround = false;
    }
  }

  // ── Keyboard input ────────────────────────────────────────────────────────

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _moveLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    _moveRight = keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.space &&
        _onGround) {
      _velocity.y = _jumpImpulse;
      _onGround = false;
    }

    return false; // allow other handlers to process the event
  }

  // ── Rendering ─────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    // Body — rounded sky-blue rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF4FC3F7),
    );

    // Face stripe (slightly darker)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, size.y * 0.18, size.x - 12, size.y * 0.52),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF81D4FA),
    );

    // Eyes
    for (final eyeX in [size.x * 0.30, size.x * 0.70]) {
      // White sclera
      canvas.drawCircle(
        Offset(eyeX, size.y * 0.30),
        7.0,
        Paint()..color = Colors.white,
      );
      // Pupil
      canvas.drawCircle(
        Offset(eyeX, size.y * 0.30),
        3.5,
        Paint()..color = const Color(0xFF1A1A2E),
      );
    }

    // Smile
    final smilePath = Path()
      ..moveTo(size.x * 0.30, size.y * 0.52)
      ..quadraticBezierTo(
        size.x * 0.50, size.y * 0.63,
        size.x * 0.70, size.y * 0.52,
      );
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF1A1A2E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }
}
