import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/milestone_model.dart';
import '../../core/models/sound_node.dart';
import '../../core/services/app_providers.dart';
import '../sound_mode/screens/sound_mode_screen.dart';
import 'forest_game.dart';
import 'widgets/parent_insights_overlay.dart';

// ─── Home Screen (forest theme) ────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _insightsOpen = false;

  // One game instance – recreated if the widget is remounted.
  final _game = ForestGame();

  void _openInsights()  => setState(() => _insightsOpen = true);
  void _closeInsights() => setState(() => _insightsOpen = false);

  void _onNodeTap(SoundNode node, NodeStatus status) {
    if (status == NodeStatus.locked) return;
    Navigator.of(context).push(_fadeRoute(
      SoundModeScreen(
        syllable: node.id,
        onFinish: () { if (mounted) Navigator.of(context).pop(); },
      ),
    ));
  }

  PageRoute<void> _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder:        (_, anim, __) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      );

  @override
  Widget build(BuildContext context) {
    final profile      = ref.watch(childProfileProvider);
    final name         = profile?.name ?? 'Friend';
    final accuracyMap  = ref.watch(soundAccuracyProvider);
    final milestonesAsync = ref.watch(milestonesStreamProvider);

    final sessions = milestonesAsync.when(
      data:  (s) => s,
      loading: ()  => <BabyDevelopment>[],
      error:   (_, __) => <BabyDevelopment>[],
    );

    return Scaffold(
      body: Stack(
        children: [
          // ── Flame forest background (fills whole screen) ─────────────────
          GameWidget<ForestGame>(game: _game),

          // ── Top gradient scrim so header text is readable ─────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom gradient scrim ─────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main overlay content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, $name! 🌿',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: Colors.white,
                                shadows: const [
                                  Shadow(color: Color(0x88000000), offset: Offset(1, 2), blurRadius: 6),
                                ],
                              ),
                            ),
                            Text(
                              'Your forest path awaits!',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 16,
                                shadows: const [
                                  Shadow(color: Color(0x66000000), offset: Offset(0, 1), blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _InsightsButton(
                        name:    name,
                        mastery: _overallMastery(accuracyMap),
                        onTap:   _openInsights,
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms),
                ),

                // Flexible space that holds the path + nodes
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      return _ForestPathNodes(
                        width:       w,
                        height:      h,
                        accuracyMap: accuracyMap,
                        onNodeTap:   _onNodeTap,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Parent insights overlay ───────────────────────────────────────
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

// ─── Path nodes overlay (positioned along visual forest path) ──────────────

class _ForestPathNodes extends StatelessWidget {
  const _ForestPathNodes({
    required this.width,
    required this.height,
    required this.accuracyMap,
    required this.onNodeTap,
  });

  final double width, height;
  final Map<String, double>                    accuracyMap;
  final void Function(SoundNode, NodeStatus)   onNodeTap;

  // Each entry: (xFraction, yFraction) along the visual S-curve path.
  // Derived from the bezier in forest_game.dart so nodes sit on the dirt road.
  static const _nodePositions = [
    (0.46, 0.80),  // Ma  – lower path
    (0.55, 0.52),  // Pa  – middle path
    (0.48, 0.24),  // Ma+Pa – upper path
  ];

  @override
  Widget build(BuildContext context) {
    final nodes = SoundNode.curriculum;

    return Stack(
      children: [
        // Connecting dashed vine between nodes
        CustomPaint(
          size: Size(width, height),
          painter: _VineConnectorPainter(
            positions: _nodePositions,
          ),
        ),

        // Node widgets
        for (int i = 0; i < nodes.length && i < _nodePositions.length; i++)
          _buildNode(nodes[i], i),
      ],
    );
  }

  Widget _buildNode(SoundNode node, int index) {
    final status   = node.statusFor(accuracyMap);
    final accuracy = accuracyMap[node.id] ?? 0.0;
    final (xf, yf) = _nodePositions[index];

    const nodeSize = 90.0;

    return Positioned(
      left: width * xf - nodeSize / 2,
      top:  height * yf - nodeSize / 2,
      child: _ForestNode(
        node:     node,
        status:   status,
        accuracy: accuracy,
        onTap:    () => onNodeTap(node, status),
      )
          .animate(delay: (index * 180).ms)
          .fadeIn(duration: 500.ms)
          .scale(
            begin: const Offset(0.6, 0.6),
            end:   const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),
    );
  }
}

// ─── Dashed vine connector between path nodes ─────────────────────────────

class _VineConnectorPainter extends CustomPainter {
  const _VineConnectorPainter({required this.positions});
  final List<(double, double)> positions;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < positions.length - 1; i++) {
      final (x0, y0) = positions[i];
      final (x1, y1) = positions[i + 1];
      final p0 = Offset(size.width * x0, size.height * y0);
      final p1 = Offset(size.width * x1, size.height * y1);

      // Draw dashed line
      final dx   = p1.dx - p0.dx;
      final dy   = p1.dy - p0.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      const dashLen = 10.0;
      const gapLen  = 8.0;
      final steps   = (dist / (dashLen + gapLen)).floor();

      for (int j = 0; j < steps; j++) {
        final t0 = j * (dashLen + gapLen) / dist;
        final t1 = (j * (dashLen + gapLen) + dashLen) / dist;
        canvas.drawLine(
          Offset(p0.dx + dx * t0, p0.dy + dy * t0),
          Offset(p0.dx + dx * t1.clamp(0, 1), p0.dy + dy * t1.clamp(0, 1)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_VineConnectorPainter old) => false;
}

// ─── Individual forest node ────────────────────────────────────────────────

class _ForestNode extends StatelessWidget {
  const _ForestNode({
    required this.node,
    required this.status,
    required this.accuracy,
    required this.onTap,
  });

  final SoundNode    node;
  final NodeStatus   status;
  final double       accuracy;
  final VoidCallback onTap;

  static const _bgByStatus = {
    NodeStatus.locked:     Color(0xFF78909C),
    NodeStatus.available:  Color(0xFFFF7043),
    NodeStatus.inProgress: Color(0xFFFFB300),
    NodeStatus.mastered:   Color(0xFF43A047),
  };

  static const _glowByStatus = {
    NodeStatus.locked:     Color(0x00000000),
    NodeStatus.available:  Color(0x55FF7043),
    NodeStatus.inProgress: Color(0x55FFB300),
    NodeStatus.mastered:   Color(0x5543A047),
  };

  @override
  Widget build(BuildContext context) {
    final isLocked = status == NodeStatus.locked;
    final bg       = _bgByStatus[status]!;
    final glow     = _glowByStatus[status]!;
    const size     = 90.0;

    Widget node_ = GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Node circle
          Container(
            width:  size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bg,
              border: Border.all(color: Colors.white, width: 3.5),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4)),
                BoxShadow(color: glow, blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLocked)
                  const Icon(Icons.lock_rounded, color: Colors.white70, size: 28)
                else if (status == NodeStatus.mastered)
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 36)
                else ...[
                  Text(node.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 2),
                  Text(
                    node.label,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color:     Colors.white,
                      fontSize:  node.prerequisites.isNotEmpty ? 13 : 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Status badge below node
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isLocked
                  ? '🔒 Locked'
                  : status == NodeStatus.mastered
                      ? '⭐ Mastered'
                      : '${(accuracy * 100).round()}%',
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    // Pulse animation for available nodes
    if (status == NodeStatus.available) {
      node_ = node_
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end:   const Offset(1.06, 1.06),
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }

    return node_;
  }
}

// ─── Insights button (top-right) ──────────────────────────────────────────

class _InsightsButton extends StatelessWidget {
  const _InsightsButton({
    required this.name,
    required this.mastery,
    required this.onTap,
  });

  final String       name;
  final double       mastery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72, height: 72,
                child: CustomPaint(painter: _MasteryRingPainter(mastery)),
              ),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color:  Colors.white.withOpacity(0.25),
                  shape:  BoxShape.circle,
                  border: Border.all(color: Colors.white60, width: 2),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize:   24,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                      shadows:    [Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 3)],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color:  const Color(0xFFFFD740),
                    shape:  BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.bar_chart_rounded, color: Colors.white, size: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Insights',
            style: TextStyle(
              color:      Colors.white.withOpacity(0.9),
              fontSize:   11,
              fontWeight: FontWeight.w700,
              shadows:    const [Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 3)],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryRingPainter extends CustomPainter {
  const _MasteryRingPainter(this.mastery);
  final double mastery;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..color       = Colors.white.withOpacity(0.25),
    );

    if (mastery > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * mastery,
        false,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap   = StrokeCap.round
          ..color       = const Color(0xFF69F0AE),
      );
    }
  }

  @override
  bool shouldRepaint(_MasteryRingPainter old) => old.mastery != mastery;
}
