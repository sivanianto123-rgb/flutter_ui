import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/milestone_model.dart';
import '../../core/models/sound_node.dart';
import '../../core/services/app_providers.dart';
import '../sound_mode/screens/sound_mode_screen.dart';
import 'home_game.dart';
import 'widgets/parent_insights_overlay.dart';

// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  bool _insightsOpen = false;
  late final HomeBackgroundGame _game;

  late final AnimationController _pulseController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _game = HomeBackgroundGame();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _openInsights()  => setState(() => _insightsOpen = true);
  void _closeInsights() => setState(() => _insightsOpen = false);

  void _onNodeTap(SoundNode node, NodeStatus status) {
    if (status == NodeStatus.locked) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:        (ctx, anim, sec) => SoundModeScreen(
          syllable: node.id,
          onFinish: () { if (mounted) Navigator.of(context).pop(); },
        ),
        transitionsBuilder: (ctx, anim, sec, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile         = ref.watch(childProfileProvider);
    final name            = profile?.name ?? 'Friend';
    final accuracyMap     = ref.watch(soundAccuracyProvider);
    final milestonesAsync = ref.watch(milestonesStreamProvider);
    final sessions = milestonesAsync.when(
      data:    (s) => s,
      loading: ()  => <BabyDevelopment>[],
      error:   (e, _) => <BabyDevelopment>[],
    );

    final nodes = SoundNode.curriculum;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Flame background ──────────────────────────────────────────────
          GameWidget(game: _game),

          // ── Gradient overlay to give depth ────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end:   Alignment.bottomCenter,
                colors: [
                  Color(0x000D1B3E),
                  Color(0x400D1B3E),
                  Color(0x990D1B3E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Main game level content ───────────────────────────────────────
          SafeArea(
            child: Stack(
              children: [
                // ── Header row ────────────────────────────────────────────────
                Positioned(
                  top: 16, left: 20, right: 20,
                  child: Row(
                    children: [
                      // Star count badge
                      _StarsBadge(stars: profile?.totalStars ?? 0),
                      const Spacer(),
                      // Profile / insights button
                      _ProfileButton(
                        name:    name,
                        mastery: _overallMastery(accuracyMap),
                        onTap:   _openInsights,
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms),
                ),

                // ── Title card ────────────────────────────────────────────────
                Positioned(
                  top: 80, left: 24, right: 24,
                  child: Column(
                    children: [
                      Text(
                        'Hi, $name!',
                        style: const TextStyle(
                          fontSize:   32,
                          fontWeight: FontWeight.w900,
                          color:      Colors.white,
                          shadows: [Shadow(blurRadius: 12, color: Color(0x66000000))],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color:        Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border:       Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'Choose your adventure!',
                          style: TextStyle(
                            fontSize:   15,
                            color:      Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms)
                   .slideY(begin: -0.3, end: 0),
                ),

                // ── Level nodes (game map) ────────────────────────────────────
                _GameLevelMap(
                  nodes:            nodes,
                  accuracyMap:      accuracyMap,
                  pulseController:  _pulseController,
                  floatController:  _floatController,
                  onNodeTap:        _onNodeTap,
                ),

                // ── Bottom progress bar ───────────────────────────────────────
                Positioned(
                  bottom: 16, left: 24, right: 24,
                  child: _ProgressBar(accuracyMap: accuracyMap),
                ),
              ],
            ),
          ),

          // ── Parent Insights overlay ───────────────────────────────────────
          if (_insightsOpen)
            ParentInsightsOverlay(
              sessions:  sessions,
              childName: name,
              onClose:   _closeInsights,
            ),
        ],
      ),
    );
  }

  double _overallMastery(Map<String, double> map) {
    if (map.isEmpty) return 0.0;
    return (map.values.fold(0.0, (s, a) => s + a) / map.length).clamp(0.0, 1.0);
  }
}

// ── Game level map ─────────────────────────────────────────────────────────────

class _GameLevelMap extends StatelessWidget {
  const _GameLevelMap({
    required this.nodes,
    required this.accuracyMap,
    required this.pulseController,
    required this.floatController,
    required this.onNodeTap,
  });

  final List<SoundNode>                          nodes;
  final Map<String, double>                      accuracyMap;
  final AnimationController                      pulseController;
  final AnimationController                      floatController;
  final void Function(SoundNode, NodeStatus)     onNodeTap;

  // Node positions as fractions of screen (from bottom)
  static const _positions = [
    Alignment(-0.55, 0.65),   // Ma — bottom-left
    Alignment(0.35, 0.05),    // Pa — mid-right
    Alignment(-0.20, -0.62),  // Ma+Pa — upper-center
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            for (int i = 0; i < nodes.length; i++)
              _buildNode(context, nodes[i], i),
          ],
        );
      },
    );
  }

  Widget _buildNode(BuildContext context, SoundNode node, int index) {
    final status  = node.statusFor(accuracyMap);
    final accuracy = accuracyMap[node.id] ?? 0.0;
    final align   = _positions[index];

    Widget nodeWidget = _LevelNode(
      node:             node,
      status:           status,
      accuracy:         accuracy,
      index:            index,
      floatController:  floatController,
      onTap:            () => onNodeTap(node, status),
    );

    return Align(
      alignment: align,
      child: nodeWidget
          .animate(delay: Duration(milliseconds: 200 + index * 150))
          .fadeIn(duration: 600.ms)
          .scale(
            begin: const Offset(0.3, 0.3),
            end:   const Offset(1.0, 1.0),
            curve: Curves.elasticOut,
            duration: 800.ms,
          ),
    );
  }
}

// ── Single level node ──────────────────────────────────────────────────────────

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.node,
    required this.status,
    required this.accuracy,
    required this.index,
    required this.floatController,
    required this.onTap,
  });

  final SoundNode            node;
  final NodeStatus           status;
  final double               accuracy;
  final int                  index;
  final AnimationController  floatController;
  final VoidCallback         onTap;

  static const _nodeColors = [
    AppColors.maNodeColor,   // Ma — coral red
    AppColors.paNodeColor,   // Pa — teal
    AppColors.comboColor,    // Ma+Pa — gold
  ];

  static const _iconColors = [
    Color(0xFFB33A3A),
    Color(0xFF2E8B84),
    Color(0xFFB8970A),
  ];

  @override
  Widget build(BuildContext context) {
    final isLocked   = status == NodeStatus.locked;
    final isMastered = status == NodeStatus.mastered;
    final isCombo    = node.prerequisites.isNotEmpty;
    final baseColor  = isLocked ? AppColors.lockedGray : _nodeColors[index];
    final iconColor  = _iconColors[index];
    final nodeSize   = isCombo ? 130.0 : 120.0;

    Widget content = GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedBuilder(
        animation: floatController,
        builder: (ctx, child) {
          final floatOffset = math.sin(floatController.value * math.pi + index * 1.2) * 8.0;
          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: child,
          );
        },
        child: _NodeBody(
          node:      node,
          status:    status,
          accuracy:  accuracy,
          index:     index,
          baseColor: baseColor,
          iconColor: iconColor,
          isLocked:  isLocked,
          isMastered:isMastered,
          isCombo:   isCombo,
          nodeSize:  nodeSize,
        ),
      ),
    );

    // Pulse animation for available nodes
    if (status == NodeStatus.available) {
      content = content
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end:   const Offset(1.06, 1.06),
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }

    return content;
  }
}

