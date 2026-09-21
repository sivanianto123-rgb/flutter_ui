import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/app_providers.dart';
import '../providers/sound_mode_provider.dart';
import '../widgets/bubble_background_painter.dart';
import '../widgets/mave_next_button.dart';
import '../widgets/pop_explosion_painter.dart';

class Level3Screen extends ConsumerStatefulWidget {
  const Level3Screen({
    super.key,
    required this.syllable,
    required this.activityId,
    required this.onNext,
  });

  final String syllable;
  final String activityId;
  final VoidCallback onNext;

  @override
  ConsumerState<Level3Screen> createState() => _Level3ScreenState();
}

class _Level3ScreenState extends ConsumerState<Level3Screen>
    with SingleTickerProviderStateMixin {
  // ── Bubble data ────────────────────────────────────────────────────────────
  static const int _targetCount = 3;
  static const int _totalBubbles = 9; // 3 targets + 6 distractors
  static const double _bubbleSize = 100.0;
  static const double _minDistance = 112.0;

  late final List<_Bubble> _bubbles;
  List<Offset>? _positions;

  final Set<int> _tappedTargets = {};
  final Set<int> _showPop = {};
  final Set<int> _popped = {};
  bool _complete = false;

  // ── Accuracy tracking ──────────────────────────────────────────────────────
  int _totalTaps   = 0;
  int _correctTaps = 0;

  // ── Nudge animation (3 s inactivity → target bubbles breathe) ─────────────
  late final AnimationController _nudgeController;
  late final Animation<double> _nudgeScale;
  bool _nudgeActive = false;
  Timer? _nudgeTimer;

  static const _nudgeDuration = Duration(seconds: 3);

  // ── Audio inactivity reminder (6 s without any tap) ───────────────────────
  Timer? _inactivityTimer;
  static const _inactivityDuration = Duration(seconds: 6);

  // ── Life-cycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _buildBubbles();

    _nudgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _nudgeScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _nudgeController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAudio();
      // Start both inactivity clocks once the screen is visible.
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

  // ── Bubble setup ───────────────────────────────────────────────────────────

  void _buildBubbles() {
    final syllable = widget.syllable;
    const distractors = ['ba', 'da', 'ta', 'pa', 'na', 'la', 'ka', 'sa'];
    final list = <_Bubble>[
      for (int i = 0; i < _targetCount; i++)
        _Bubble(text: syllable, isTarget: true),
      for (int i = 0; i < _totalBubbles - _targetCount; i++)
        _Bubble(text: distractors[i % distractors.length], isTarget: false),
    ]..shuffle(Random(DateTime.now().millisecondsSinceEpoch));
    _bubbles = list;
  }

  Future<void> _preloadAudio() async {
    final texts = _bubbles.map((b) => b.text).toSet().toList();
    await ref.read(audioServiceProvider).preload(texts);
  }

  List<Offset> _generatePositions(double width, double height) {
    final rng = Random(42);
    final positions = <Offset>[];
    const padding = _bubbleSize / 2 + 4;
    int attempts = 0;

    while (positions.length < _bubbles.length && attempts < 2000) {
      attempts++;
      final x = padding + rng.nextDouble() * (width - _bubbleSize - 8);
      final y = padding + rng.nextDouble() * (height - _bubbleSize - 8);
      final candidate = Offset(x, y);
      if (!positions.any((p) => (p - candidate).distance < _minDistance)) {
        positions.add(candidate);
      }
    }

    if (positions.length < _bubbles.length) {
      final cols = (width / (_bubbleSize + 8)).floor().clamp(1, 99);
      for (int i = positions.length; i < _bubbles.length; i++) {
        final col = i % cols;
        final row = i ~/ cols;
        positions.add(Offset(
          padding + col * (_bubbleSize + 8),
          padding + row * (_bubbleSize + 8),
        ));
      }
    }
    return positions;
  }

  // ── Nudge timer (3 s → breathing animation on targets) ────────────────────

  void _resetNudgeTimer() {
    _nudgeTimer?.cancel();
    if (_complete) return;
    _nudgeTimer = Timer(_nudgeDuration, _onNudgeTimeout);
  }

  void _onNudgeTimeout() {
    if (!mounted || _complete) return;
    setState(() => _nudgeActive = true);
    _nudgeController.repeat(reverse: true);
  }

  void _stopNudge() {
    _nudgeTimer?.cancel();
    if (_nudgeActive) {
      _nudgeController.stop();
      _nudgeController.animateTo(0.0,
          duration: const Duration(milliseconds: 150));
      setState(() => _nudgeActive = false);
    }
  }

  // ── Inactivity audio reminder (6 s → speak instruction) ───────────────────

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (_complete) return;
    _inactivityTimer = Timer(_inactivityDuration, _onInactivityTimeout);
  }

  void _onInactivityTimeout() {
    if (!mounted || _complete) return;
    final audio = ref.read(audioServiceProvider);
    if (!audio.isPlaying) {
      audio.speak("Find all the '${widget.syllable}' bubbles!");
    }
    _resetInactivityTimer();
  }

  // ── Interaction handler ────────────────────────────────────────────────────

  /// Called on every bubble tap — resets all engagement timers and stops the
  /// nudge animation immediately so the child gets instant visual feedback.
  void _onAnyInteraction() {
    _stopNudge();
    _resetNudgeTimer();
    _resetInactivityTimer();
  }

  // ── Bubble tap logic ───────────────────────────────────────────────────────

  Future<void> _onBubbleTap(int index) async {
    if (_popped.contains(index) || _showPop.contains(index)) return;

    _onAnyInteraction();

    final bubble = _bubbles[index];
    ref.read(audioServiceProvider).speak(bubble.text); // fire-and-forget

    // Local tap counting for accuracy recording.
    _totalTaps++;
    if (bubble.isTarget) _correctTaps++;

    // Also forward to SoundModeNotifier for session analytics.
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
    setState(() {
      _showPop.remove(index);
      _popped.add(index);
    });
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

    // Record accuracy to LevelProvider.
    final accuracy = _totalTaps == 0
        ? 0.0
        : (_correctTaps / _totalTaps).clamp(0.0, 1.0);
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final audioReady = ref.watch(soundModeProvider).audioReady;

    return AnimatedBubbleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // ── Main content ───────────────────────────────────────────────
              Column(
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Tap all "${widget.syllable}"!',
                            style: AppTextStyles.headlineLarge,
                            textAlign: TextAlign.center,
                          ),
                        ).animate().fadeIn(duration: 500.ms),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _complete
                                ? '🎊 All found!'
                                : '${_targetCount - _tappedTargets.length} left to find',
                            key: ValueKey(_tappedTargets.length),
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.textMedium),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Scatter field ──────────────────────────────────────────
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _positions ??= _generatePositions(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );
                        final positions = _positions!;

                        return Stack(
                          children: [
                            for (int i = 0; i < _bubbles.length; i++)
                              if (i < positions.length)
                                Positioned(
                                  left: positions[i].dx - _bubbleSize / 2,
                                  top: positions[i].dy - _bubbleSize / 2,
                                  child: _ScatterBubble(
                                    bubble: _bubbles[i],
                                    index: i,
                                    popped: _popped.contains(i),
                                    showPop: _showPop.contains(i),
                                    tapped: _tappedTargets.contains(i),
                                    size: _bubbleSize,
                                    delay: i * 60,
                                    // Pass the breathing animation only to
                                    // un-tapped, un-popped target bubbles.
                                    breatheAnimation: (
                                      _nudgeActive &&
                                      _bubbles[i].isTarget &&
                                      !_tappedTargets.contains(i) &&
                                      !_popped.contains(i)
                                    )
                                        ? _nudgeScale
                                        : null,
                                    onTap: () => _onBubbleTap(i),
                                    onPopComplete: () => _onPopComplete(i),
                                  ),
                                ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              // ── Next button ────────────────────────────────────────────────
              if (audioReady)
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: MaveNextButton(onTap: widget.onNext),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Individual scatter bubble ─────────────────────────────────────────────────

class _ScatterBubble extends StatefulWidget {
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

  final _Bubble bubble;
  final int index;
  final bool popped;
  final bool showPop;
  final bool tapped;
  final double size;
  final int delay;
  final VoidCallback onTap;
  final VoidCallback onPopComplete;

  /// When non-null and this bubble is an un-tapped target, a breathing
  /// Transform.scale is applied using this animation (range 1.0 → 1.1).
  final Animation<double>? breatheAnimation;

  @override
  State<_ScatterBubble> createState() => _ScatterBubbleState();
}

class _ScatterBubbleState extends State<_ScatterBubble> {
  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.bubbleColors[widget.index % AppColors.bubbleColors.length];
    final isTarget = widget.bubble.isTarget;

    // ── Visual bubble container ──────────────────────────────────────────────
    Widget bubbleVisual = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.tapped
            ? AppColors.accentGreen.withAlpha(200)
            : color.withAlpha(220),
        shape: BoxShape.circle,
        border: isTarget && !widget.tapped
            ? Border.all(color: Colors.white.withAlpha(160), width: 2.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: (widget.tapped ? AppColors.accentGreen : color)
                .withAlpha(100),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.bubble.text,
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    // ── Breathing nudge ──────────────────────────────────────────────────────
    // Applied only to un-tapped, un-popped target bubbles when the animation
    // is active. AnimatedBuilder limits repaints to this subtree only.
    final anim = widget.breatheAnimation;
    if (anim != null && isTarget && !widget.tapped && !widget.popped) {
      bubbleVisual = AnimatedBuilder(
        animation: anim,
        builder: (_, child) =>
            Transform.scale(scale: anim.value, child: child),
        child: bubbleVisual,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Entry + pop-out animations ─────────────────────────────────────
          AnimatedScale(
            scale: widget.popped ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
            child: AnimatedOpacity(
              opacity: widget.popped ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: GestureDetector(
                onTap: widget.onTap,
                child: bubbleVisual,
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: widget.delay))
              .fadeIn(duration: 350.ms)
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 350.ms,
                curve: Curves.elasticOut,
              ),

          // ── Pop explosion overlay ──────────────────────────────────────────
          if (widget.showPop)
            PopExplosion(
              size: widget.size * 1.6,
              onComplete: widget.onPopComplete,
            ),
        ],
      ),
    );
  }
}

class _Bubble {
  const _Bubble({required this.text, required this.isTarget});
  final String text;
  final bool isTarget;
}
