import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/app_providers.dart';
import '../providers/sound_mode_provider.dart';
import '../widgets/mave_next_button.dart';
import '../widgets/pop_explosion_painter.dart';

class Level3Screen extends ConsumerStatefulWidget {
  const Level3Screen({
    super.key,
    required this.syllable,
    required this.activityId,
    required this.onNext,
  });

  final String       syllable;
  final String       activityId;
  final VoidCallback onNext;

  @override
  ConsumerState<Level3Screen> createState() => _Level3ScreenState();
}

class _Level3ScreenState extends ConsumerState<Level3Screen>
    with SingleTickerProviderStateMixin {
  static const int    _targetCount  = 3;
  static const int    _totalBubbles = 9;
  static const double _bubbleSize   = 100.0;
  static const double _minDistance  = 112.0;

  late final List<_Bubble> _bubbles;
  List<Offset>? _positions;

  final Set<int> _tappedTargets = {};
  final Set<int> _showPop       = {};
  final Set<int> _popped        = {};
  bool _complete = false;

  int _totalTaps   = 0;
  int _correctTaps = 0;

  late final AnimationController _nudgeController;
  late final Animation<double>   _nudgeScale;
  bool _nudgeActive = false;
  Timer? _nudgeTimer;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _buildBubbles();

    _nudgeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _nudgeScale = Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _nudgeController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetNudgeTimer();
      _resetInactivityTimer();
    });
  }

  @override
  void dispose() {
    _nudgeTimer?.cancel();
    _inactivityTimer?.cancel();
    _nudgeController.dispose();
    super.dispose();
  }

  void _buildBubbles() {
    const distractors = ['ba', 'da', 'ta', 'pa', 'na', 'la', 'ka', 'sa'];
    final list = <_Bubble>[
      for (int i = 0; i < _targetCount; i++)
        _Bubble(text: widget.syllable, isTarget: true),
      for (int i = 0; i < _totalBubbles - _targetCount; i++)
        _Bubble(text: distractors[i % distractors.length], isTarget: false),
    ]..shuffle(Random(DateTime.now().millisecondsSinceEpoch));
    _bubbles = list;
  }

  List<Offset> _generatePositions(double w, double h) {
    final rng = Random(42);
    final positions = <Offset>[];
    const padding = _bubbleSize / 2 + 4;
    int attempts = 0;
    while (positions.length < _bubbles.length && attempts < 2000) {
      attempts++;
      final x = padding + rng.nextDouble() * (w - _bubbleSize - 8);
      final y = padding + rng.nextDouble() * (h - _bubbleSize - 8);
      final c = Offset(x, y);
      if (!positions.any((p) => (p - c).distance < _minDistance)) positions.add(c);
    }
    return positions;
  }

  void _resetNudgeTimer() {
    _nudgeTimer?.cancel();
    if (_complete) return;
    _nudgeTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted || _complete) return;
      setState(() => _nudgeActive = true);
      _nudgeController.repeat(reverse: true);
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_complete) return;
    _inactivityTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _complete) return;
      final audio = ref.read(audioServiceProvider);
      if (!audio.isPlaying) {
        audio.speak("Find all the '${widget.syllable}' bubbles!");
      }
      _resetInactivityTimer();
    });
  }

  void _stopNudge() {
    _nudgeTimer?.cancel();
    if (_nudgeActive) {
      _nudgeController.stop();
      _nudgeController.animateTo(0, duration: const Duration(milliseconds: 150));
      setState(() => _nudgeActive = false);
    }
  }

  Future<void> _onBubbleTap(int index) async {
    if (_popped.contains(index) || _showPop.contains(index)) return;

    _stopNudge();
    _resetNudgeTimer();
    _resetInactivityTimer();

    final bubble = _bubbles[index];
    ref.read(audioServiceProvider).speak(bubble.text);

    _totalTaps++;
    if (bubble.isTarget) _correctTaps++;
    ref.read(soundModeProvider.notifier).recordTap(wasTarget: bubble.isTarget);

    if (!bubble.isTarget || _tappedTargets.contains(index)) return;

    setState(() {
      _tappedTargets.add(index);
      _showPop.add(index);
    });

    if (_tappedTargets.length == _targetCount) {
      await Future.delayed(const Duration(milliseconds: 600));
      _onComplete();
    }
  }

  void _onPopComplete(int index) {
    if (!mounted) return;
    setState(() { _showPop.remove(index); _popped.add(index); });
  }

  Future<void> _onComplete() async {
    _nudgeTimer?.cancel();
    _inactivityTimer?.cancel();
    _stopNudge();
    setState(() => _complete = true);
    ref.read(soundModeProvider.notifier).markLevelComplete();
    await ref.read(audioServiceProvider).speak('You found them all!');
    await ref.read(audioServiceProvider).waitForCompletion();
    ref.read(soundModeProvider.notifier).markAudioReady();

    final accuracy = _totalTaps == 0 ? 0.0 : (_correctTaps / _totalTaps).clamp(0.0, 1.0);
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);
  }

  @override
  Widget build(BuildContext context) {
    final audioReady = ref.watch(soundModeProvider).audioReady;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B4E), Color(0xFF1A3A6E)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        Text(
                          'Tap all "${widget.syllable}"!',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 500.ms),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _complete
                                ? 'All found!'
                                : '${_targetCount - _tappedTargets.length} left to find',
                            key: ValueKey(_tappedTargets.length),
                            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _positions ??= _generatePositions(
                          constraints.maxWidth, constraints.maxHeight,
                        );
                        final positions = _positions!;

                        return Stack(
                          children: [
                            for (int i = 0; i < _bubbles.length; i++)
                              if (i < positions.length)
                                Positioned(
                                  left: positions[i].dx - _bubbleSize / 2,
                                  top:  positions[i].dy - _bubbleSize / 2,
                                  child: _ScatterBubble(
                                    bubble:          _bubbles[i],
                                    index:           i,
                                    popped:          _popped.contains(i),
                                    showPop:         _showPop.contains(i),
                                    tapped:          _tappedTargets.contains(i),
                                    size:            _bubbleSize,
                                    delay:           i * 60,
                                    breatheAnimation:
                                        (_nudgeActive && _bubbles[i].isTarget &&
                                            !_tappedTargets.contains(i) && !_popped.contains(i))
                                            ? _nudgeScale : null,
                                    onTap:           () => _onBubbleTap(i),
                                    onPopComplete:   () => _onPopComplete(i),
                                  ),
                                ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              if (audioReady)
                Positioned(
                  bottom: 24, right: 24,
                  child: MaveNextButton(onTap: widget.onNext),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScatterBubble extends StatelessWidget {
  const _ScatterBubble({
    required this.bubble,
    required this.index,
    required this.popped,
    required this.showPop,
    required this.tapped,
    required this.size,
    required this.delay,
    required this.onTap,
    required this.onPopComplete,
    this.breatheAnimation,
  });

  final _Bubble              bubble;
  final int                  index;
  final bool                 popped;
  final bool                 showPop;
  final bool                 tapped;
  final double               size;
  final int                  delay;
  final VoidCallback         onTap;
  final VoidCallback         onPopComplete;
  final Animation<double>?   breatheAnimation;

  @override
  Widget build(BuildContext context) {
    final color    = AppColors.bubbleColors[index % AppColors.bubbleColors.length];
    final isTarget = bubble.isTarget;

    Widget bubbleVisual = Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color:  tapped ? AppColors.accentGreen.withOpacity(0.9) : color.withOpacity(0.9),
        shape:  BoxShape.circle,
        border: isTarget && !tapped
            ? Border.all(color: Colors.white.withOpacity(0.5), width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: (tapped ? AppColors.accentGreen : color).withOpacity(0.4),
            blurRadius: 14, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          bubble.text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    );

    final anim = breatheAnimation;
    if (anim != null && isTarget && !tapped && !popped) {
      bubbleVisual = AnimatedBuilder(
        animation: anim,
        builder: (_, child) => Transform.scale(scale: anim.value, child: child),
        child: bubbleVisual,
      );
    }

    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedScale(
            scale:    popped ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve:    Curves.easeIn,
            child: AnimatedOpacity(
              opacity:  popped ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: GestureDetector(
                onTap: onTap,
                child: bubbleVisual,
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: delay))
              .fadeIn(duration: 350.ms)
              .scale(begin: const Offset(0.5, 0.5), duration: 350.ms, curve: Curves.elasticOut),

          if (showPop)
            PopExplosion(size: size * 1.6, onComplete: onPopComplete),
        ],
      ),
    );
  }
}

class _Bubble {
  const _Bubble({required this.text, required this.isTarget});
  final String text;
  final bool   isTarget;
}
