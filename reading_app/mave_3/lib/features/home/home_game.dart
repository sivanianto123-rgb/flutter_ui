import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Flame game that renders the animated background of the Home screen:
/// - Scrolling starfield
/// - Drifting clouds
/// - Floating sparkles / decorations
///
/// Interactive node buttons are Flutter widgets overlaid on top via
/// [GameWidget.overlayBuilderMap] so they benefit from Riverpod and routing.
class HomeBackgroundGame extends FlameGame {
  HomeBackgroundGame();

  @override
  Color backgroundColor() => const Color(0xFF0D1B3E);

  @override
  Future<void> onLoad() async {
    // ── Stars ────────────────────────────────────────────────────────────────
    for (int i = 0; i < 60; i++) {
      add(_StarParticle());
    }

    // ── Clouds ───────────────────────────────────────────────────────────────
    for (int i = 0; i < 5; i++) {
      add(_CloudComponent(index: i));
    }

    // ── Floating sparkles ─────────────────────────────────────────────────────
    for (int i = 0; i < 12; i++) {
      add(_SparkleComponent(index: i));
    }

    // ── Winding path dots ─────────────────────────────────────────────────────
    add(_WindingPathComponent());
  }
}

// ── Star ───────────────────────────────────────────────────────────────────────

class _StarParticle extends PositionComponent with HasGameReference {
  _StarParticle() {
    final rng = math.Random();
    _radius   = 1.0 + rng.nextDouble() * 2.0;
    _alpha    = 0.4 + rng.nextDouble() * 0.6;
    _twinkleSpeed = 0.5 + rng.nextDouble() * 1.5;
    _twinklePhase = rng.nextDouble() * math.pi * 2;
    _color    = [
      const Color(0xFFFFFFFF),
      const Color(0xFFFFE66D),
      const Color(0xFF9BE8E4),
      const Color(0xFFFFB3C6),
    ][rng.nextInt(4)];
  }

  late double _radius;
  late double _alpha;
  late double _twinkleSpeed;
  late double _twinklePhase;
  late Color  _color;
  double      _elapsed = 0;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    final rng = math.Random();
    position = Vector2(
      rng.nextDouble() * gameSize.x,
      rng.nextDouble() * gameSize.y * 0.7,
    );
  }

  @override
  void update(double dt) {
    _elapsed += dt;
  }

  @override
  void render(Canvas canvas) {
    final phase  = math.sin(_elapsed * _twinkleSpeed + _twinklePhase);
    final alpha  = (_alpha * (0.5 + 0.5 * phase)).clamp(0.0, 1.0);
    final paint  = Paint()..color = _color.withOpacity(alpha);
    canvas.drawCircle(Offset.zero, _radius, paint);

    // Cross-sparkle effect on brighter stars
    if (_radius > 2.0) {
      final sparklePaint = Paint()
        ..color  = Colors.white.withOpacity(alpha * 0.6)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(-_radius * 2, 0), Offset(_radius * 2, 0), sparklePaint);
      canvas.drawLine(Offset(0, -_radius * 2), Offset(0, _radius * 2), sparklePaint);
    }
  }
}

// ── Cloud ───────────────────────────────────────────────────────────────────────

class _CloudComponent extends PositionComponent with HasGameReference {
  _CloudComponent({required this.index});

  final int index;
  final _rng = math.Random();
  late double _speed;
  late double _yBase;
  late double _bobPhase;
  late double _bobSpeed;
  late double _width;
  late double _alpha;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    _speed    = 8.0 + index * 4.0;
    _yBase    = gameSize.y * (0.05 + index * 0.08);
    _bobPhase = _rng.nextDouble() * math.pi * 2;
    _bobSpeed = 0.3 + _rng.nextDouble() * 0.4;
    _width    = 80 + _rng.nextDouble() * 60;
    _alpha    = 0.08 + _rng.nextDouble() * 0.12;
    position  = Vector2(gameSize.x * (_rng.nextDouble() + index * 0.2), _yBase);
    size      = Vector2(_width, _width * 0.5);
  }

  @override
  void update(double dt) {
    final ref = game;
    x += _speed * dt;
    if (x > ref.size.x + _width) x = -_width;
    y = _yBase + math.sin(x * 0.003 + _bobPhase) * 8;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withOpacity(_alpha);
    final r = _width / 2;
    // Puff cloud shape
    canvas.drawOval(Rect.fromCenter(center: Offset(r, r * 0.65), width: _width, height: r * 0.9), paint);
    canvas.drawCircle(Offset(r * 0.4, r * 0.4), r * 0.38, paint);
    canvas.drawCircle(Offset(r * 0.7, r * 0.28), r * 0.30, paint);
    canvas.drawCircle(Offset(r * 1.0, r * 0.32), r * 0.35, paint);
    canvas.drawCircle(Offset(r * 1.3, r * 0.40), r * 0.28, paint);
    canvas.drawCircle(Offset(r * 1.6, r * 0.52), r * 0.32, paint);
  }
}

