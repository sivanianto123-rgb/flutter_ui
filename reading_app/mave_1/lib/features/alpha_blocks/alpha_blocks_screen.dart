import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/gemini_live_service.dart';
import '../../widgets/mave_npc.dart';
import '../home/home_screen.dart';

// ---------------------------------------------------------------------------
// Alpha Blocks – "MA" 2-slot puzzle
//
// Rules:
//   • Drag M to slot 0 → snaps in, Mave says "Mmm!"
//   • Drag A to slot 1 → snaps in, Mave says "Aaa!"
//   • Wrong letter in any slot → slot shakes red
//   • Both correct → confetti + Mave says "Ma! You did it!" → HomeScreen
// ---------------------------------------------------------------------------

const _kTarget = ['M', 'A'];

const _kBlockLetters = ['M', 'A', 'B', 'P'];
const _kBlockColors = [
  AppColors.balloon1,
  AppColors.balloon2,
  AppColors.balloon3,
  AppColors.balloon4,
];

class AlphaBlocksScreen extends ConsumerStatefulWidget {
  const AlphaBlocksScreen({super.key});

  @override
  ConsumerState<AlphaBlocksScreen> createState() => _AlphaBlocksScreenState();
}

class _AlphaBlocksScreenState extends ConsumerState<AlphaBlocksScreen>
    with TickerProviderStateMixin {
  late List<_Block> _blocks;
  final List<String?> _slotContents = [null, null];

  late List<AnimationController> _slotShakeCtrl;
  late List<Animation<double>> _slotShakeAnim;
  final List<bool> _slotWrong = [false, false];

  late ConfettiController _confetti;
  bool _complete = false;
  bool _transitioning = false;

  @override
  void initState() {
    super.initState();

    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    final rng = math.Random(7);
    final indices = List.generate(_kBlockLetters.length, (i) => i)..shuffle(rng);
    _blocks = indices
        .map((i) => _Block(letter: _kBlockLetters[i], color: _kBlockColors[i]))
        .toList();

    _slotShakeCtrl = List.generate(
      2,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _slotShakeAnim = _slotShakeCtrl.map((c) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: c, curve: Curves.elasticIn),
      );
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(maveStateProvider.notifier).state = MaveState.speaking;
      ref.read(geminiServiceProvider).speak('Drag the letters to spell M-A!');
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    for (final c in _slotShakeCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onDrop(int slotIdx, _Block block) async {
    if (_slotContents[slotIdx] != null || _complete) return;
    final expected = _kTarget[slotIdx];

    if (block.letter == expected) {
      setState(() {
        _slotContents[slotIdx] = block.letter;
        block.placed = true;
      });
      final sound = block.letter == 'M' ? 'Mmm!' : 'Aaa!';
      await ref.read(geminiServiceProvider).speak(sound);

      if (_slotContents.every((s) => s != null)) {
        await Future.delayed(const Duration(milliseconds: 400));
        _onComplete();
      }
    } else {
      // Wrong letter — shake slot red
      setState(() => _slotWrong[slotIdx] = true);
      _slotShakeCtrl[slotIdx].forward(from: 0).then((_) {
        if (mounted) setState(() => _slotWrong[slotIdx] = false);
      });
    }
  }

  Future<void> _onComplete() async {
    if (_complete || _transitioning) return;
    setState(() => _complete = true);
    _confetti.play();
    ref.read(maveStateProvider.notifier).state = MaveState.happy;
    await ref.read(geminiServiceProvider).speak('Ma! You did it! Amazing!');
    await Future.delayed(const Duration(seconds: 3));
    _goHome();
  }

  void _goHome() {
    if (_transitioning || !mounted) return;
    _transitioning = true;
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
      backgroundColor: const Color(0xFFF0F4FF),
      body: Stack(
        children: [
          Listener(
            onPointerMove: (e) {
              ref.read(touchPositionProvider.notifier).state = (
                e.position.dx / size.width,
                e.position.dy / size.height,
              );
            },
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 32),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.bgMid,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Alpha Blocks',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.bgDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Instruction
                  Text(
                    'Drag the letters to spell:',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bgMid,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'M  A',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.bgDeep,
                      letterSpacing: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Available blocks
                  Expanded(
                    child: Center(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: _blocks
                            .where((b) => !b.placed)
                            .map((b) => _DraggableBlock(block: b))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Drop slots
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _SlotWidget(
                            content: _slotContents[i],
                            isWrong: _slotWrong[i],
                            shakeAnim: _slotShakeAnim[i],
                            onDrop: (block) => _onDrop(i, block),
                          ),
                        );
                      }),
                    ),
                  ),
                  const MaveNPC(size: 120),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Confetti
          Positioned(
            top: 0,
            left: size.width / 2,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              numberOfParticles: 40,
              gravity: 0.3,
              colors: _kBlockColors,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class _Block {
  final String letter;
  final Color color;
  bool placed = false;
  _Block({required this.letter, required this.color});
}

// ---------------------------------------------------------------------------
// Draggable block
// ---------------------------------------------------------------------------

class _DraggableBlock extends StatelessWidget {
  final _Block block;
  const _DraggableBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    return Draggable<_Block>(
      data: block,
      feedback: _BlockTile(letter: block.letter, color: block.color, size: 120),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _BlockTile(letter: block.letter, color: block.color, size: 120),
      ),
      child: _BlockTile(letter: block.letter, color: block.color, size: 120),
    );
  }
}

// ---------------------------------------------------------------------------
// Drop slot
// ---------------------------------------------------------------------------

class _SlotWidget extends StatelessWidget {
  final String? content;
  final bool isWrong;
  final Animation<double> shakeAnim;
  final void Function(_Block) onDrop;

  const _SlotWidget({
    required this.content,
    required this.isWrong,
    required this.shakeAnim,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<_Block>(
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final bgColor = isWrong
            ? AppColors.letterWrong
            : content != null
                ? AppColors.letterCorrect
                : isHovering
                    ? AppColors.cardAlpha.withValues(alpha: 0.3)
                    : Colors.white;

        return AnimatedBuilder(
          animation: shakeAnim,
          builder: (context, child) {
            final shake = math.sin(shakeAnim.value * math.pi * 8) * 10;
            return Transform.translate(
              offset: Offset(shake, 0),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isWrong
                    ? Colors.red
                    : content != null
                        ? AppColors.letterCorrect
                        : AppColors.bgMid.withValues(alpha: 0.35),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: content != null
                  ? Text(
                      content!,
                      style: TextStyle(
                        fontSize: 56.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '?',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.black12,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared block tile
// ---------------------------------------------------------------------------

class _BlockTile extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;

  const _BlockTile({
    required this.letter,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: (size * 0.44).sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
      ),
    );
  }
}
