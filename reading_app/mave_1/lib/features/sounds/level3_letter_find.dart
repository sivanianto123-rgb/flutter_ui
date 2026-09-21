import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/gemini_live_service.dart';
import '../../widgets/mave_npc.dart';
import 'level4_story.dart';

// ---------------------------------------------------------------------------
// Level 3 – Letter Find
// ---------------------------------------------------------------------------

const _kLetterGrid = ['M', 'A', 'B', 'M', 'P', 'A', 'B', 'M', 'A', 'P', 'M', 'A'];

class Level3LetterFind extends ConsumerStatefulWidget {
  const Level3LetterFind({super.key});

  @override
  ConsumerState<Level3LetterFind> createState() => _Level3LetterFindState();
}

class _Level3LetterFindState extends ConsumerState<Level3LetterFind>
    with SingleTickerProviderStateMixin {
  final Set<int> _removed = {};
  final Set<int> _shaking = {};
  bool _transitioning = false;

  // Screen-level shake for wrong taps
  late AnimationController _screenShakeCtrl;
  late Animation<double> _screenShakeAnim;

  int get _remainingTarget =>
      _kLetterGrid.asMap().entries.where((e) {
        return (e.value == 'M' || e.value == 'A') && !_removed.contains(e.key);
      }).length;

  @override
  void initState() {
    super.initState();
    _screenShakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _screenShakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _screenShakeCtrl, curve: Curves.elasticIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(geminiServiceProvider).speak('Find the letters M and A! Tap them!');
    });
  }

  @override
  void dispose() {
    _screenShakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap(int idx) async {
    if (_removed.contains(idx)) return;
    final letter = _kLetterGrid[idx];
    final isTarget = letter == 'M' || letter == 'A';

    if (isTarget) {
      setState(() => _removed.add(idx));
      final sound = letter == 'M' ? 'Mmm!' : 'Aaa!';
      await ref.read(geminiServiceProvider).speak(sound);

      if (_remainingTarget == 0) {
        await Future.delayed(const Duration(milliseconds: 600));
        _goNext();
      }
    } else {
      // Wrong letter — shake tile + full-screen shake + thump
      setState(() => _shaking.add(idx));
      final player = ref.read(audioPlayerServiceProvider);
      await player.playThump();
      _screenShakeCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _shaking.remove(idx));
    }
  }

  void _goNext() {
    if (_transitioning || !mounted) return;
    _transitioning = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const Level4Story(),
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
      backgroundColor: const Color(0xFFF8F4FF),
      body: Listener(
        onPointerMove: (e) {
          ref.read(touchPositionProvider.notifier).state = (
            e.position.dx / size.width,
            e.position.dy / size.height,
          );
        },
        child: AnimatedBuilder(
          animation: _screenShakeAnim,
          builder: (context, child) {
            final shake = math.sin(_screenShakeAnim.value * math.pi * 6) * 12;
            return Transform.translate(
              offset: Offset(shake, 0),
              child: child,
            );
          },
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Find all the M and A letters!',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.bgDeep,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: _kLetterGrid.length,
                    itemBuilder: (context, idx) {
                      if (_removed.contains(idx)) {
                        return const SizedBox.shrink();
                      }
                      return _LetterTile(
                        letter: _kLetterGrid[idx],
                        isShaking: _shaking.contains(idx),
                        onTap: () => _onTap(idx),
                      );
                    },
                  ),
                ),
                const MaveNPC(size: 140),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Letter tile widget
// ---------------------------------------------------------------------------

class _LetterTile extends StatefulWidget {
  final String letter;
  final bool isShaking;
  final VoidCallback onTap;

  const _LetterTile({
    required this.letter,
    required this.isShaking,
    required this.onTap,
  });

  @override
  State<_LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<_LetterTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  bool _glowing = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_LetterTile old) {
    super.didUpdateWidget(old);
    if (widget.isShaking && !old.isShaking) {
      _shakeCtrl.forward(from: 0);
    }
    if (!widget.isShaking && old.isShaking) {
      _shakeCtrl.stop();
    }
  }

  Future<void> _onTap() async {
    final isTarget = widget.letter == 'M' || widget.letter == 'A';
    if (isTarget) {
      setState(() => _glowing = true);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isTarget = widget.letter == 'M' || widget.letter == 'A';
    final bgColor =
        widget.isShaking ? AppColors.letterWrong : AppColors.letterBg;

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) {
        final shake = math.sin(_shakeAnim.value * math.pi * 8) * 8;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _glowing ? AppColors.letterCorrect : bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _glowing
                ? [
                    BoxShadow(
                      color: AppColors.letterCorrect.withValues(alpha: 0.6),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ]
                : [
                    const BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
          ),
          child: Center(
            child: Text(
              widget.letter,
              style: TextStyle(
                fontSize: 52.sp,
                fontWeight: FontWeight.w900,
                color: _glowing
                    ? Colors.white
                    : isTarget
                        ? AppColors.bgDeep
                        : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
