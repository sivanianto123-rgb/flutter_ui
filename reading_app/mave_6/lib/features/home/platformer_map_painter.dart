import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── World constants ──────────────────────────────────────────────────────────
const double kWorldWidth = 3400;

// Island data: (centerX, yFrac, width, decor, stars 0-3)
// yFrac = top of island surface as fraction of screen height.
// stars = how many stars the player has earned on this level (0 = locked/not started).
const _islands = [
  (280.0, 0.72, 210.0, _Decor.home, 3),
  (640.0, 0.61, 155.0, _Decor.tree, 2),
  (990.0, 0.50, 135.0, _Decor.flowers, 1),
  (1300.0, 0.66, 165.0, _Decor.mushroom, 0),
  (1620.0, 0.44, 120.0, _Decor.tree, 0),
  (1940.0, 0.58, 145.0, _Decor.star, 0),
  (2240.0, 0.38, 115.0, _Decor.tree, 0),
  (2560.0, 0.53, 140.0, _Decor.flowers, 0),
  (2860.0, 0.63, 215.0, _Decor.castle, 0),
];
const _levelTitles = [
  'Phonics Zone',
  'Vowel Zone',
  'Consonant Zone',
  'Word Zone',
  'Sentences Zone',
];

enum _Decor { home, tree, flowers, mushroom, star, castle }

// ─── Painter ─────────────────────────────────────────────────────────────────

class PlatformerMapPainter extends CustomPainter {
  const PlatformerMapPainter(
    this.h, {
    this.isDarkMode = false,
    this.unlockedLevelCount = 1,
  });
  final double h; // world height (screen height)
  final bool isDarkMode;
  final int unlockedLevelCount;

  @override
  void paint(Canvas canvas, Size size) {
    _sky(canvas, size);
    _sun(canvas);
    _mountainsFar(canvas, size);
    _mountainsMid(canvas, size);
    _treelineSilhouette(canvas, size);
    _mist(canvas, size);
    _clouds(canvas, size);
    _bridges(canvas);
    _allIslands(canvas);
  }

  // ── Sky — warm sunny-forest day ─────────────────────────────────────────────