// ── Sparkle ────────────────────────────────────────────────────────────────────

class _SparkleComponent extends PositionComponent with HasGameReference {
  _SparkleComponent({required this.index});

  final int index;
  double _elapsed  = 0;
  late double _phase;
  late double _speed;
  late Color  _color;
  late double _size;

  static const _colors = [
    Color(0xFFFFE66D), Color(0xFFFF6B9D), Color(0xFF4ECDC4),
    Color(0xFF6BCB77), Color(0xFFA855F7), Color(0xFFFF9F43),
  ];

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    final rng = math.Random(index * 31 + 7);
    _phase   = rng.nextDouble() * math.pi * 2;
    _speed   = 0.4 + rng.nextDouble() * 0.8;
    _color   = _colors[index % _colors.length];
    _size    = 3.0 + rng.nextDouble() * 4.0;
    position = Vector2(
      rng.nextDouble() * gameSize.x,
      gameSize.y * 0.2 + rng.nextDouble() * gameSize.y * 0.6,
    );
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    final ref = game;
    y = position.y + math.sin(_elapsed * _speed + _phase) * dt * 20;
    if (y > ref.size.y) y = 0;
  }

  @override
  void render(Canvas canvas) {
    final alpha = 0.5 + 0.5 * math.sin(_elapsed * _speed * 2 + _phase);
    final paint = Paint()..color = _color.withOpacity(alpha.clamp(0.0, 1.0));

    // 4-pointed star shape
    final s = _size;
    final path = Path()
      ..moveTo(0, -s)
      ..lineTo(s * 0.2, -s * 0.2)
      ..lineTo(s, 0)
      ..lineTo(s * 0.2, s * 0.2)
      ..lineTo(0, s)
      ..lineTo(-s * 0.2, s * 0.2)
      ..lineTo(-s, 0)
      ..lineTo(-s * 0.2, -s * 0.2)
      ..close();
    canvas.drawPath(path, paint);
  }
}

// ── Winding path dots ──────────────────────────────────────────────────────────

class _WindingPathComponent extends Component with HasGameReference {
  @override
  void render(Canvas canvas) {
    final size = game.size;
    _drawPath(canvas, size.x, size.y);
  }

  void _drawPath(Canvas canvas, double w, double h) {
    // Define the winding path control points (bottom → top)
    final points = _pathPoints(w, h);

    // Draw dotted path
    final paint = Paint()
      ..color       = const Color(0xFFFFE66D).withOpacity(0.35)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap   = StrokeCap.round;

    // Dashed effect by drawing short segments
    final dashPaint = Paint()
      ..color       = const Color(0xFFFFE66D).withOpacity(0.5)
      ..style       = PaintingStyle.fill;

    if (points.length < 2) return;

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final dx = p1.dx - p0.dx;
      final dy = p1.dy - p0.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      final steps = (dist / 24).round();
      for (int j = 0; j < steps; j += 2) {
        final t0 = j / steps;
        final t1 = (j + 1) / steps;
        final start = Offset(p0.dx + dx * t0, p0.dy + dy * t0);
        final end   = Offset(p0.dx + dx * t1, p0.dy + dy * t1);
        canvas.drawCircle(
          Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2),
          5,
          dashPaint,
        );
      }
    }

    // Draw shadow dots
    final shadowPaint = Paint()
      ..color = const Color(0xFFE6C84A).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final dx = p1.dx - p0.dx;
      final dy = p1.dy - p0.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      final steps = (dist / 24).round();
      for (int j = 0; j < steps; j += 2) {
        final t = (j + 0.5) / steps;
        final pos = Offset(p0.dx + dx * t + 2, p0.dy + dy * t + 3);
        canvas.drawCircle(pos, 5, shadowPaint);
      }
    }
  }

  List<Offset> _pathPoints(double w, double h) => [
    Offset(w * 0.30, h * 0.88),   // Start at bottom-left (Ma node)
    Offset(w * 0.50, h * 0.78),
    Offset(w * 0.70, h * 0.68),
    Offset(w * 0.60, h * 0.55),   // Mid-right curve
    Offset(w * 0.40, h * 0.45),
    Offset(w * 0.30, h * 0.32),   // Pa node area
    Offset(w * 0.50, h * 0.22),
    Offset(w * 0.65, h * 0.12),   // Combo node at top-right
  ];
}
