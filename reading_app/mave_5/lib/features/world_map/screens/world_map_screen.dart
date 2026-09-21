import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/level_node.dart';
import '../providers/world_map_provider.dart';
import '../widgets/cactus_painter.dart';
import '../widgets/gift_box_widget.dart';
import '../widgets/level_node_widget.dart';
import '../widgets/path_painter.dart';

class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future(() {
      if (!mounted) return;
      final screenW = MediaQuery.of(context).size.width;
      final screenH = MediaQuery.of(context).size.height;
      ref.read(worldMapProvider.notifier).init(screenW);
      const nodeY = canvasHeight * 0.76;
      final scrollTo = (nodeY - screenH / 2).clamp(0.0, double.infinity);
      _scrollController.animateTo(
        scrollTo,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onNodeTap(BuildContext context, LevelNode node) {
    if (node.state == NodeState.locked) {
      _showLockedTooltip(context, node);
      return;
    }
    // TODO: navigate to PhonicsZoneScreen(level: node.id)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening level ${node.id}…'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showLockedTooltip(BuildContext context, LevelNode node) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _LockedTooltip(
        message: 'Complete level ${node.id - 1} first!',
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  Widget _rock(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFFC17820),
          borderRadius: BorderRadius.vertical(
            top: Radius.elliptical(w / 2, h * 0.7),
            bottom: Radius.elliptical(w / 2, h * 0.3),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2)),
          ],
        ),
      );

  Widget _decorStar(double size) => Icon(
        Icons.star_rounded,
        color: const Color(0xFFFFD700),
        size: size,
      );

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final nodes = ref.watch(worldMapProvider);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: screenW,
              height: canvasHeight,
              child: Stack(
                children: [
                  // FIX 5 — 4-stop desert gradient
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFD580),
                            Color(0xFFF5B830),
                            Color(0xFFE8A020),
                            Color(0xFFD4880A),
                          ],
                          stops: [0.0, 0.30, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Winding path
                  Positioned.fill(
                    child: CustomPaint(painter: PathPainter()),
                  ),

                  // FIX 6 — Rocks
                  Positioned(top: 210,  left: screenW * 0.47, child: _rock(60, 32)),
                  Positioned(top: 470,  left: screenW * 0.10, child: _rock(52, 28)),
                  Positioned(top: 640,  left: screenW * 0.62, child: _rock(44, 24)),
                  Positioned(top: 820,  left: screenW * 0.38, child: _rock(48, 26)),
                  Positioned(top: 1050, left: screenW * 0.28, child: _rock(56, 30)),
                  Positioned(top: 1150, left: screenW * 0.70, child: _rock(38, 20)),

                  // FIX 9 — Decorative stars
                  Positioned(top: 380, left: screenW * 0.10, child: _decorStar(14)),
                  Positioned(top: 420, left: screenW * 0.08, child: _decorStar(12)),
                  Positioned(top: 560, left: screenW * 0.15, child: _decorStar(16)),
                  Positioned(top: 720, left: screenW * 0.62, child: _decorStar(14)),
                  Positioned(top: 840, left: screenW * 0.88, child: _decorStar(12)),

                  // FIX 7 — Cacti
                  Positioned(
                    top: 60,
                    left: 24,
                    child: SizedBox(
                      width: 60,
                      height: 90,
                      child: CustomPaint(painter: const CactusPainter(hasFlower: true)),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    right: 24,
                    child: SizedBox(
                      width: 55,
                      height: 80,
                      child: CustomPaint(painter: const CactusPainter()),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    right: 16,
                    child: SizedBox(
                      width: 45,
                      height: 55,
                      child: CustomPaint(painter: const CactusPainter(hasFlower: true)),
                    ),
                  ),

                  // FIX 8 — Gift box: right of node 5 (x=0.60, y=0.28)
                  Positioned(
                    top: canvasHeight * 0.28 - 30,
                    left: screenW * 0.60,
                    child: const GiftBoxWidget(),
                  ),

                  // Level nodes — offset by half node height (star row ~20 + circle ~66)
                  for (final node in nodes)
                    Positioned(
                      left: node.position.dx - (node.state == NodeState.current ? 33 : 31),
                      top: node.position.dy - (node.state == NodeState.current ? 86 : 82),
                      child: LevelNodeWidget(
                        node: node,
                        onTap: () => _onNodeTap(context, node),
                      ),
                    ),

                  // Title banner
                  Positioned(
                    top: 52,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'READ & WONDER ★',
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1565C0),
                          shadows: const [
                            Shadow(color: Colors.white, blurRadius: 4),
                            Shadow(color: Colors.white, blurRadius: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Parent dashboard FAB — always visible over scroll
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              onPressed: () {
                // TODO: navigate to ParentDashboard
              },
              child: const Icon(Icons.bar_chart_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Locked overlay tooltip ──────────────────────────────────────────────────

class _LockedTooltip extends StatefulWidget {
  final String message;
  final VoidCallback onDone;
  const _LockedTooltip({required this.message, required this.onDone});

  @override
  State<_LockedTooltip> createState() => _LockedTooltipState();
}

class _LockedTooltipState extends State<_LockedTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDone());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _opacity,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