// ── Node body ─────────────────────────────────────────────────────────────────

class _NodeBody extends StatelessWidget {
  const _NodeBody({
    required this.node,
    required this.status,
    required this.accuracy,
    required this.index,
    required this.baseColor,
    required this.iconColor,
    required this.isLocked,
    required this.isMastered,
    required this.isCombo,
    required this.nodeSize,
  });

  final SoundNode  node;
  final NodeStatus status;
  final double     accuracy;
  final int        index;
  final Color      baseColor;
  final Color      iconColor;
  final bool       isLocked;
  final bool       isMastered;
  final bool       isCombo;
  final double     nodeSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Accuracy badge above node ─────────────────────────────────────
        if (!isLocked)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:        Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(
                color: isMastered ? AppColors.accentGreen : baseColor,
                width: 1.5,
              ),
            ),
            child: Text(
              isMastered
                  ? 'Mastered!'
                  : '${(accuracy * 100).round()}%',
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w800,
                color: isMastered ? AppColors.accentGreen : Colors.white,
              ),
            ),
          ),

        // ── Main node button ──────────────────────────────────────────────
        Container(
          width:  nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            shape: isCombo ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isCombo ? BorderRadius.circular(28) : null,
            gradient: RadialGradient(
              colors: isLocked
                  ? [const Color(0xFF5A5A7A), const Color(0xFF3A3A5A)]
                  : [
                      baseColor.withOpacity(0.9),
                      Color.lerp(baseColor, Colors.black, 0.25)!,
                    ],
              center: const Alignment(-0.3, -0.3),
            ),
            boxShadow: [
              if (!isLocked) ...[
                BoxShadow(
                  color:      baseColor.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset:     const Offset(0, 6),
                ),
                BoxShadow(
                  color:      baseColor.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
              BoxShadow(
                color:      Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset:     const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isLocked
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.4),
              width: 3,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Inner glow circle
              if (!isLocked)
                Container(
                  width:  nodeSize * 0.7,
                  height: nodeSize * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),

              // Content
              if (isLocked)
                _LockIcon(size: nodeSize * 0.4)
              else if (isMastered)
                _MasteredContent(nodeSize: nodeSize, color: iconColor)
              else
                _NodeCharacter(index: index, nodeSize: nodeSize, node: node),

              // Shine overlay
              if (!isLocked)
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    width:  nodeSize * 0.3,
                    height: nodeSize * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Node label ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color:        Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            node.label,
            style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w900,
              color:      Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Lock icon ──────────────────────────────────────────────────────────────────

class _LockIcon extends StatelessWidget {
  const _LockIcon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LockPainter()),
    );
  }
}

class _LockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Shackle arc
    final shacklePath = Path()
      ..moveTo(w * 0.25, h * 0.52)
      ..lineTo(w * 0.25, h * 0.28)
      ..arcToPoint(
        Offset(w * 0.75, h * 0.28),
        radius: Radius.circular(w * 0.25),
        clockwise: false,
      )
      ..lineTo(w * 0.75, h * 0.52);
    canvas.drawPath(shacklePath, paint);

    // Body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.50, w * 0.70, h * 0.45),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(body, paint..style = PaintingStyle.fill..color = Colors.white.withOpacity(0.3));
    canvas.drawRRect(body, paint..style = PaintingStyle.stroke..color = Colors.white.withOpacity(0.6));

    // Keyhole
    canvas.drawCircle(Offset(w * 0.5, h * 0.70), w * 0.08,
        Paint()..color = Colors.white.withOpacity(0.6));
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.80), width: w * 0.08, height: w * 0.12),
      Paint()..color = Colors.white.withOpacity(0.6),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Mastered content ───────────────────────────────────────────────────────────

