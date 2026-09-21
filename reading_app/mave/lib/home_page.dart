import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'home_game.dart';

// ── Level data ────────────────────────────────────────────────────────────────

enum LevelStatus { locked, available, completed }

class Level {
  const Level(this.number, this.status);
  final int number;
  final LevelStatus status;
}

// ── Home page ─────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final DesertBackgroundGame _game;
  late final AnimationController  _pulseCtrl;
  late final AnimationController  _foxCtrl;

  // 11 levels – 1 & 2 completed, 3 available, rest locked
  final List<Level> _levels = List.generate(
    11,
    (i) => Level(
      i + 1,
      i < 2
          ? LevelStatus.completed
          : i == 2
              ? LevelStatus.available
              : LevelStatus.locked,
    ),
  );

  @override
  void initState() {
    super.initState();
    _game     = DesertBackgroundGame();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _foxCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _foxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Flame desert background ───────────────────────────────────────
          GameWidget(game: _game),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildTitle(),
                Expanded(
                  child: _buildScrollableMap(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Stars badge
          _StarsBadge(),
          const Spacer(),
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "Let's learn with mave",
              style: TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.w900,
                color:      Color(0xFF7B3F00),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          // Settings placeholder
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_rounded, color: Color(0xFF7B3F00)),
          ),
        ],
      ),
    );
  }

  // ── Scrollable level map ──────────────────────────────────────────────────

  Widget _buildScrollableMap(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;

        // Winding path positions: bottom → top, alternating left/right
        final positions = _levelPositions(w, h);

        return SingleChildScrollView(
          reverse: true, // Start from bottom
          child: SizedBox(
            width:  w,
            height: h * 1.8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Path painter
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathPainter(positions),
                  ),
                ),

                // Fox mascot at bottom-left
                Positioned(
                  left:   w * 0.02,
                  bottom: h * 0.02,
                  child:  _FoxMascot(controller: _foxCtrl),
                ),

                // Gift box decoration mid-map
                Positioned(
                  left:   w * 0.52,
                  top:    h * 0.55,
                  child:  _GiftBox(),
                ),

                // Level nodes
                for (int i = 0; i < _levels.length; i++)
                  Positioned(
                    left:   positions[i].dx - 34,
                    top:    positions[i].dy - 34,
                    child:  _LevelNode(
                      level:      _levels[i],
                      pulse:      _pulseCtrl,
                      onTap:      () => _onLevelTap(_levels[i]),
                    ),
                  ),

                // Stars between nodes
                for (int i = 0; i < _levels.length - 1; i++)
                  ..._buildStarsBeween(positions[i], positions[i + 1]),
              ],
            ),
          ),
        );
      },
    );
  }

  // Winding snake positions (bottom to top)
  List<Offset> _levelPositions(double w, double h) {
    final totalH = h * 1.8;
    // 11 nodes evenly spread vertically, alternating x
    return List.generate(11, (i) {
      final t = i / 10; // 0..1
      final y = totalH * (0.92 - t * 0.85);
      // Sinusoidal x: creates winding
      final x = w * 0.25 + w * 0.50 * (0.5 + 0.5 * math.sin(i * 1.1));
      return Offset(x, y);
    });
  }

  List<Widget> _buildStarsBeween(Offset a, Offset b) {
    final count = 3;
    return List.generate(count, (k) {
      final t  = (k + 1) / (count + 1);
      final dx = a.dx + (b.dx - a.dx) * t;
      final dy = a.dy + (b.dy - a.dy) * t;
      return Positioned(
        left: dx - 10,
        top:  dy - 10,
        child: const _StarIcon(),
      );
    });
  }

  void _onLevelTap(Level level) {
    if (level.status == LevelStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete previous levels to unlock!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting Level ${level.number}!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// ── Path painter ─────────────────────────────────────────────────────────────

class _PathPainter extends CustomPainter {
  const _PathPainter(this.positions);
  final List<Offset> positions;

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    // Draw smooth path
    final path = Path();
    path.moveTo(positions[0].dx, positions[0].dy);
    for (int i = 1; i < positions.length; i++) {
      final prev = positions[i - 1];
      final curr = positions[i];
      final cx   = (prev.dx + curr.dx) / 2;
      path.quadraticBezierTo(cx, prev.dy, curr.dx, curr.dy);
    }

    // Path shadow
    canvas.drawPath(
      path,
      Paint()
        ..color       = const Color(0xFF8B4513).withOpacity(0.4)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 26
        ..strokeCap   = StrokeCap.round
        ..strokeJoin  = StrokeJoin.round,
    );

    // Main sandy path
    canvas.drawPath(
      path,
      Paint()
        ..color       = const Color(0xFFE8B86D)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap   = StrokeCap.round
        ..strokeJoin  = StrokeJoin.round,
    );

    // Dashed center line
    final dashPaint = Paint()
      ..color       = Colors.white.withOpacity(0.55)
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap   = StrokeCap.round;

    _drawDashedPath(canvas, path, dashPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      const dashLen  = 12.0;
      const gapLen   = 10.0;
      bool   drawing = true;
      while (distance < metric.length) {
        final seg = drawing ? dashLen : gapLen;
        if (drawing) {
          final extracted = metric.extractPath(
            distance,
            math.min(distance + seg, metric.length),
          );
          canvas.drawPath(extracted, paint);
        }
        distance += seg;
        drawing   = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Level node ────────────────────────────────────────────────────────────────

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.level,
    required this.pulse,
    required this.onTap,
  });

  final Level               level;
  final AnimationController pulse;
  final VoidCallback        onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked    = level.status == LevelStatus.locked;
    final isCompleted = level.status == LevelStatus.completed;
    final isAvailable = level.status == LevelStatus.available;

    final Color bg = isLocked
        ? const Color(0xFF9B8EA8)
        : isCompleted
            ? const Color(0xFF6C5CE7)
            : const Color(0xFF5B7BE6);

    Widget node = GestureDetector(
      onTap: onTap,
      child: Container(
        width:  68, height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(
            color: Colors.white.withOpacity(isLocked ? 0.3 : 0.7),
            width: 3,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color:      bg.withOpacity(0.6),
                    blurRadius: 14,
                    offset:     const Offset(0, 5),
                  ),
                  BoxShadow(
                    color:      Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset:     const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner highlight
            if (!isLocked)
              Positioned(
                top: 8, left: 10,
                child: Container(
                  width: 20, height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            if (isLocked)
              const Icon(Icons.lock_rounded, color: Colors.white54, size: 28)
            else if (isCompleted)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${level.number}',
                    style: const TextStyle(
                      fontSize:   20,
                      fontWeight: FontWeight.w900,
                      color:      Colors.white,
                    ),
                  ),
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                ],
              )
            else
              Text(
                '${level.number}',
                style: const TextStyle(
                  fontSize:   24,
                  fontWeight: FontWeight.w900,
                  color:      Colors.white,
                ),
              ),
          ],
        ),
      ),
    );

    if (isAvailable) {
      node = AnimatedBuilder(
        animation: pulse,
        builder: (ctx, child) {
          final scale = 1.0 + pulse.value * 0.06;
          return Transform.scale(scale: scale, child: child);
        },
        child: node,
      );
    }

    return node;
  }
}

