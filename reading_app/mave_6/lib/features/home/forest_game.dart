import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

// ─── Flame game ────────────────────────────────────────────────────────────

class ForestGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF5BB8F5);

  @override
  Future<void> onLoad() async {
    await add(ForestScene());
  }
}

// ─── Single component that paints the whole forest scene ───────────────────

class ForestScene extends Component with HasGameReference<ForestGame> {
  Vector2 _size = Vector2.zero();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _size = size;
  }

  @override
  void render(Canvas canvas) {
    if (_size.x == 0) return;
    _sky(canvas);
    _sun(canvas);
    _clouds(canvas);
    _distantHills(canvas);
    _ground(canvas);
    _path(canvas);
    _trees(canvas);
    _flowers(canvas);
    _grassBlades(canvas);
  }

  // ── Sky ──────────────────────────────────────────────────────────────────

  void _sky(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _size.x, _size.y * 0.68),
      Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          Offset(0, _size.y * 0.68),
          const [Color(0xFF2196F3), Color(0xFF64B5F6), Color(0xFFBBDEFB)],
          [0.0, 0.5, 1.0],
        ),
    );
  }

  // ── Sun ──────────────────────────────────────────────────────────────────

  void _sun(Canvas canvas) {
    final c = Offset(_size.x * 0.14, _size.y * 0.11);
    canvas.drawCircle(
      c, 52,
      Paint()
        ..color = const Color(0x55FFD740)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawCircle(c, 30, Paint()..color = const Color(0xFFFDD835));
    canvas.drawCircle(c - const Offset(9, 9), 13,
        Paint()..color = const Color(0x99FFF9C4));

    final rp = Paint()
      ..color = const Color(0x80FDD835)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        c + Offset(math.cos(a) * 36, math.sin(a) * 36),
        c + Offset(math.cos(a) * 50, math.sin(a) * 50),
        rp,
      );
    }
  }

  // ── Clouds ───────────────────────────────────────────────────────────────

  void _clouds(Canvas canvas) {
    final p = Paint()..color = const Color(0xEBFFFFFF);
    _cloud(canvas, p, Offset(_size.x * 0.52, _size.y * 0.07), 44);
    _cloud(canvas, p, Offset(_size.x * 0.78, _size.y * 0.14), 32);
    _cloud(canvas, p, Offset(_size.x * 0.32, _size.y * 0.19), 28);
  }

  void _cloud(Canvas canvas, Paint p, Offset c, double r) {
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c + Offset(r * 0.72, 0), r * 0.78, p);
    canvas.drawCircle(c - Offset(r * 0.72, 0), r * 0.72, p);
    canvas.drawCircle(c + Offset(r * 0.28, -r * 0.4), r * 0.65, p);
    canvas.drawRect(
      Rect.fromCenter(
        center: c + Offset(0, r * 0.35),
        width:  r * 2.6,
        height: r * 0.8,
      ),
      p,
    );
  }

  // ── Distant hills / treeline at horizon ──────────────────────────────────

  void _distantHills(Canvas canvas) {
    final groundY = _size.y * 0.62;
    final path = Path()..moveTo(0, groundY);
    final rng  = math.Random(77);
    double x   = 0;
    while (x < _size.x) {
      final w = 30 + rng.nextDouble() * 28;
      final h = 36 + rng.nextDouble() * 32;
      path
        ..lineTo(x, groundY)
        ..lineTo(x + w / 2, groundY - h)
        ..lineTo(x + w, groundY);
      x += w * 0.68;
    }
    path
      ..lineTo(_size.x, groundY)
      ..lineTo(_size.x, _size.y)
      ..lineTo(0, _size.y)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = Gradient.linear(
          Offset(0, groundY - 60),
          Offset(0, groundY),
          const [Color(0x991B5E20), Color(0x7727AE60)],
        ),
    );
  }

  // ── Ground ───────────────────────────────────────────────────────────────

  void _ground(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, _size.y * 0.6, _size.x, _size.y * 0.4),
      Paint()
        ..shader = Gradient.linear(
          Offset(0, _size.y * 0.6),
          Offset(0, _size.y),
          const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
    );
  }

  // ── Winding dirt path (S-curve, perspective) ─────────────────────────────

  void _path(Canvas canvas) {
    final w  = _size.x;
    final h  = _size.y;
    final cx = w * 0.5;

    // shadow
    canvas.drawPath(
      _pathShape(cx, h, inflate: 2),
      Paint()
        ..color      = const Color(0x22000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // dirt surface
    canvas.drawPath(
      _pathShape(cx, h),
      Paint()
        ..shader = Gradient.linear(
          Offset(cx - 52, 0),
          Offset(cx + 52, 0),
          const [
            Color(0xFFA1887F),
            Color(0xFFD7CCC8),
            Color(0xFFBCAAA4),
            Color(0xFFA1887F),
          ],
          [0.0, 0.35, 0.65, 1.0],
        ),
    );

    // tyre-track grooves
    final tp = Paint()
      ..color       = const Color(0x55795548)
      ..strokeWidth = 1.5
      ..style       = PaintingStyle.stroke;
    for (final s in [-1, 1]) {
      canvas.drawPath(
        Path()
          ..moveTo(cx + s * 12, h)
          ..cubicTo(
            cx + s * 14 - s * 2, h * 0.65,
            cx + s * 12 + s * 6, h * 0.35,
            cx + s * 4,          0,
          ),
        tp,
      );
    }

    // pebbles
    final pp  = Paint()..color = const Color(0xFFBCAAA4);
    final rng = math.Random(13);
    for (int i = 0; i < 14; i++) {
      final t = i / 14.0;
      canvas.drawCircle(
        Offset(
          _pathCx(cx, t) + (rng.nextDouble() - 0.5) * 18,
          h * (1 - t),
        ),
        2.5 + rng.nextDouble() * 2,
        pp,
      );
    }
  }

  Path _pathShape(double cx, double h, {double inflate = 0}) => Path()
    ..moveTo(cx - 52 - inflate, h)
    ..cubicTo(cx - 62, h * 0.65, cx + 36, h * 0.35, cx - 20, 0)
    ..lineTo(cx - 12, 0)
    ..cubicTo(cx + 44, h * 0.35, cx - 46, h * 0.65, cx + 52 + inflate, h)
    ..close();

  double _pathCx(double cx, double t) {
    double b(double p0, double p1, double p2, double p3) {
      final u = 1 - t;
      return u * u * u * p0 + 3 * u * u * t * p1 +
             3 * u * t * t * p2 + t * t * t * p3;
    }
    return (b(cx - 52, cx - 62, cx + 36, cx - 20) +
            b(cx + 52, cx - 46, cx + 44, cx - 12)) /
        2;
  }

  // ── Trees ─────────────────────────────────────────────────────────────────

  void _trees(Canvas canvas) {
    final w = _size.x;
    final h = _size.y;

    const left = [
      (0.03, 0.88, 72.0), (0.11, 0.70, 80.0), (0.05, 0.52, 65.0),
      (0.14, 0.38, 75.0), (0.04, 0.22, 68.0), (0.09, 0.10, 58.0),
      (0.18, 0.60, 55.0), (0.08, 0.78, 60.0),
    ];
    const right = [
      (0.97, 0.88, 72.0), (0.89, 0.70, 80.0), (0.95, 0.52, 65.0),
      (0.86, 0.38, 75.0), (0.96, 0.22, 68.0), (0.91, 0.10, 58.0),
      (0.82, 0.60, 55.0), (0.92, 0.78, 60.0),
    ];

    for (final (xf, yf, sz) in left)  { _pine(canvas, Offset(w * xf, h * yf), sz); }
    for (final (xf, yf, sz) in right) { _pine(canvas, Offset(w * xf, h * yf), sz); }
  }

  void _pine(Canvas canvas, Offset base, double size) {
    // trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx, base.dy - size * 0.06),
          width:  size * 0.18,
          height: size * 0.28,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF5D4037),
    );

    // three pine layers
    const lc = [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)];
    for (int l = 0; l < 3; l++) {
      final lw   = size * (1.0 - l * 0.22);
      final ly   = base.dy - size * 0.15 - l * size * 0.24;
      final tipY = ly - size * 0.32;

      canvas.drawPath(
        Path()
          ..moveTo(base.dx, tipY)
          ..lineTo(base.dx - lw / 2, ly + size * 0.08)
          ..lineTo(base.dx + lw / 2, ly + size * 0.08)
          ..close(),
        Paint()..color = lc[l],
      );
      // sheen
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, tipY)
          ..lineTo(base.dx - lw * 0.12, ly + size * 0.08)
          ..lineTo(base.dx + lw * 0.12, ly + size * 0.08)
          ..close(),
        Paint()..color = const Color(0x1AFFFFFF),
      );
    }
  }

  // ── Flowers ───────────────────────────────────────────────────────────────

  void _flowers(Canvas canvas) {
    final w   = _size.x;
    final h   = _size.y;
    final cx  = w * 0.5;
    final rng = math.Random(21);

    const fc = [
      Color(0xFFFF8A80), Color(0xFFFFD740), Color(0xFF40C4FF),
      Color(0xFFB388FF), Color(0xFFFF80AB), Color(0xFF69F0AE),
    ];

    for (int i = 0; i < 16; i++) {
      final t  = i / 15.0;
      final px = _pathCx(cx, t);
      final y  = h * (1 - t);

      final lx = px - 60 - rng.nextDouble() * 22;
      if (lx > 4) _flower(canvas, Offset(lx, y), fc[i % fc.length]);

      final rx = px + 60 + rng.nextDouble() * 22;
      if (rx < w - 4) {
        _flower(canvas, Offset(rx, y + 4), fc[(i + 3) % fc.length]);
      }
    }
  }

  void _flower(Canvas canvas, Offset c, Color color) {
    final pp = Paint()..color = color;
    final cp = Paint()..color = const Color(0xFFFFF9C4);
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      canvas.drawCircle(c + Offset(math.cos(a) * 5, math.sin(a) * 5), 4, pp);
    }
    canvas.drawCircle(c, 3.5, cp);
  }

  // ── Grass blades at ground boundary ──────────────────────────────────────

  void _grassBlades(Canvas canvas) {
    final groundY = _size.y * 0.62;
    final rng     = math.Random(5);
    final p = Paint()
      ..color       = const Color(0xFF4CAF50)
      ..strokeWidth = 2
      ..strokeCap   = StrokeCap.round;

    for (double x = 0; x < _size.x; x += 18) {
      final lean = (rng.nextDouble() - 0.5) * 10;
      final bh   = 10 + rng.nextDouble() * 12;
      canvas.drawLine(Offset(x, groundY), Offset(x + lean, groundY - bh), p);
    }
  }
}
