import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Desert-themed Flame background game.
/// Renders: sandy sky gradient, dunes, cacti, rocks, and scattered stars.
/// Level nodes and UI are Flutter widgets overlaid on top.
class DesertBackgroundGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFFFDB347);

  @override
  Future<void> onLoad() async {
    add(_SkyComponent());
    add(_DuneLayer(yFraction: 0.72, color: const Color(0xFFE8922A), amplitude: 0.07));
    add(_DuneLayer(yFraction: 0.80, color: const Color(0xFFF0A030), amplitude: 0.05));
    add(_DuneLayer(yFraction: 0.88, color: const Color(0xFFD4791A), amplitude: 0.04));

    // Cacti at fixed fractional positions
    final cactiPositions = [
      const Offset(0.78, 0.18),
      const Offset(0.85, 0.10),
      const Offset(0.12, 0.55),
      const Offset(0.90, 0.55),
      const Offset(0.60, 0.05),
    ];
    for (final pos in cactiPositions) {
      add(_CactusPainter(xFrac: pos.dx, yFrac: pos.dy));
    }

    // Rocks
    final rockPositions = [
      const Offset(0.38, 0.68),
      const Offset(0.55, 0.62),
      const Offset(0.20, 0.72),
      const Offset(0.75, 0.60),
    ];
    for (final pos in rockPositions) {
      add(_RockPainter(xFrac: pos.dx, yFrac: pos.dy));
    }

    // Floating dust particles
    for (int i = 0; i < 18; i++) {
      add(_DustParticle(index: i));
    }
  }
}

// ── Sky gradient ───────────────────────────────────────────────────────────────

class _SkyComponent extends Component with HasGameReference {
  @override
  void render(Canvas canvas) {
    final size = game.size;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y * 0.75);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFFFFD580)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
}

// ── Rolling dune layer ─────────────────────────────────────────────────────────

class _DuneLayer extends Component with HasGameReference {
  _DuneLayer({
    required this.yFraction,
    required this.color,
    required this.amplitude,
  });

  final double yFraction;
  final Color color;
  final double amplitude;
  double _elapsed = 0;

  @override
  void update(double dt) => _elapsed += dt * 0.12;

  @override
  void render(Canvas canvas) {
    final s = game.size;
    final baseY = s.y * yFraction;
    final amp = s.y * amplitude;
    final path = Path();
    path.moveTo(0, baseY);
    for (double x = 0; x <= s.x; x += 4) {
      final y = baseY + math.sin((x / s.x) * 2 * math.pi + _elapsed) * amp;
      path.lineTo(x, y);
    }
    path.lineTo(s.x, s.y);
    path.lineTo(0, s.y);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }
}

// ── Cactus ────────────────────────────────────────────────────────────────────

class _CactusPainter extends Component with HasGameReference {
  _CactusPainter({required this.xFrac, required this.yFrac});

  final double xFrac;
  final double yFrac;

  static const _green     = Color(0xFF3A8C3F);
  static const _darkGreen = Color(0xFF2A6B2E);

  @override
  void render(Canvas canvas) {
    final s = game.size;
    final cx = s.x * xFrac;
    final cy = s.y * yFrac;
    final scale = s.y * 0.10;
    _drawCactus(canvas, cx, cy, scale);
  }

  void _drawCactus(Canvas canvas, double cx, double cy, double h) {
    final trunk = Paint()..color = _green;
    final dark  = Paint()..color = _darkGreen;

    // Trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - h * 0.15, cy - h, h * 0.30, h),
        const Radius.circular(6),
      ),
      trunk,
    );

    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - h * 0.45, cy - h * 0.65, h * 0.30, h * 0.18),
        const Radius.circular(5),
      ),
      trunk,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - h * 0.47, cy - h * 0.82, h * 0.18, h * 0.28),
        const Radius.circular(5),
      ),
      trunk,
    );

    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + h * 0.15, cy - h * 0.55, h * 0.30, h * 0.18),
        const Radius.circular(5),
      ),
      trunk,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + h * 0.27, cy - h * 0.72, h * 0.18, h * 0.28),
        const Radius.circular(5),
      ),
      trunk,
    );

    // Ribs shadow
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(cx - h * 0.12, cy - h * (0.3 + i * 0.25)),
        Offset(cx + h * 0.12, cy - h * (0.3 + i * 0.25)),
        dark..strokeWidth = 1.5,
      );
    }
  }
}

// ── Rock ──────────────────────────────────────────────────────────────────────

class _RockPainter extends Component with HasGameReference {
  _RockPainter({required this.xFrac, required this.yFrac});

  final double xFrac;
  final double yFrac;

  @override
  void render(Canvas canvas) {
    final s = game.size;
    final cx = s.x * xFrac;
    final cy = s.y * yFrac;
    final r  = s.y * 0.038;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: r * 2.4, height: r * 1.4),
      Paint()..color = const Color(0xFFA0785A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - r * 0.15, cy - r * 0.2), width: r * 1.6, height: r * 0.8),
      Paint()..color = const Color(0xFFBC9070),
    );
  }
}

// ── Floating dust particle ────────────────────────────────────────────────────

class _DustParticle extends PositionComponent with HasGameReference {
  _DustParticle({required this.index});

  final int index;
  late double _speed;
  late double _phase;
  late double _radius;
  double _elapsed = 0;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    final rng = math.Random(index * 17 + 3);
    _speed  = 0.3 + rng.nextDouble() * 0.5;
    _phase  = rng.nextDouble() * math.pi * 2;
    _radius = 2.0 + rng.nextDouble() * 3.0;
    position = Vector2(
      rng.nextDouble() * gameSize.x,
      gameSize.y * 0.3 + rng.nextDouble() * gameSize.y * 0.5,
    );
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    x += _speed * 18 * dt;
    if (x > game.size.x + 10) x = -10;
    y = position.y + math.sin(_elapsed * _speed + _phase) * 6 * dt;
  }

  @override
  void render(Canvas canvas) {
    final alpha = 0.3 + 0.2 * math.sin(_elapsed * _speed + _phase);
    canvas.drawCircle(
      Offset.zero,
      _radius,
      Paint()..color = const Color(0xFFFFD580).withOpacity(alpha),
    );
  }
}
