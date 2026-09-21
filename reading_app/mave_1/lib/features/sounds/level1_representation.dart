import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/gemini_live_service.dart';
import '../../widgets/mave_npc.dart';
import 'level2_balloon.dart';

// ---------------------------------------------------------------------------
// Level 1 – Representation Screen
// ---------------------------------------------------------------------------

class Level1Representation extends ConsumerStatefulWidget {
  const Level1Representation({super.key});

  @override
  ConsumerState<Level1Representation> createState() =>
      _Level1RepresentationState();
}

class _Level1RepresentationState extends ConsumerState<Level1Representation>
    with SingleTickerProviderStateMixin {
  late AnimationController _textPulse;
  late Animation<double> _textScale;
  bool _transitioning = false;

  @override
  void initState() {
    super.initState();
    _textPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _textScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _textPulse, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _startLevel());
  }

  @override
  void dispose() {
    _textPulse.dispose();
    super.dispose();
  }

  Future<void> _startLevel() async {
    final gemini = ref.read(geminiServiceProvider);

    // Wait for Gemini to be ready (max 10 s) before speaking.
    int t = 0;
    while (!gemini.isReady && t < 50) {
      await Future.delayed(const Duration(milliseconds: 200));
      t++;
    }
    if (!mounted) return;
    if (!gemini.isReady) {
      // Gemini unavailable — still transition through level without audio.
      await Future.delayed(const Duration(seconds: 3));
      _goNext();
      return;
    }

    // Mave speaks
    ref.read(maveStateProvider.notifier).state = MaveState.speaking;
    await gemini.speak('Mmm... Aaa... Ma!');

    // Wait for audio to likely finish (~3 s)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    ref.read(maveStateProvider.notifier).state = MaveState.happy;

    // Bounce then transition
    await Future.delayed(const Duration(milliseconds: 1200));
    _goNext();
  }

  void _goNext() {
    if (_transitioning || !mounted) return;
    _transitioning = true;
    ref.read(maveStateProvider.notifier).state = MaveState.idle;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const Level2Balloon(),
        transitionsBuilder: (ctx, anim, anim2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.level1Bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Giant "ma" text
              ScaleTransition(
                scale: _textScale,
                child: Text(
                  'ma',
                  style: TextStyle(
                    color: AppColors.level1Text,
                    fontSize: 220.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const MaveNPC(size: 200),
              const SizedBox(height: 16),
              _SubtitleText(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubtitleText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maveStateProvider);
    final label = switch (state) {
      MaveState.speaking => 'Mmm... Aaa... Ma! 🎵',
      MaveState.happy => 'Great! Let\'s play! 🎉',
      _ => '',
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        label,
        key: ValueKey(label),
        style: TextStyle(
          color: AppColors.bgMid,
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
