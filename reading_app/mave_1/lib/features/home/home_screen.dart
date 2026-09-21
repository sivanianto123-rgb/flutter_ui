import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/audio_player_service.dart';
import '../../widgets/mave_npc.dart';
import '../../widgets/parallax_background.dart';
import '../../widgets/progress_bubble.dart';
import '../sounds/level1_representation.dart';
import '../alpha_blocks/alpha_blocks_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Listener(
        onPointerMove: (e) {
          final size = MediaQuery.of(context).size;
          ref.read(touchPositionProvider.notifier).state = (
            e.position.dx / size.width,
            e.position.dy / size.height,
          );
        },
        child: ParallaxBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _TopBar(),
                    Expanded(child: _CardRow()),
                    const SizedBox(height: 32),
                    const MaveNPC(size: 180),
                    const SizedBox(height: 24),
                  ],
                ),
                // ── DEBUG: audio sandbox test button ──────────────────────
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _AudioTestButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar with progress bubble + title
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          const ProgressBubble(size: 90),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Hello! I\'m Mave 👋',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 36.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Two giant mode cards
// ---------------------------------------------------------------------------

class _CardRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: _ModeCard(
              label: 'Sounds',
              emoji: '🔊',
              color: AppColors.cardSounds,
              onTap: () => Navigator.of(context).push(
                _fadeRoute(const Level1Representation()),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _ModeCard(
              label: 'Alpha\nBlocks',
              emoji: '🧩',
              color: AppColors.cardAlpha,
              onTap: () => Navigator.of(context).push(
                _fadeRoute(const AlphaBlocksScreen()),
              ),
              enable3d: true,
            ),
          ),
        ],
      ),
    );
  }

  PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => page,
        transitionsBuilder: (ctx, anim, anim2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      );
}

class _ModeCard extends StatefulWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;
  final bool enable3d;

  const _ModeCard({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
    this.enable3d = false,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

// ---------------------------------------------------------------------------
// DEBUG: Audio sandbox test — tap to play a generated beep.
// If you hear the beep, audioplayers + sandbox are working.
// If silent, check Console.app for sandbox denials or AudioPlayer log errors.
// ---------------------------------------------------------------------------

class _AudioTestButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        debugPrint('[AudioTest] button tapped — playing pop');
        await ref.read(audioPlayerServiceProvider).playPop();
        debugPrint('[AudioTest] playPop() returned');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Audio Test',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCardState extends State<_ModeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _tiltX = 0, _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() {}),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.emoji,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 16),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!widget.enable3d) return card;

    // 3-D tilt effect for Alpha Blocks card
    return MouseRegion(
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(e.position);
        setState(() {
          _tiltX = (local.dy / box.size.height - 0.5) * 0.15;
          _tiltY = -(local.dx / box.size.width - 0.5) * 0.15;
        });
      },
      onExit: (_) => setState(() {
        _tiltX = 0;
        _tiltY = 0;
      }),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY),
        child: card,
      ),
    );
  }
}