class _MasteredContent extends StatelessWidget {
  const _MasteredContent({required this.nodeSize, required this.color});
  final double nodeSize;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  nodeSize * 0.6,
      height: nodeSize * 0.6,
      child: CustomPaint(painter: _CheckStarPainter(color: color)),
    );
  }
}

class _CheckStarPainter extends CustomPainter {
  const _CheckStarPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = math.min(w, h) / 2;
    final center = Offset(w / 2, h / 2);

    // Draw 5-pointed star
    final starPaint = Paint()..color = AppColors.starGold;
    final starPath = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = -math.pi / 2 + i * 2 * math.pi / 5;
      final innerAngle = outerAngle + math.pi / 5;
      final outerPoint = Offset(
        center.dx + r * math.cos(outerAngle),
        center.dy + r * math.sin(outerAngle),
      );
      final innerPoint = Offset(
        center.dx + r * 0.38 * math.cos(innerAngle),
        center.dy + r * 0.38 * math.sin(innerAngle),
      );
      if (i == 0) {
        starPath.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        starPath.lineTo(outerPoint.dx, outerPoint.dy);
      }
      starPath.lineTo(innerPoint.dx, innerPoint.dy);
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);

    // Check mark
    final checkPaint = Paint()
      ..color       = Colors.white
      ..style       = PaintingStyle.stroke
      ..strokeWidth = r * 0.22
      ..strokeCap   = StrokeCap.round
      ..strokeJoin  = StrokeJoin.round;
    final checkPath = Path()
      ..moveTo(w * 0.28, h * 0.50)
      ..lineTo(w * 0.44, h * 0.66)
      ..lineTo(w * 0.72, h * 0.36);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Node character (drawn mascot) ─────────────────────────────────────────────

