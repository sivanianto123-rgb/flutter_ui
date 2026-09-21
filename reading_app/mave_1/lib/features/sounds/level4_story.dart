import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/gemini_live_service.dart';
import '../../core/services/hive_service.dart';
import '../../widgets/mave_npc.dart';
import '../home/home_screen.dart';

// ---------------------------------------------------------------------------
// Level 4 – Sound Story
// ---------------------------------------------------------------------------

class Level4Story extends ConsumerStatefulWidget {
  const Level4Story({super.key});

  @override
  ConsumerState<Level4Story> createState() => _Level4StoryState();
}

class _Level4StoryState extends ConsumerState<Level4Story>
    with SingleTickerProviderStateMixin {
  late AnimationController _sceneCtrl;
  late Animation<double> _sceneAnim;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _sceneCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _sceneAnim = CurvedAnimation(parent: _sceneCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) => _playStory());
  }

  @override
  void dispose() {
    _sceneCtrl.dispose();
    super.dispose();
  }

  Future<void> _playStory() async {
    final gemini = ref.read(geminiServiceProvider);
    ref.read(maveStateProvider.notifier).state = MaveState.speaking;
    await gemini.speak(
      'Look! It is Mama. Mama loves Mave. Ma, ma, ma.',
    );

    // Give story audio time to play (~6 s)
    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;

    ref.read(maveStateProvider.notifier).state = MaveState.happy;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Persist progress
    await ref.read(hiveServiceProvider).markLevelComplete(3); // 0-based level 4
    ref.read(progressProvider.notifier).refresh();

    setState(() => _done = true);

    await Future.delayed(const Duration(seconds: 1));
    _goHome();
  }

  void _goHome() {
    if (!mounted) return;
    ref.read(maveStateProvider.notifier).state = MaveState.idle;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const HomeScreen(),
        transitionsBuilder: (ctx, anim, anim2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E6),
      body: Listener(
        onPointerMove: (e) {
          ref.read(touchPositionProvider.notifier).state = (
            e.position.dx / size.width,
            e.position.dy / size.height,
          );
        },
        child: SafeArea(
          child: FadeTransition(
            opacity: _sceneAnim,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Scene title
                Text(
                  'A Story About Ma',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cardSounds,
                  ),
                ),
                const SizedBox(height: 40),
                // Scene illustration
                Expanded(child: _StoryScene()),
                // Mave
                const MaveNPC(size: 160),
                const SizedBox(height: 16),
                // Caption
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: _Caption(done: _done),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scene illustration (drawn programmatically)
// ---------------------------------------------------------------------------

class _StoryScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _ScenePainter(),
      );
    });
  }
}

class _ScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Sky
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.6),
      Paint()
        ..color = const Color(0xFFADD8E6)
        ..style = PaintingStyle.fill,
    );

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      Paint()..color = const Color(0xFF90EE90),
    );

    // Big "Mama" figure (simple stick figure with heart)
    final mamaPaint = Paint()
      ..color = const Color(0xFFFF6B9D)
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(cx - 80, cy - 40), 50, mamaPaint);

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 80, cy + 60), width: 70, height: 100),
        const Radius.circular(20),
      ),
      mamaPaint,
    );

    // "Mama" label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Mama',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - 80 - tp.width / 2, cy + 20));

    // Heart between Mama and Mave
    _drawHeart(canvas, Offset(cx, cy - 30), 24, Colors.red.withValues(alpha: 0.8));

    // "Mave" blob (small version)
    canvas.drawCircle(
      Offset(cx + 80, cy - 20),
      40,
      Paint()..color = AppColors.maveIdle,
    );
    final tp2 = TextPainter(
      text: const TextSpan(
        text: 'Mave',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, Offset(cx + 80 - tp2.width / 2, cy - 28));

    // Big "MA" text in the sky
    final tp3 = TextPainter(
      text: const TextSpan(
        text: 'Ma ♪',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.w900,
          shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp3.paint(canvas, Offset(cx - tp3.width / 2, 24));
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    final x = center.dx;
    final y = center.dy;
    path.moveTo(x, y + size * 0.35);
    path.cubicTo(x, y, x - size, y, x - size, y - size * 0.35);
    path.cubicTo(
        x - size, y - size * 0.7, x, y - size * 0.7, x, y - size * 0.35);
    path.cubicTo(x, y - size * 0.7, x + size, y - size * 0.7, x + size,
        y - size * 0.35);
    path.cubicTo(x + size, y, x, y, x, y + size * 0.35);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ---------------------------------------------------------------------------
// Caption sub-widget
// ---------------------------------------------------------------------------

class _Caption extends ConsumerWidget {
  final bool done;
  const _Caption({required this.done});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maveStateProvider);
    final text = done
        ? '🌟 Great job! Going home...'
        : state == MaveState.speaking
            ? '"Look! It is Mama. Mama loves Mave. Ma, ma, ma."'
            : '🎉 You finished the Ma journey!';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.bgDeep,
            fontStyle: state == MaveState.speaking
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}