  void _sky(Canvas canvas, Size size) {
    final colors = isDarkMode
        ? const [
            Color(0xFF06152D),
            Color(0xFF0B2A4A),
            Color(0xFF1A3E66),
            Color(0xFF234C73),
            Color(0xFF355D7E),
            Color(0xFF4D6C88),
          ]
        : const [
            Color(0xFF0D3B6E),
            Color(0xFF1565C0),
            Color(0xFF42A5F5),
            Color(0xFF81D4FA),
            Color(0xFFB3E5FC),
            Color(0xFFFFF8E1),
          ];
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0.0, 0.12, 0.38, 0.60, 0.78, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  // ── Sun ─────────────────────────────────────────────────────────────────────

  void _sun(Canvas canvas) {
    // Placed upper-left so it's visible as the player starts the map.
    const cx = 280.0;
    final cy = h * 0.12;
    final c = Offset(cx, cy);

    if (isDarkMode) {
      canvas.drawCircle(
        c,
        44,
        Paint()
          ..color = const Color(0x4490CAF9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawCircle(c, 30, Paint()..color = const Color(0xFFE3F2FD));
      canvas.drawCircle(
        c + const Offset(12, -6),
        24,
        Paint()..color = const Color(0xFF2A4A67),
      );
      return;
    }

    canvas.drawCircle(
      c,
      80,
      Paint()
        ..color = const Color(0x18FFF9C4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55),
    );
    // Inner warm glow
    canvas.drawCircle(
      c,
      52,
      Paint()
        ..color = const Color(0x30FFD740)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    // Triangular sun rays — alternating long / short
    _sunRays(canvas, c, innerR: 38, count: 14);

    // Main disc — radial gradient for depth
    canvas.drawCircle(
      c,
      36,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: const [
            Color(0xFFFFF9C4),
            Color(0xFFFDD835),
            Color(0xFFF9A825),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: 36)),
    );

    // Small specular highlight
    canvas.drawCircle(
      c - const Offset(11, 11),
      10,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  void _sunRays(
    Canvas canvas,
    Offset c, {
    required double innerR,
    required int count,
  }) {
    for (int i = 0; i < count; i++) {
      final angle = i * 2 * math.pi / count - math.pi / 2;
      final isLong = i % 2 == 0;
      final outerR = isLong ? innerR + 36.0 : innerR + 18.0;
      final spread = isLong ? 0.055 : 0.04;

      final path = Path()
        ..moveTo(
          c.dx + math.cos(angle - spread) * (innerR + 2),
          c.dy + math.sin(angle - spread) * (innerR + 2),
        )
        ..lineTo(
          c.dx + math.cos(angle) * outerR,
          c.dy + math.sin(angle) * outerR,
        )
        ..lineTo(
          c.dx + math.cos(angle + spread) * (innerR + 2),
          c.dy + math.sin(angle + spread) * (innerR + 2),
        )
        ..close();

      canvas.drawPath(path, Paint()..color = const Color(0xAAFFD740));
    }
  }

  // ── Mountain layers (forest-palette, back → front) ─────────────────────────

  void _mountainsFar(Canvas canvas, Size size) {
    // Farthest — hazy blue-green, atmospheric perspective makes these appear
    // lighter and cooler than the foreground trees.
    final topY = h * 0.42;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF7CB9C4), Color(0xFF4A9BA8)],
      ).createShader(Rect.fromLTWH(0, topY, size.width, h * 0.28));
    _smoothHills(
      canvas,
      size,
      paint,
      baseY: h * 0.68,
      minH: h * 0.13,
      maxH: h * 0.24,
      seed: 1,
    );
  }

  void _mountainsMid(Canvas canvas, Size size) {
    // Mid — warm forest green hills, still smooth (distant canopy).
    final topY = h * 0.55;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(0, topY, size.width, h * 0.25));
    _smoothHills(
      canvas,
      size,
      paint,
      baseY: h * 0.76,
      minH: h * 0.10,
      maxH: h * 0.18,
      seed: 7,
    );
  }

  /// Smooth rounded hill rows for far + mid layers.
  void _smoothHills(
    Canvas canvas,
    Size size,
    Paint paint, {
    required double baseY,
    required double minH,
    required double maxH,
    required int seed,
  }) {
    final rng = math.Random(seed);
    final path = Path()..moveTo(0, baseY);
    double x = 0;
    while (x < size.width) {
      final mw = 70 + rng.nextDouble() * 90;
      final mh = minH + rng.nextDouble() * (maxH - minH);
      path.cubicTo(
        x + mw * 0.25,
        baseY - mh * 0.15,
        x + mw * 0.40,
        baseY - mh,
        x + mw * 0.50,
        baseY - mh,
      );
      path.cubicTo(
        x + mw * 0.60,
        baseY - mh,
        x + mw * 0.75,
        baseY - mh * 0.15,
        x + mw,
        baseY,
      );
      x += mw * 0.68;
    }
    path
      ..lineTo(size.width, baseY)
      ..lineTo(size.width, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, paint);
  }

  /// Nearest layer — a dense bumpy treeline silhouette instead of smooth hills.
  void _treelineSilhouette(Canvas canvas, Size size) {
    final baseY = h * 0.84;
    final rng = math.Random(37);

    // Two-tone: lighter canopy colour on top, dark body below
    for (final (color, yShift, seed2) in [
      (const Color(0xFF2E7D32), 0.0, 37),
      (const Color(0xFF1B5E20), h * 0.04, 59),
    ]) {
      final path = Path()..moveTo(0, baseY + yShift);
      double x = 0;
      final r2 = math.Random(seed2);
      while (x < size.width) {
        final tw = 18.0 + r2.nextDouble() * 24;
        final th = h * 0.07 + r2.nextDouble() * h * 0.09;
        final tx = x + tw / 2;
        final ty = baseY + yShift - th;
        // round tree-top arch
        path.lineTo(x, baseY + yShift);
        path.cubicTo(x, ty + th * 0.4, tx - tw * 0.35, ty, tx, ty);
        path.cubicTo(
          tx + tw * 0.35,
          ty,
          x + tw,
          ty + th * 0.4,
          x + tw,
          baseY + yShift,
        );
        x += tw * (0.55 + rng.nextDouble() * 0.3);
      }
      path
        ..lineTo(size.width, baseY + yShift)
        ..lineTo(size.width, h)
        ..lineTo(0, h)
        ..close();

      canvas.drawPath(path, Paint()..color = color);
    }
  }

  /// Soft ground mist sitting at the base of the treeline — forest atmosphere.
  void _mist(Canvas canvas, Size size) {
    final mistY = h * 0.80;
    canvas.drawRect(
      Rect.fromLTWH(0, mistY, size.width, h * 0.12),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, mistY, size.width, h * 0.12)),
    );
  }

  // ── Clouds ─────────────────────────────────────────────────────────────────

  void _clouds(Canvas canvas, Size size) {
    // Mix of large cumulus and smaller wispy clouds across the world.
    const specs = [
      // (centerX, yFrac, radius, large?)
      (500.0, 0.09, 52.0, true),
      (870.0, 0.14, 34.0, false),
      (1180.0, 0.06, 58.0, true),
      (1500.0, 0.11, 38.0, false),
      (1780.0, 0.07, 48.0, true),
      (2060.0, 0.13, 32.0, false),
      (2340.0, 0.05, 55.0, true),
      (2650.0, 0.10, 40.0, false),
      (2940.0, 0.07, 50.0, true),
      (3220.0, 0.12, 36.0, false),
    ];
    for (final (cx, yf, r, large) in specs) {
      _cloud(canvas, Offset(cx, h * yf), r, large: large);
    }
  }

  void _cloud(Canvas canvas, Offset c, double r, {bool large = true}) {
    // All layers are pure circles — no rectangles, no boxes.

    // 1. Soft drop shadow (offset down-right, blurred blue-grey)
    _drawPuffs(
      canvas,
      c + Offset(r * 0.12, r * 0.20),
      r,
      Paint()
        ..color = const Color(0x30A8C0D0)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.35),
    );

    // 2. Main cloud body — top-to-bottom gradient baked into the shader rect
    final bodyRect = Rect.fromLTWH(
      c.dx - r * 2.0,
      c.dy - r * 1.2,
      r * 4.0,
      r * 2.4,
    );
    _drawPuffs(
      canvas,
      c,
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Colors.white, Color(0xFFD6E8F5)],
        ).createShader(bodyRect),
    );

    // 3. Bright white highlight layer (upper puffs only, semi-transparent)
    _drawPuffs(
      canvas,
      c - Offset(r * 0.05, r * 0.12),
      r * 0.78,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );

    // 4. Small specular glint on the tallest puff
    if (large) {
      canvas.drawCircle(
        c - Offset(r * 0.30, r * 0.32),
        r * 0.22,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }
  }

  /// Draws the cluster of overlapping puffs that form a cloud shape.
  void _drawPuffs(Canvas canvas, Offset c, double r, Paint paint) {
    canvas.drawCircle(c, r, paint); // main centre
    canvas.drawCircle(c + Offset(-r * 0.72, r * 0.10), r * 0.74, paint); // left
    canvas.drawCircle(c + Offset(r * 0.74, r * 0.06), r * 0.70, paint); // right
    canvas.drawCircle(
      c + Offset(-r * 0.30, -r * 0.42),
      r * 0.56,
      paint,
    ); // top-left
    canvas.drawCircle(
      c + Offset(r * 0.30, -r * 0.38),
      r * 0.52,
      paint,
    ); // top-right
    canvas.drawCircle(
      c + Offset(r * 0.90, r * 0.20),
      r * 0.46,
      paint,
    ); // far right
    canvas.drawCircle(
      c + Offset(-r * 0.92, r * 0.22),
      r * 0.44,
      paint,
    ); // far left
  }

  // ── Rope bridges between consecutive islands ────────────────────────────────

  void _bridges(Canvas canvas) {
    for (int i = 0; i < _islands.length - 1; i++) {
      final (ax, ayf, aw, _, _) = _islands[i];
      final (bx, byf, bw, _, _) = _islands[i + 1];
      _bridge(
        canvas,
        Offset(ax + aw * 0.42, ayf * h - 4),
        Offset(bx - bw * 0.42, byf * h - 4),
      );
    }
  }

  void _bridge(Canvas canvas, Offset a, Offset b) {
    final midX = (a.dx + b.dx) / 2;
    final sag = (b - a).distance * 0.18 + 20;
    final ctrl = Offset(midX, math.max(a.dy, b.dy) + sag);

    final ropePaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // two rope lines
    for (final offset in [-6.0, 6.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy + offset)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy + offset, b.dx, b.dy + offset),
        ropePaint,
      );
    }

    // planks
    final plankPaint = Paint()
      ..color = const Color(0xFFBCAAA4)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    const steps = 10;
    for (int j = 1; j < steps; j++) {
      final t = j / steps;
      final u = 1 - t;
      final px = u * u * a.dx + 2 * u * t * ctrl.dx + t * t * b.dx;
      final py = u * u * a.dy + 2 * u * t * ctrl.dy + t * t * b.dy;
      canvas.drawLine(Offset(px, py - 6), Offset(px, py + 6), plankPaint);
    }
  }

  // ── All islands ─────────────────────────────────────────────────────────────

  void _allIslands(Canvas canvas) {
    for (final entry in _islands.asMap().entries) {
      final index = entry.key;
      final (cx, yf, w, decor, stars) = entry.value;
      _island(canvas, index, cx, yf * h, w, decor, stars);
    }
  }

  void _island(
    Canvas canvas,
    int index,
    double cx,
    double surfaceY,
    double w,
    _Decor decor,
    int stars,
  ) {
    const bodyH = 80.0;
    final isLocked = index >= unlockedLevelCount;

    // ── Rock body ────────────────────────────────────────────────────────────
    final body = _islandBodyPath(cx, surfaceY, w, bodyH);

    // gradient: lighter warm stone at top → dark earth at bottom
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFFBCAAA4),
            Color(0xFF795548),
            Color(0xFF4E342E),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(cx - w / 2, surfaceY, w, bodyH + 20)),
    );

    // subtle left-edge highlight
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white.withValues(alpha: 0.12), Colors.transparent],
        ).createShader(Rect.fromLTWH(cx - w / 2, surfaceY, w, bodyH)),
    );

    // outline
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF3E2723)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // dangling root tendrils
    _roots(canvas, cx, surfaceY + bodyH * 0.7, w);

    // ── Grass surface ─────────────────────────────────────────────────────────
    _grassTop(canvas, cx, surfaceY, w);

    // ── Decoration ────────────────────────────────────────────────────────────
    if (!isLocked) {
      switch (decor) {
        case _Decor.home:
          _hut(canvas, cx, surfaceY);
          break;
        case _Decor.tree:
          _tree(canvas, cx, surfaceY);
          break;
        case _Decor.flowers:
          _flowerCluster(canvas, cx, surfaceY, w);
          break;
        case _Decor.mushroom:
          _mushroom(canvas, cx, surfaceY);
          break;
        case _Decor.star:
          _floatingStar(canvas, cx, surfaceY);
          break;
        case _Decor.castle:
          _castle(canvas, cx, surfaceY);
          break;
      }
    } else {
      _drawLockBadge(canvas, cx, surfaceY - 34);
    }

    // ── Star rating — badge anchored just below the grass line ────────────────
    _drawStars(canvas, cx, surfaceY + 24, isLocked ? 0 : stars);
    if (index < _levelTitles.length) {
      _drawLevelTitle(canvas, cx, surfaceY + 50, _levelTitles[index]);
    }
    if (isDarkMode) _drawOwlLevelMarker(canvas, cx, surfaceY - 30);
  }

  void _drawLevelTitle(Canvas canvas, double cx, double y, String title) {
    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          shadows: [Shadow(color: Color(0xAA000000), blurRadius: 6)],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 190);
    tp.paint(canvas, Offset(cx - tp.width / 2, y));
  }

  void _drawLockBadge(Canvas canvas, double cx, double y) {
    final center = Offset(cx, y);
    canvas.drawCircle(
      center,
      18,
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      center,
      18,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    final lockBody = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center + const Offset(0, 4),
        width: 12,
        height: 10,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(lockBody, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawArc(
      Rect.fromCenter(
        center: center + const Offset(0, -1),
        width: 10,
        height: 9,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawOwlLevelMarker(Canvas canvas, double cx, double y) {
    final center = Offset(cx, y);
    canvas.drawCircle(center, 14, Paint()..color = const Color(0xFF6D4C41));
    canvas.drawCircle(
      center + const Offset(-5, -2),
      4,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center + const Offset(5, -2),
      4,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center + const Offset(-5, -2),
      1.8,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      center + const Offset(5, -2),
      1.8,
      Paint()..color = Colors.black,
    );
    final beak = Path()
      ..moveTo(cx, y + 1)
      ..lineTo(cx - 3, y + 6)
      ..lineTo(cx + 3, y + 6)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFFFC107));
  }

  // ── 3-star progress indicator ─────────────────────────────────────────────

  void _drawStars(Canvas canvas, double cx, double y, int earned) {
    const total = 3;
    const starR = 10.0; // outer radius of each star
    const innerR = 4.5; // inner radius
    const spacing = 26.0; // centre-to-centre gap

    final totalW = (total - 1) * spacing;
    final startX = cx - totalW / 2;
    final badgeRect = Rect.fromCenter(
      center: Offset(cx, y),
      width: totalW + 44,
      height: 30,
    );

    // Soft backing badge keeps stars visible on any island/decor while blending in.
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(16)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x663A2A1F), Color(0x99210F07)],
        ).createShader(badgeRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(16)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0x66FFFFFF),
    );

    for (int i = 0; i < total; i++) {
      final sx = startX + i * spacing;
      final filled = i < earned;

      // Glow behind earned stars
      if (filled) {
        canvas.drawCircle(
          Offset(sx, y),
          starR + 5,
          Paint()
            ..color = const Color(0x55FFD740)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }

      // Build star path
      final path = Path();
      for (int p = 0; p < 5; p++) {
        final outerAngle = p * 2 * math.pi / 5 - math.pi / 2;
        final innerAngle = outerAngle + math.pi / 5;
        final outerPt = Offset(
          sx + math.cos(outerAngle) * starR,
          y + math.sin(outerAngle) * starR,
        );
        final innerPt = Offset(
          sx + math.cos(innerAngle) * innerR,
          y + math.sin(innerAngle) * innerR,
        );
        if (p == 0)
          path.moveTo(outerPt.dx, outerPt.dy);
        else
          path.lineTo(outerPt.dx, outerPt.dy);
        path.lineTo(innerPt.dx, innerPt.dy);
      }
      path.close();

      if (filled) {
        // Filled — gold gradient
        canvas.drawPath(
          path,
          Paint()
            ..shader =
                LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [Color(0xFFFFF176), Color(0xFFFFC107)],
                ).createShader(
                  Rect.fromCircle(center: Offset(sx, y), radius: starR),
                ),
        );
        // Thin dark outline
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFE65100)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..strokeJoin = StrokeJoin.round,
        );
      } else {
        // Empty — frosted fill + brighter outline so stars remain visible.
        canvas.drawPath(
          path,
          Paint()
            ..shader =
                LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [Color(0xAAFFFFFF), Color(0x66CFD8DC)],
                ).createShader(
                  Rect.fromCircle(center: Offset(sx, y), radius: starR),
                ),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xCC37474F)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
  }

  Path _islandBodyPath(double cx, double top, double w, double bodyH) {
    final l = cx - w / 2;
    final r = cx + w / 2;
    final bl = top + bodyH;
    final path = Path();
    // top-left to top-right (the grass line will cover this)
    path.moveTo(l + w * 0.04, top + 4);
    // left side curves inward slightly
    path.cubicTo(
      l - 8,
      top + bodyH * 0.2,
      l + w * 0.08,
      bl - 12,
      l + w * 0.18,
      bl + 8,
    );
    // rounded bottom
    path.cubicTo(
      l + w * 0.35,
      bl + 22,
      r - w * 0.35,
      bl + 22,
      r - w * 0.18,
      bl + 8,
    );
    // right side
    path.cubicTo(
      r - w * 0.08,
      bl - 12,
      r + 8,
      top + bodyH * 0.2,
      r - w * 0.04,
      top + 4,
    );
    path.close();
    return path;
  }

  // ── Grass top ───────────────────────────────────────────────────────────────

  void _grassTop(Canvas canvas, double cx, double y, double w) {
    final l = cx - w / 2 - 8;
    final r = cx + w / 2 + 8;

    // dark grass underlayer
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(l, y - 10, r - l, 22),
        topLeft: const Radius.circular(11),
        topRight: const Radius.circular(11),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF388E3C),
    );

    // bright grass top strip
    final grassPath = Path();
    grassPath.moveTo(l, y + 2);
    // wavy top edge
    final steps = ((r - l) / 14).ceil();
    for (int i = 0; i <= steps; i++) {
      final x = l + i * (r - l) / steps;
      final bmp = (i % 2 == 0) ? -7.0 : -4.0;
      if (i == 0)
        grassPath.moveTo(x, y + bmp);
      else
        grassPath.lineTo(x, y + bmp);
    }
    grassPath.lineTo(r, y + 8);
    grassPath.lineTo(l, y + 8);
    grassPath.close();

    canvas.drawPath(grassPath, Paint()..color = const Color(0xFF66BB6A));

    // highlight shimmer
    canvas.drawPath(
      grassPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.22), Colors.transparent],
        ).createShader(Rect.fromLTWH(l, y - 10, r - l, 20)),
    );

    // grass blade tufts
    final bladePaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final rng = math.Random(cx.toInt());
    for (double x = l + 8; x < r - 8; x += 12) {
      final lean = (rng.nextDouble() - 0.5) * 6;
      canvas.drawLine(Offset(x, y - 4), Offset(x + lean, y - 14), bladePaint);
    }
  }

  // ── Dangling roots ──────────────────────────────────────────────────────────

  void _roots(Canvas canvas, double cx, double y, double w) {
    final rng = math.Random(cx.toInt() + 99);
    final paint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      final rx = cx + (rng.nextDouble() - 0.5) * w * 0.6;
      final rl = 14 + rng.nextDouble() * 22;
      canvas.drawLine(
        Offset(rx, y),
        Offset(rx + (rng.nextDouble() - 0.5) * 8, y + rl),
        paint,
      );
    }
  }

  // ── Decorations ─────────────────────────────────────────────────────────────

  void _hut(Canvas canvas, double cx, double y) {
    final bx = cx - 20.0;
    // walls
    canvas.drawRect(
      Rect.fromLTWH(bx, y - 48, 40, 38),
      Paint()..color = const Color(0xFFFFCC80),
    );
    // door
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(bx + 13, y - 26, 14, 20),
        topLeft: const Radius.circular(7),
        topRight: const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFF6D4C41),
    );
    // window
    canvas.drawRect(
      Rect.fromLTWH(bx + 4, y - 44, 10, 10),
      Paint()..color = const Color(0xFF90CAF9),
    );
    // roof
    final roof = Path()
      ..moveTo(bx - 8, y - 48)
      ..lineTo(cx, y - 78)
      ..lineTo(bx + 48, y - 48)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFE53935));
    canvas.drawPath(
      roof,
      Paint()
        ..color = const Color(0xFFB71C1C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // chimney
    canvas.drawRect(
      Rect.fromLTWH(bx + 28, y - 80, 8, 20),
      Paint()..color = const Color(0xFF795548),
    );
    // smoke puffs
    final sp = Paint()..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(bx + 32, y - 88), 5, sp);
    canvas.drawCircle(Offset(bx + 35, y - 96), 7, sp);
    canvas.drawCircle(Offset(bx + 38, y - 103), 5, sp);
  }

  void _tree(Canvas canvas, double cx, double y) {
    // trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 7, y - 52, 14, 42),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF6D4C41),
    );
    // three round canopy layers (Mario style)
    for (int i = 0; i < 3; i++) {
      final r = 26.0 - i * 4;
      final cy = y - 52 - i * 16.0;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [const Color(0xFF66BB6A), const Color(0xFF1B5E20)],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
      // highlight
      canvas.drawCircle(
        Offset(cx - r * 0.3, cy - r * 0.3),
        r * 0.28,
        Paint()..color = Colors.white.withValues(alpha: 0.18),
      );
    }
  }

  void _flowerCluster(Canvas canvas, double cx, double y, double w) {
    const fc = [
      Color(0xFFFF8A80),
      Color(0xFFFFD740),
      Color(0xFF40C4FF),
      Color(0xFFE040FB),
      Color(0xFF69F0AE),
    ];
    final rng = math.Random(cx.toInt());
    for (int i = 0; i < 7; i++) {
      final fx = cx + (rng.nextDouble() - 0.5) * w * 0.55;
      final fy = y - 8 - rng.nextDouble() * 10;
      _flower(canvas, Offset(fx, fy), fc[i % fc.length]);
    }
  }

  void _flower(Canvas canvas, Offset c, Color color) {
    final pp = Paint()..color = color;
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      canvas.drawCircle(
        c + Offset(math.cos(a) * 5, math.sin(a) * 5 - 10),
        4.5,
        pp,
      );
    }
    canvas.drawCircle(
      c - const Offset(0, 10),
      3.5,
      Paint()..color = const Color(0xFFFFF176),
    );
    // stem
    canvas.drawLine(
      c - const Offset(0, 5),
      c,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _mushroom(Canvas canvas, double cx, double y) {
    // stem
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 8, y - 34, 16, 26),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFF5F5F5),
    );
    // cap
    final capPath = Path()
      ..moveTo(cx - 24, y - 34)
      ..cubicTo(cx - 26, y - 56, cx - 14, y - 66, cx, y - 66)
      ..cubicTo(cx + 14, y - 66, cx + 26, y - 56, cx + 24, y - 34)
      ..close();
    canvas.drawPath(capPath, Paint()..color = const Color(0xFFE53935));
    // spots
    for (final (ox, oy) in [
      (-10.0, -54.0),
      (8.0, -60.0),
      (0.0, -48.0),
      (-4.0, -63.0),
    ]) {
      canvas.drawCircle(
        Offset(cx + ox, y + oy),
        4.5,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  void _floatingStar(Canvas canvas, double cx, double y) {
    // glow
    canvas.drawCircle(
      Offset(cx, y - 50),
      22,
      Paint()
        ..color = const Color(0x66FFD740)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    // star shape
    final path = Path();
    const n = 5;
    const r1 = 18.0;
    const r2 = 9.0;
    for (int i = 0; i < n * 2; i++) {
      final a = i * math.pi / n - math.pi / 2;
      final r = (i % 2 == 0) ? r1 : r2;
      final p = Offset(cx + math.cos(a) * r, y - 50 + math.sin(a) * r);
      if (i == 0)
        path.moveTo(p.dx, p.dy);
      else
        path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD740));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFF9C4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _castle(Canvas canvas, double cx, double y) {
    final bx = cx - 30.0;
    const bw = 60.0;
    const bh = 70.0;

    // main tower body
    canvas.drawRect(
      Rect.fromLTWH(bx, y - bh, bw, bh),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFFB0BEC5), Color(0xFF78909C)],
        ).createShader(Rect.fromLTWH(bx, y - bh, bw, bh)),
    );

    // battlements (crenellations)
    final battlePaint = Paint()..color = const Color(0xFF90A4AE);
    for (int i = 0; i < 5; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(bx + i * 12, y - bh - 12, 12, 12),
          battlePaint,
        );
      }
    }

    // gate arch
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(bx + 18, y - 32, 24, 26),
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFF37474F),
    );

    // windows (arrow slits)
    for (final wy in [y - bh + 14, y - bh + 38]) {
      for (final wx in [bx + 10, bx + 40]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(wx, wy, 8, 14),
            const Radius.circular(4),
          ),
          Paint()..color = const Color(0xFF263238),
        );
      }
    }

    // flag pole
    canvas.drawLine(
      Offset(cx, y - bh),
      Offset(cx, y - bh - 36),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 3,
    );
    // flag pennant
    final flag = Path()
      ..moveTo(cx, y - bh - 34)
      ..lineTo(cx + 22, y - bh - 24)
      ..lineTo(cx, y - bh - 14)
      ..close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFFE53935));

    // left tower
    canvas.drawRect(
      Rect.fromLTWH(bx - 14, y - bh + 14, 18, bh - 14),
      Paint()..color = const Color(0xFF90A4AE),
    );
    canvas.drawRect(Rect.fromLTWH(bx - 14, y - bh + 2, 6, 12), battlePaint);
    canvas.drawRect(Rect.fromLTWH(bx - 2, y - bh + 2, 6, 12), battlePaint);

    // right tower
    canvas.drawRect(
      Rect.fromLTWH(bx + bw - 4, y - bh + 14, 18, bh - 14),
      Paint()..color = const Color(0xFF90A4AE),
    );
    canvas.drawRect(Rect.fromLTWH(bx + bw - 4, y - bh + 2, 6, 12), battlePaint);
    canvas.drawRect(Rect.fromLTWH(bx + bw + 8, y - bh + 2, 6, 12), battlePaint);
  }

  @override
  bool shouldRepaint(PlatformerMapPainter old) =>
      old.h != h ||
      old.isDarkMode != isDarkMode ||
      old.unlockedLevelCount != unlockedLevelCount;
}