class _NodeCharacter extends StatelessWidget {
  const _NodeCharacter({
    required this.index,
    required this.nodeSize,
    required this.node,
  });
  final int      index;
  final double   nodeSize;
  final SoundNode node;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width:  nodeSize * 0.55,
          height: nodeSize * 0.45,
          child: CustomPaint(
            painter: index == 0
                ? _BearFacePainter()
                : index == 1
                    ? _ButterflyPainter()
                    : _SparkleStarPainter(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          node.label,
          style: const TextStyle(
            fontSize:   18,
            fontWeight: FontWeight.w900,
            color:      Colors.white,
            shadows: [Shadow(blurRadius: 6, color: Colors.black38)],
          ),
        ),
      ],
    );
  }
}

// ── Bear face painter ──────────────────────────────────────────────────────────

class _BearFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r  = math.min(w, h) * 0.42;

    // Main head
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = const Color(0xFF8B4513));
    // Snout
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + r * 0.35), width: r * 1.0, height: r * 0.55),
      Paint()..color = const Color(0xFFD2691E),
    );
    // Ears
    for (final dx in [-r * 0.68, r * 0.68]) {
      canvas.drawCircle(Offset(cx + dx, cy - r * 0.72), r * 0.30,
          Paint()..color = const Color(0xFF8B4513));
      canvas.drawCircle(Offset(cx + dx, cy - r * 0.72), r * 0.16,
          Paint()..color = const Color(0xFFD2691E));
    }
    // Eyes
    for (final dx in [-r * 0.30, r * 0.30]) {
      canvas.drawCircle(Offset(cx + dx, cy - r * 0.20), r * 0.13, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(cx + dx, cy - r * 0.20), r * 0.08, Paint()..color = Colors.black87);
      canvas.drawCircle(Offset(cx + dx - r * 0.04, cy - r * 0.25), r * 0.03, Paint()..color = Colors.white);
    }
    // Nose
    canvas.drawCircle(Offset(cx, cy + r * 0.15), r * 0.09,
        Paint()..color = Colors.black87);
    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF5A2D0C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + r * 0.20), width: r * 0.5, height: r * 0.3),
      0, math.pi, false, smilePaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Butterfly painter ──────────────────────────────────────────────────────────

class _ButterflyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Upper wings
    final wingPaint = Paint()..color = const Color(0xFF4ECDC4).withOpacity(0.9);
    final wingShadow = Paint()..color = const Color(0xFF2E9E96).withOpacity(0.8);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.30, cy - h * 0.20), width: w * 0.45, height: h * 0.50),
      wingPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.30, cy - h * 0.20), width: w * 0.45, height: h * 0.50),
      wingPaint,
    );
    // Lower wings
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.22, cy + h * 0.22), width: w * 0.32, height: h * 0.38),
      wingShadow,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.22, cy + h * 0.22), width: w * 0.32, height: h * 0.38),
      wingShadow,
    );
    // Wing dots
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.6);
    for (final (dx, dy) in [(-0.25, -0.22), (0.25, -0.22), (-0.18, 0.20), (0.18, 0.20)]) {
      canvas.drawCircle(Offset(cx + w * dx, cy + h * dy), w * 0.05, dotPaint);
    }
    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.10, height: h * 0.65),
      Paint()..color = const Color(0xFF1A5F5B),
    );
    // Antennae
    final antPaint = Paint()
      ..color = const Color(0xFF1A5F5B)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - w * 0.04, cy - h * 0.30), Offset(cx - w * 0.18, cy - h * 0.50), antPaint);
    canvas.drawLine(Offset(cx + w * 0.04, cy - h * 0.30), Offset(cx + w * 0.18, cy - h * 0.50), antPaint);
    canvas.drawCircle(Offset(cx - w * 0.18, cy - h * 0.52), w * 0.04, Paint()..color = const Color(0xFF1A5F5B));
    canvas.drawCircle(Offset(cx + w * 0.18, cy - h * 0.52), w * 0.04, Paint()..color = const Color(0xFF1A5F5B));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Sparkle star painter ───────────────────────────────────────────────────────