// ── Star icon ─────────────────────────────────────────────────────────────────

class _StarIcon extends StatelessWidget {
  const _StarIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _StarPainter(color: const Color(0xFFFFD700)),
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.4;
    const points = 5;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final r     = i.isEven ? outer : inner;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x     = cx + r * math.cos(angle);
      final y     = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path.shift(const Offset(1, 1.5)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Stars badge ───────────────────────────────────────────────────────────────

class _StarsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 22),
          SizedBox(width: 4),
          Text(
            '0',
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w900,
              color:      Color(0xFF7B3F00),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fox mascot (drawn with Canvas) ────────────────────────────────────────────

class _FoxMascot extends StatelessWidget {
  const _FoxMascot({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (ctx, _) {
        final bounce = math.sin(controller.value * math.pi) * 6;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: CustomPaint(
            size: const Size(90, 100),
            painter: _FoxPainter(),
          ),
        );
      },
    );
  }
}

class _FoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body
    canvas.drawOval(
      Rect.fromLTWH(w * 0.2, h * 0.40, w * 0.60, h * 0.45),
      Paint()..color = const Color(0xFFE8A040),
    );

    // Head
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.38),
      w * 0.26,
      Paint()..color = const Color(0xFFE8A040),
    );

    // White face patch
    canvas.drawOval(
      Rect.fromLTWH(w * 0.30, h * 0.30, w * 0.40, h * 0.22),
      Paint()..color = const Color(0xFFFFF5E0),
    );

    // Left ear
    final leftEar = Path()
      ..moveTo(w * 0.28, h * 0.18)
      ..lineTo(w * 0.18, h * 0.02)
      ..lineTo(w * 0.40, h * 0.15)
      ..close();
    canvas.drawPath(leftEar, Paint()..color = const Color(0xFFE8A040));
    final leftEarInner = Path()
      ..moveTo(w * 0.28, h * 0.17)
      ..lineTo(w * 0.21, h * 0.06)
      ..lineTo(w * 0.37, h * 0.15)
      ..close();
    canvas.drawPath(leftEarInner, Paint()..color = const Color(0xFFD4606A));

    // Right ear
    final rightEar = Path()
      ..moveTo(w * 0.72, h * 0.18)
      ..lineTo(w * 0.82, h * 0.02)
      ..lineTo(w * 0.60, h * 0.15)
      ..close();
    canvas.drawPath(rightEar, Paint()..color = const Color(0xFFE8A040));
    final rightEarInner = Path()
      ..moveTo(w * 0.72, h * 0.17)
      ..lineTo(w * 0.79, h * 0.06)
      ..lineTo(w * 0.63, h * 0.15)
      ..close();
    canvas.drawPath(rightEarInner, Paint()..color = const Color(0xFFD4606A));

    // Eyes
    canvas.drawCircle(
      Offset(w * 0.40, h * 0.35),
      w * 0.055,
      Paint()..color = const Color(0xFF3D2B1F),
    );
    canvas.drawCircle(
      Offset(w * 0.60, h * 0.35),
      w * 0.055,
      Paint()..color = const Color(0xFF3D2B1F),
    );
    // Eye shine
    canvas.drawCircle(
      Offset(w * 0.42, h * 0.33),
      w * 0.02,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.62, h * 0.33),
      w * 0.02,
      Paint()..color = Colors.white,
    );

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.43), width: w * 0.10, height: w * 0.07),
      Paint()..color = const Color(0xFF3D2B1F),
    );

    // Smile
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.45), width: w * 0.20, height: w * 0.12),
      0, math.pi, false,
      Paint()
        ..color = const Color(0xFF3D2B1F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Tail
    final tail = Path()
      ..moveTo(w * 0.72, h * 0.70)
      ..quadraticBezierTo(w * 1.1, h * 0.85, w * 0.95, h * 1.0)
      ..quadraticBezierTo(w * 0.75, h * 0.90, w * 0.68, h * 0.72);
    canvas.drawPath(tail, Paint()..color = const Color(0xFFE8A040));
    final tailTip = Path()
      ..moveTo(w * 0.90, h * 0.96)
      ..quadraticBezierTo(w * 1.05, h * 1.05, w * 0.95, h * 1.0)
      ..quadraticBezierTo(w * 0.80, h * 0.98, w * 0.88, h * 0.94);
    canvas.drawPath(tailTip, Paint()..color = Colors.white);

    // Legs
    for (final dx in [0.30, 0.55]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * dx, h * 0.78, w * 0.13, h * 0.20),
          const Radius.circular(8),
        ),
        Paint()..color = const Color(0xFFCC8830),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Gift box ──────────────────────────────────────────────────────────────────

