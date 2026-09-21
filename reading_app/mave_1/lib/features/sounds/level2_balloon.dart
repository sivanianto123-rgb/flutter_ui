import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/gemini_live_service.dart';
import '../../widgets/mave_npc.dart';
import 'level3_letter_find.dart';

// ---------------------------------------------------------------------------
// Level 2 – Balloon tap-and-learn
// Pop 3 balloons to unlock the Next arrow, then advance to Level 3.
// ---------------------------------------------------------------------------

const _kBalloonCount = 6;
const _kBalloonColors = [
  AppColors.balloon1,
  AppColors.balloon2,
  AppColors.balloon3,
  AppColors.balloon4,
  AppColors.balloon5,
];

class Level2Balloon extends ConsumerStatefulWidget {
  const Level2Balloon({super.key});

  @override
  ConsumerState<Level2Balloon> createState() => _Level2BalloonState();
}

class _Level2BalloonState extends ConsumerState<Level2Balloon>
    with TickerProviderStateMixin {
  late final List<_BalloonModel> _balloons;
  int _poppedCount = 0;
  bool _showNext = false;
  bool _transitioning = false;
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _balloons = List.generate(_kBalloonCount, (i) {
      final color = _kBalloonColors[i % _kBalloonColors.length];
      return _BalloonModel(
        id: i,
        color: color,
        posX: 0.1 + (i % 3) * 0.35,
        posY: 0.15 + (i ~/ 3) * 0.4,
        ctrl: AnimationController(
          vsync: this,
          duration: Duration(seconds: 3 + (i % 3)),
        )..repeat(reverse: true),
      );
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    for (final b in _balloons) {
      b.ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _onBalloonTap(int id) async {
    if (_transitioning) return;
    final idx = _balloons.indexWhere((b) => b.id == id && !b.popped);
    if (idx == -1) return;

    setState(() => _balloons[idx].popped = true);
    _poppedCount++;

    final player = ref.read(audioPlayerServiceProvider);
    await player.playPop();

    await ref.read(geminiServiceProvider).speak('Ma!');

    if (_poppedCount >= 3 && !_showNext) {
      setState(() => _showNext = true);
    }
  }

  void _onNextTap() {
    if (_transitioning) return;
    _confetti.play();
    Future.delayed(const Duration(milliseconds: 600), _goNext);
  }

  void _goNext() {
    if (_transitioning || !mounted) return;
    _transitioning = true;
    ref.read(maveStateProvider.notifier).state = MaveState.idle;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const Level3LetterFind(),
        transitionsBuilder: (ctx, anim, anim2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Listener(
        onPointerMove: (e) {
          ref.read(touchPositionProvider.notifier).state = (
            e.position.dx / size.width,
            e.position.dy / size.height,
          );
        },
        child: Stack(
          children: [
            // Balloons
            ..._balloons.map((b) => _BalloonWidget(
                  model: b,
                  screenSize: size,
                  onTap: () => _onBalloonTap(b.id),
                )),
            // Mave at bottom
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  _HintBubble(poppedCount: _poppedCount),
                  const SizedBox(height: 8),
                  const MaveNPC(size: 160),
                ],
              ),
            ),
            // Next arrow — appears after 3 pops
            if (_showNext)
              Positioned(
                bottom: 36,
                right: 36,
                child: _NextArrow(onTap: _onNextTap),
              ),
            // Confetti
            Positioned(
              top: 0,
              left: size.width / 2,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirection: math.pi / 2,
                numberOfParticles: 30,
                gravity: 0.3,
                colors: _kBalloonColors,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Next arrow button (pulsing)
// ---------------------------------------------------------------------------

class _NextArrow extends StatefulWidget {
  final VoidCallback onTap;
  const _NextArrow({required this.onTap});

  @override
  State<_NextArrow> createState() => _NextArrowState();
}

class _NextArrowState extends State<_NextArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.cardSounds,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.cardSounds.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Models & sub-widgets
// ---------------------------------------------------------------------------

class _BalloonModel {
  final int id;
  final Color color;
  final double posX;
  final double posY;
  final AnimationController ctrl;
  bool popped = false;

  _BalloonModel({
    required this.id,
    required this.color,
    required this.posX,
    required this.posY,
    required this.ctrl,
  });
}

class _BalloonWidget extends StatelessWidget {
  final _BalloonModel model;
  final Size screenSize;
  final VoidCallback onTap;

  const _BalloonWidget({
    required this.model,
    required this.screenSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (model.popped) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: model.ctrl,
      builder: (context, _) {
        final floatY = -12.0 * model.ctrl.value;
        return Positioned(
          left: model.posX * screenSize.width - 70,
          top: model.posY * screenSize.height + floatY - 70,
          child: GestureDetector(
            onTap: onTap,
            child: _BalloonPainterWidget(color: model.color),
          ),
        );
      },
    );
  }
}

class _BalloonPainterWidget extends StatelessWidget {
  final Color color;
  const _BalloonPainterWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 170,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: const Size(140, 160),
            painter: _BalloonPainter(color: color),
          ),
          Positioned(
            top: 50,
            child: Text(
              'ma',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  final Color color;
  const _BalloonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadow = Paint()
      ..color = Colors.black26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final rx = size.width * 0.46;
    final ry = size.height * 0.48;

    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        shadow);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        paint);

    // Highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - rx * 0.2, cy - ry * 0.3),
        width: rx * 0.4,
        height: ry * 0.25,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // String
    final stringPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(cx, cy + ry)
      ..quadraticBezierTo(cx + 8, cy + ry + 12, cx, cy + ry + 24);
    canvas.drawPath(path, stringPaint);
  }

  @override
  bool shouldRepaint(_BalloonPainter old) => old.color != color;
}

class _HintBubble extends StatelessWidget {
  final int poppedCount;
  const _HintBubble({required this.poppedCount});

  @override
  Widget build(BuildContext context) {
    if (poppedCount >= 3) return const SizedBox.shrink();
    final remaining = 3 - poppedCount;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Text(
        'Pop $remaining more balloon${remaining == 1 ? '' : 's'}!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.bgDeep,
        ),
      ),
    );
  }
}