class _SparkleStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r  = math.min(w, h) * 0.42;

    // Outer glow
    canvas.drawCircle(
      Offset(cx, cy), r * 1.1,
      Paint()
        ..color = const Color(0xFFFFE66D).withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 8-pointed star
    final starPaint = Paint()
      ..color = const Color(0xFFFFE66D)
      ..style = PaintingStyle.fill;
    final starPath = Path();
    for (int i = 0; i < 8; i++) {
      final outerAngle = -math.pi / 2 + i * 2 * math.pi / 8;
      final innerAngle = outerAngle + math.pi / 8;
      final outer = Offset(cx + r * math.cos(outerAngle), cy + r * math.sin(outerAngle));
      final inner = Offset(cx + r * 0.4 * math.cos(innerAngle), cy + r * 0.4 * math.sin(innerAngle));
      if (i == 0) starPath.moveTo(outer.dx, outer.dy);
      else         starPath.lineTo(outer.dx, outer.dy);
      starPath.lineTo(inner.dx, inner.dy);
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);

    // Center circle
    canvas.drawCircle(Offset(cx, cy), r * 0.22,
        Paint()..color = Colors.white.withOpacity(0.9));

    // Sparkle lines
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(cx + r * 1.15 * math.cos(angle), cy + r * 1.15 * math.sin(angle)),
        Offset(cx + r * 1.4  * math.cos(angle), cy + r * 1.4  * math.sin(angle)),
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Stars badge ────────────────────────────────────────────────────────────────

class _StarsBadge extends StatelessWidget {
  const _StarsBadge({required this.stars});
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:      const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 12,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text(
            '$stars',
            style: const TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w900,
              color:      Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile button ─────────────────────────────────────────────────────────────

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    required this.name,
    required this.mastery,
    required this.onTap,
  });

  final String     name;
  final double     mastery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width:  72,
            height: 72,
            child: CustomPaint(painter: _RingPainter(mastery: mastery)),
          ),
          Container(
            width:  54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF6A6AFF), Color(0xFF4444CC)],
              ),
              boxShadow: [
                BoxShadow(
                  color:      const Color(0xFF6A6AFF).withOpacity(0.5),
                  blurRadius: 12,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize:   22,
                  fontWeight: FontWeight.w900,
                  color:      Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0, bottom: 4,
            child: Container(
              width:  20, height: 20,
              decoration: BoxDecoration(
                color:  AppColors.accentOrange,
                shape:  BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.bar_chart, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.mastery});
  final double mastery;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    canvas.drawCircle(center, radius,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color       = Colors.white.withOpacity(0.15));

    if (mastery > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * mastery,
        false,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap   = StrokeCap.round
          ..color       = AppColors.accentGreen,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.mastery != mastery;
}

// ── Progress bar ───────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.accuracyMap});
  final Map<String, double> accuracyMap;

  int get _mastered => SoundNode.curriculum
      .where((n) => n.statusFor(accuracyMap) == NodeStatus.mastered)
      .length;

  @override
  Widget build(BuildContext context) {
    final mastered = _mastered;
    final total    = SoundNode.curriculum.length;
    final progress = total == 0 ? 0.0 : mastered / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border:       Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$mastered of $total sounds mastered',
                  style: const TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween:    Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve:    Curves.easeOut,
                    builder: (ctx, v, child) => LinearProgressIndicator(
                      value:           v,
                      minHeight:       10,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor:      const AlwaysStoppedAnimation(AppColors.accentGreen),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          TweenAnimationBuilder<double>(
            tween:    Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve:    Curves.easeOut,
            builder: (ctx, v, child) => Text(
              '${(v * 100).round()}%',
              style: const TextStyle(
                fontSize:   20,
                fontWeight: FontWeight.w900,
                color:      AppColors.accentGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
