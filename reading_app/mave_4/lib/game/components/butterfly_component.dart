import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/material.dart'
    show Color, Colors, Paint, PaintingStyle, Canvas, Rect, Offset;

import '../enchanted_game.dart';

/// A dynamic butterfly that flutters endlessly through the upper portion
/// of the scene, automatically avoiding the cottage structure.
///
/// Wings are rendered as two coloured ovals; the body is a small dark oval.
/// The flight path is a [SequenceEffect] of [MoveEffect.to] waypoints with
/// [infinite: true] so the butterfly loops forever without any manual timer.
///
/// Each ButterflyComponent gets a unique [wingColor] and a different random
/// seed so the eight instances spread across the scene.
class ButterflyComponent extends PositionComponent
    with HasGameRef<MyEnchantedGame> {
  final Color wingColor;

  static const double _wingW = 26.0;
  static const double _wingH = 16.0;
  static const double _bodyW = 5.0;
  static const double _bodyH = 12.0;

  ButterflyComponent({
    required Vector2 startPosition,
    required this.wingColor,
  }) : super(
          position: startPosition,
          size: Vector2(_wingW * 2 + 2, _wingH),
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    _startFlutter();
  }

  // ── Flight path ───────────────────────────────────────────────────────────

  void _startFlutter() {
    final rng = Random();
    const waypointCount = 8;

    final moves = List<Effect>.generate(waypointCount, (_) {
      final target = MyEnchantedGame.randomButterflyPoint(rng);
      final duration = 0.7 + rng.nextDouble() * 2.3; // 0.7 – 3.0 s per leg
      return MoveEffect.to(
        target,
        EffectController(duration: duration, curve: Curves.easeInOut),
      );
    });

    // infinite: true → the butterfly loops the waypoint list forever
    add(SequenceEffect(moves, infinite: true));
  }

  // ── Rendering ─────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    final wingPaint = Paint()..color = wingColor.withOpacity(0.88);
    final bodyPaint = Paint()..color = Colors.black87;
    final outlinePaint = Paint()
      ..color = Colors.black38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final cx = size.x / 2;
    final cy = size.y / 2;

    // Left wing
    final leftWingRect = Rect.fromCenter(
      center: Offset(cx - _wingW * 0.5, cy),
      width: _wingW,
      height: _wingH,
    );
    canvas.drawOval(leftWingRect, wingPaint);
    canvas.drawOval(leftWingRect, outlinePaint);

    // Right wing
    final rightWingRect = Rect.fromCenter(
      center: Offset(cx + _wingW * 0.5, cy),
      width: _wingW,
      height: _wingH,
    );
    canvas.drawOval(rightWingRect, wingPaint);
    canvas.drawOval(rightWingRect, outlinePaint);

    // Body (narrow oval in the centre)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: _bodyW,
        height: _bodyH,
      ),
      bodyPaint,
    );
  }
}
