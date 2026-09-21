import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/syllable_utils.dart';

/// Which crate the train carries for this zone.
enum TrainCrateMode { vowelsOnly, consonantsOnly }

/// Letter + picture label for a floating airship.
class TrainSortItem {
  const TrainSortItem({
    required this.letter,
    required this.word,
    required this.icon,
  });

  final String letter;
  final String word;
  final IconData icon;

  bool get isVowelLetter => isVowel(letter);
}

/// Desert train game: tap floating letter airships so they drop into the
/// zone's crate (vowel-only or consonant-only).
class TrainSortGame extends StatefulWidget {
  const TrainSortGame({
    super.key,
    required this.items,
    required this.onComplete,
    required this.mode,
    this.targetCount = 8,
  });

  final List<TrainSortItem> items;
  final VoidCallback onComplete;
  final TrainCrateMode mode;
  final int targetCount;

  @override
  State<TrainSortGame> createState() => _TrainSortGameState();
}

class _TrainSortGameState extends State<TrainSortGame>
    with TickerProviderStateMixin {
  late final AnimationController _sky;
  late final AnimationController _train;
  late final List<_AirshipState> _ships;
  final List<_FallingLetter> _falling = [];
  int _score = 0;
  bool _finished = false;

  // Single crate sits after engine + passenger (~62% along the train).
  static const _crateFrac = 0.62;
  static const _trainWidthFrac = 0.78;

  bool get _wantVowels => widget.mode == TrainCrateMode.vowelsOnly;

  @override
  void initState() {
    super.initState();
    _sky = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _train = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    final rng = math.Random(7);
    _ships = List.generate(widget.items.length, (i) {
      final item = widget.items[i];
      return _AirshipState(
        item: item,
        // stagger horizontal start so they enter at different times
        startX: -0.15 - (i * 0.22) - rng.nextDouble() * 0.08,
        yFrac: 0.10 + (i % 3) * 0.14 + rng.nextDouble() * 0.04,
        speed: 0.045 + rng.nextDouble() * 0.025,
        bobPhase: rng.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _sky.dispose();
    _train.dispose();
    super.dispose();
  }

  void _onTapShip(_AirshipState ship, Size size, BuildContext context) {
    if (ship.caught || _finished) return;

    final isMatch = _wantVowels
        ? ship.item.isVowelLetter
        : !ship.item.isVowelLetter;
    if (!isMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _wantVowels
                ? 'Only vowels go in this crate! Look for A E I O U'
                : 'Only consonants go in this crate!',
          ),
          duration: const Duration(milliseconds: 900),
        ),
      );
      return;
    }

    final t = _sky.value;
    final wrapped = (ship.startX + t * ship.speed * 14);
    final frac = wrapped - wrapped.floorToDouble();
    final xFrac = frac * 1.3 - 0.15;
    if (xFrac < -0.2 || xFrac > 1.15) return;

    final shipX = xFrac * size.width;
    final shipY = ship.yFrac * size.height;

    setState(() {
      ship.caught = true;
      _falling.add(
        _FallingLetter(
          letter: ship.item.letter,
          isVowel: ship.item.isVowelLetter,
          from: Offset(shipX, shipY),
          crateFrac: _crateFrac,
          started: DateTime.now(),
        ),
      );
      _score += 1;
    });

    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _falling.removeWhere(
          (f) => DateTime.now().difference(f.started).inMilliseconds >= 850,
        );
      });

      if (_score >= widget.targetCount && !_finished) {
        _finished = true;
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onComplete();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Desert backdrop
              const Positioned.fill(child: CustomPaint(painter: _DesertPainter())),

              // Moving clouds + airships + falling letters + train
              AnimatedBuilder(
                animation: Listenable.merge([_sky, _train]),
                builder: (context, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // clouds
                      ..._buildClouds(size),
                      // airships
                      ..._buildShips(size),
                      // falling letters
                      ..._buildFalling(size),
                      // train
                      _buildTrain(size),
                      // cactus in foreground
                      Positioned(
                        left: 8,
                        bottom: size.height * 0.12,
                        child: CustomPaint(
                          size: Size(size.width * 0.14, size.height * 0.22),
                          painter: const _CactusPainter(),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // HUD
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              (_score / widget.targetCount).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Color(0xFF81C784), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$_score / ${widget.targetCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // instruction banner
              Positioned(
                top: 36,
                left: 16,
                right: 16,
                child: Text(
                  'Tap ${_wantVowels ? "vowel" : "consonant"} letters — they drop into the crate!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: Color(0xAA000000), blurRadius: 6),
                    ],
                  ),
                ),
              ),

              if (_finished)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    alignment: Alignment.center,
                    child: const Text(
                      'All aboard!',
                      style: TextStyle(
                        color: Color(0xFFFFF59D),
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: Color(0xAA000000), blurRadius: 8),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                      ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildClouds(Size size) {
    final t = _sky.value;
    final clouds = <Widget>[];
    for (var i = 0; i < 5; i++) {
      final x = ((t * 0.3 + i * 0.22) % 1.3 - 0.15) * size.width;
      final y = size.height * (0.08 + (i % 3) * 0.12);
      clouds.add(
        Positioned(
          left: x,
          top: y,
          child: CustomPaint(
            size: Size(70 + i * 10.0, 36 + i * 4.0),
            painter: const _CloudPainter(),
          ),
        ),
      );
    }
    return clouds;
  }

  List<Widget> _buildShips(Size size) {
    final t = _sky.value;
    final widgets = <Widget>[];
    for (final ship in _ships) {
      if (ship.caught) continue;
      final xFrac = (ship.startX + t * ship.speed * 14);
      // wrap around
      final wrapped = xFrac - xFrac.floorToDouble();
      // only show when roughly on screen (allow slight overflow)
      final x = (wrapped * 1.3 - 0.15) * size.width;
      final bob = math.sin((t + ship.bobPhase) * math.pi * 4) * 6;
      final y = ship.yFrac * size.height + bob;

      widgets.add(
        Positioned(
          left: x,
          top: y,
          child: GestureDetector(
            onTap: () => _onTapShip(ship, size, context),
            child: _AirshipCard(item: ship.item),
          ),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildFalling(Size size) {
    final now = DateTime.now();
    final trainLeft = (_train.value * 1.55 - 0.35) * size.width;
    final trainW = size.width * _trainWidthFrac;
    final targetY = size.height * 0.78;

    return _falling.map((f) {
      final elapsed = now.difference(f.started).inMilliseconds / 900.0;
      final t = elapsed.clamp(0.0, 1.0);
      final eased = Curves.easeInCubic.transform(t);
      final targetX = trainLeft + trainW * f.crateFrac;
      final x = f.from.dx + (targetX - f.from.dx) * eased;
      final y = f.from.dy + (targetY - f.from.dy) * eased;
      return Positioned(
        left: x - 22,
        top: y - 22,
        child: Opacity(
          opacity: (1 - t * 0.3).clamp(0.0, 1.0),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: f.isVowel
                  ? const Color(0xFFFFD54F)
                  : const Color(0xFF81C784),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              f.letter.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3E2723),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTrain(Size size) {
    // Loop: enter from left, exit right
    final trainLeft = (_train.value * 1.55 - 0.35) * size.width;
    final trainW = size.width * _trainWidthFrac;
    final trainH = size.height * 0.22;

    return Positioned(
      left: trainLeft,
      bottom: size.height * 0.02,
      child: SizedBox(
        width: trainW,
        height: trainH,
        child: CustomPaint(
          painter: _TrainPainter(
            crateLabel: _wantVowels ? 'vowel' : 'consonant',
          ),
        ),
      ),
    );
  }
}

// ─── State helpers ───────────────────────────────────────────────────────────

class _AirshipState {
  _AirshipState({
    required this.item,
    required this.startX,
    required this.yFrac,
    required this.speed,
    required this.bobPhase,
  });

  final TrainSortItem item;
  final double startX;
  final double yFrac;
  final double speed;
  final double bobPhase;
  bool caught = false;
}

class _FallingLetter {
  _FallingLetter({
    required this.letter,
    required this.isVowel,
    required this.from,
    required this.crateFrac,
    required this.started,
  });

  final String letter;
  final bool isVowel;
  final Offset from;
  final double crateFrac;
  final DateTime started;
}

// ─── Airship card widget ─────────────────────────────────────────────────────

class _AirshipCard extends StatelessWidget {
  const _AirshipCard({required this.item});
  final TrainSortItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // blimp body
          CustomPaint(
            size: const Size(88, 100),
            painter: _BlimpPainter(
              accent: item.isVowelLetter
                  ? const Color(0xFFFFB74D)
                  : const Color(0xFF90CAF9),
            ),
          ),
          // content panel
          Positioned(
            top: 18,
            child: Container(
              width: 58,
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFB0BEC5), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 28,
                    color: item.isVowelLetter
                        ? const Color(0xFFEF6C00)
                        : const Color(0xFF1565C0),
                  ),
                  Text(
                    item.letter.toLowerCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'serif',
                      color: Color(0xFF212121),
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Painters ────────────────────────────────────────────────────────────────

class _DesertPainter extends CustomPainter {
  const _DesertPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // sky gradient — dusk purple/blue like the screenshot
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF9FA8DA),
          Color(0xFFB39DDB),
          Color(0xFFCE93D8),
          Color(0xFFE1BEE7),
          Color(0xFFFFCC80),
        ],
        stops: [0.0, 0.25, 0.45, 0.65, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    // distant mountains
    final m1 = Paint()..color = const Color(0xFF7E57C2).withValues(alpha: 0.55);
    final m2 = Paint()..color = const Color(0xFF5E35B1).withValues(alpha: 0.45);
    final path1 = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
          size.width * 0.2, size.height * 0.32, size.width * 0.4, size.height * 0.52)
      ..quadraticBezierTo(
          size.width * 0.55, size.height * 0.38, size.width * 0.7, size.height * 0.55)
      ..quadraticBezierTo(
          size.width * 0.85, size.height * 0.42, size.width, size.height * 0.50)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, m1);

    final path2 = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.48, size.width * 0.5, size.height * 0.60)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.50, size.width, size.height * 0.58)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, m2);

    // ground / desert floor
    final ground = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFFD7CCC8),
          Color(0xFFBCAAA4),
          Color(0xFFA1887F),
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.70, size.width, size.height * 0.30),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.70, size.width, size.height * 0.30),
      ground,
    );

    // tracks
    final rail = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final y1 = size.height * 0.90;
    final y2 = size.height * 0.935;
    canvas.drawLine(Offset(0, y1), Offset(size.width, y1), rail);
    canvas.drawLine(Offset(0, y2), Offset(size.width, y2), rail);
    final sleeper = Paint()..color = const Color(0xFF6D4C41);
    for (var x = 0.0; x < size.width; x += 18) {
      canvas.drawRect(Rect.fromLTWH(x, y1 - 2, 10, y2 - y1 + 4), sleeper);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF90A4AE).withValues(alpha: 0.55);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.55),
        width: size.width * 0.55,
        height: size.height * 0.55,
      ),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.6, size.height * 0.45),
        width: size.width * 0.5,
        height: size.height * 0.6,
      ),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.75, size.height * 0.6),
        width: size.width * 0.4,
        height: size.height * 0.45,
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CactusPainter extends CustomPainter {
  const _CactusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF558B2F);
    final dark = Paint()..color = const Color(0xFF33691E);

    // main trunk
    final trunk = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.15, size.width * 0.3, size.height * 0.85),
      const Radius.circular(12),
    );
    canvas.drawRRect(trunk, green);

    // left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.35, size.width * 0.35, size.height * 0.14),
        const Radius.circular(10),
      ),
      green,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.20, size.width * 0.16, size.height * 0.28),
        const Radius.circular(10),
      ),
      green,
    );

    // right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.45, size.width * 0.35, size.height * 0.14),
        const Radius.circular(10),
      ),
      green,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.74, size.height * 0.30, size.width * 0.16, size.height * 0.28),
        const Radius.circular(10),
      ),
      green,
    );

    // ridges
    final ridge = Paint()
      ..color = const Color(0xFF7CB342).withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.95),
      ridge,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.12),
      size.width * 0.08,
      dark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlimpPainter extends CustomPainter {
  const _BlimpPainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFECEFF1),
          const Color(0xFFB0BEC5),
          const Color(0xFF78909C),
        ],
      ).createShader(Offset.zero & size);

    // main oval hull
    final hull = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.05,
      size.width * 0.9,
      size.height * 0.55,
    );
    canvas.drawOval(hull, body);

    // accent stripe
    final stripe = Paint()..color = accent.withValues(alpha: 0.7);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.28,
        size.width * 0.8,
        size.height * 0.12,
      ),
      stripe,
    );

    // gondola / fins
    final fin = Paint()..color = const Color(0xFF607D8B);
    final finPath = Path()
      ..moveTo(size.width * 0.85, size.height * 0.25)
      ..lineTo(size.width * 0.98, size.height * 0.15)
      ..lineTo(size.width * 0.98, size.height * 0.40)
      ..close();
    canvas.drawPath(finPath, fin);

    // gondola box under hull
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.28,
          size.height * 0.52,
          size.width * 0.44,
          size.height * 0.42,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF546E7A),
    );
  }

  @override
  bool shouldRepaint(covariant _BlimpPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _TrainPainter extends CustomPainter {
  const _TrainPainter({required this.crateLabel});
  final String crateLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF2E7D32);
    final darkGreen = Paint()..color = const Color(0xFF1B5E20);
    final gold = Paint()..color = const Color(0xFFFFB300);
    final black = Paint()..color = const Color(0xFF212121);
    final cream = Paint()..color = const Color(0xFFFFF8E1);

    final h = size.height;
    final w = size.width;

    // engine ~28% | passenger ~22% | single crate ~42%
    final engineW = w * 0.28;
    final passW = w * 0.22;
    final crateW = w * 0.42;
    final bodyY = h * 0.22;
    final bodyH = h * 0.52;
    final wheelY = h * 0.78;

    double x = 0;

    // ── Engine (facing right) ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + engineW * 0.15, bodyY + bodyH * 0.15, engineW * 0.7, bodyH * 0.7),
        const Radius.circular(8),
      ),
      green,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, bodyY, engineW * 0.4, bodyH),
        const Radius.circular(4),
      ),
      darkGreen,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 2, bodyY - h * 0.08, engineW * 0.44, h * 0.1),
        const Radius.circular(3),
      ),
      black,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + engineW * 0.55, bodyY - h * 0.18, engineW * 0.14, h * 0.22),
        const Radius.circular(2),
      ),
      black,
    );
    canvas.drawCircle(
      Offset(x + engineW * 0.88, bodyY + bodyH * 0.4),
      h * 0.07,
      gold,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + engineW * 0.08, bodyY + bodyH * 0.35, engineW * 0.22, bodyH * 0.3),
        const Radius.circular(3),
      ),
      cream,
    );
    _drawText(canvas, '3', Offset(x + engineW * 0.19, bodyY + bodyH * 0.5), 14, const Color(0xFF1B5E20));

    _wheel(canvas, Offset(x + engineW * 0.25, wheelY), h * 0.14, black, gold);
    _wheel(canvas, Offset(x + engineW * 0.65, wheelY), h * 0.14, black, gold);

    x += engineW + w * 0.015;

    // ── Passenger car ──
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, bodyY + bodyH * 0.1, passW, bodyH * 0.9),
        const Radius.circular(4),
      ),
      green,
    );
    for (var i = 0; i < 3; i++) {
      final wx = x + passW * 0.12 + i * passW * 0.28;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(wx, bodyY + bodyH * 0.25, passW * 0.22, bodyH * 0.4),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFFBBDEFB),
      );
      canvas.drawCircle(
        Offset(wx + passW * 0.11, bodyY + bodyH * 0.4),
        passW * 0.06,
        black,
      );
    }
    _wheel(canvas, Offset(x + passW * 0.3, wheelY), h * 0.1, black, gold);
    _wheel(canvas, Offset(x + passW * 0.7, wheelY), h * 0.1, black, gold);

    x += passW + w * 0.02;

    // ── Single zone crate ──
    _drawCrate(
      canvas,
      x,
      bodyY,
      crateW,
      bodyH,
      wheelY,
      h,
      crateLabel,
      green,
      darkGreen,
      cream,
      black,
      gold,
    );
  }

  void _drawCrate(
    Canvas canvas,
    double x,
    double bodyY,
    double crateW,
    double bodyH,
    double wheelY,
    double h,
    String label,
    Paint green,
    Paint darkGreen,
    Paint cream,
    Paint black,
    Paint gold,
  ) {
    // open-top crate
    final crateRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, bodyY + bodyH * 0.05, crateW, bodyH * 0.95),
      const Radius.circular(4),
    );
    canvas.drawRRect(crateRect, green);

    // inner darker panel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x + crateW * 0.08,
          bodyY + bodyH * 0.2,
          crateW * 0.84,
          bodyH * 0.55,
        ),
        const Radius.circular(3),
      ),
      darkGreen,
    );

    // label
    _drawText(
      canvas,
      label,
      Offset(x + crateW / 2, bodyY + bodyH * 0.48),
      label.length > 6 ? 13 : 16,
      const Color(0xFFFFF59D),
    );

    // rim highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, bodyY + bodyH * 0.05, crateW, bodyH * 0.12),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF66BB6A).withValues(alpha: 0.5),
    );

    _wheel(canvas, Offset(x + crateW * 0.28, wheelY), h * 0.1, black, gold);
    _wheel(canvas, Offset(x + crateW * 0.72, wheelY), h * 0.1, black, gold);
  }

  void _wheel(Canvas canvas, Offset c, double r, Paint black, Paint gold) {
    canvas.drawCircle(c, r, black);
    canvas.drawCircle(c, r * 0.55, gold);
    canvas.drawCircle(c, r * 0.2, black);
  }

  void _drawText(Canvas canvas, String text, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          color: color,
          fontFamily: 'serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TrainPainter oldDelegate) =>
      oldDelegate.crateLabel != crateLabel;
}