class _GiftBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(56, 60),
      painter: _GiftPainter(),
    );
  }
}

class _GiftPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Box body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.35, w, h * 0.65),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF7B68EE),
    );

    // Lid
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w * 0.05, h * 0.28, w * 1.10, h * 0.20),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF9B88FF),
    );

    // Ribbon vertical
    canvas.drawRect(
      Rect.fromLTWH(w * 0.42, h * 0.28, w * 0.16, h * 0.72),
      Paint()..color = const Color(0xFFFF6B9D),
    );

    // Ribbon horizontal
    canvas.drawRect(
      Rect.fromLTWH(-w * 0.05, h * 0.34, w * 1.10, h * 0.14),
      Paint()..color = const Color(0xFFFF6B9D),
    );

    // Bow left loop
    final bowLeft = Path()
      ..moveTo(w * 0.50, h * 0.28)
      ..quadraticBezierTo(w * 0.15, h * 0.00, w * 0.20, h * 0.22)
      ..quadraticBezierTo(w * 0.30, h * 0.28, w * 0.50, h * 0.28);
    canvas.drawPath(bowLeft, Paint()..color = const Color(0xFFFF8CB6));

    // Bow right loop
    final bowRight = Path()
      ..moveTo(w * 0.50, h * 0.28)
      ..quadraticBezierTo(w * 0.85, h * 0.00, w * 0.80, h * 0.22)
      ..quadraticBezierTo(w * 0.70, h * 0.28, w * 0.50, h * 0.28);
    canvas.drawPath(bowRight, Paint()..color = const Color(0xFFFF8CB6));

    // Bow center knot
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.28),
      w * 0.10,
      Paint()..color = const Color(0xFFFF6B9D),
    );

    // Dots on box
    for (final pos in [Offset(w * 0.20, h * 0.65), Offset(w * 0.72, h * 0.70)]) {
      canvas.drawCircle(pos, w * 0.07, Paint()..color = const Color(0xFF9B88FF));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
