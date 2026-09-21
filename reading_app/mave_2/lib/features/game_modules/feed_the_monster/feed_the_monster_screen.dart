import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/providers/level_provider.dart';
import '../../../core/services/app_providers.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Feed the Monster — drag the correct syllable bubble into the monster's mouth.
///
/// 3 rounds. First-try accuracy recorded to [LevelNotifier] via [activityId].
class FeedTheMonsterScreen extends ConsumerStatefulWidget {
  const FeedTheMonsterScreen({
    super.key,
    required this.syllable,
    required this.activityId,
    required this.onComplete,
    required this.onExit,
  });

  /// Target phoneme, e.g. 'ma' or 'pa'.
  final String syllable;

  /// Activity ID for [LevelNotifier] recording, e.g. 'ma_feed_monster'.
  final String activityId;

  final VoidCallback onComplete;
  final VoidCallback onExit;

  @override
  ConsumerState<FeedTheMonsterScreen> createState() =>
      _FeedTheMonsterScreenState();
}

class _FeedTheMonsterScreenState extends ConsumerState<FeedTheMonsterScreen>
    with TickerProviderStateMixin {
  // ── Game state ─────────────────────────────────────────────────────────────

  static const int _totalRounds = 3;

  int  _round           = 0;
  int  _firstTryCount   = 0;
  bool _currentFirstTry = true;
  bool _mouthOpen       = false;
  bool _shaking         = false;
  bool _complete        = false;

  late List<_Bubble> _bubbles;
  final _rng = math.Random();

  // ── Animations ─────────────────────────────────────────────────────────────

  late final AnimationController _chompController;
  late final AnimationController _shakeController;
  late final AnimationController _bobControllerA;
  late final AnimationController _bobControllerB;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _chompController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _bobControllerA = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _bobControllerB = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1700))
      ..repeat(reverse: true);

    _buildBubbles();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playInstruction());
  }

  @override
  void dispose() {
    _chompController.dispose();
    _shakeController.dispose();
    _bobControllerA.dispose();
    _bobControllerB.dispose();
    super.dispose();
  }

  // ── Bubble setup ───────────────────────────────────────────────────────────

  void _buildBubbles() {
    final target     = widget.syllable;
    final distractor = target == 'ma' ? 'pa' : 'ma';

    _bubbles = [
      _Bubble(id: target,     label: target.toUpperCase(),     isTarget: true),
      _Bubble(id: distractor, label: distractor.toUpperCase(), isTarget: false),
    ]..shuffle(_rng);

    _currentFirstTry = true;
  }

  // ── Audio ──────────────────────────────────────────────────────────────────

  Future<void> _playInstruction() async {
    if (!mounted) return;
    try {
      final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
      await ref.read(audioServiceProvider).speak('Give me the $phonetic!');
    } catch (e) {
      debugPrint('[FTM] Instruction audio failed: $e');
    }
  }

  Future<void> _playNomNom() async {
    if (!mounted) return;
    try {
      await ref.read(audioServiceProvider).speak('Nom nom nom! Yummy!');
    } catch (e) {
      debugPrint('[FTM] Nom nom audio failed: $e');
    }
  }

  Future<void> _playOops() async {
    if (!mounted) return;
    try {
      final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
      await ref.read(audioServiceProvider).speak('Oops! Try the $phonetic one!');
    } catch (e) {
      debugPrint('[FTM] Oops audio failed: $e');
    }
  }

  // ── Drop handling ──────────────────────────────────────────────────────────

  void _onDrop(bool isTarget) {
    if (_complete) return;
    isTarget ? _onCorrectDrop() : _onWrongDrop();
  }

  void _onCorrectDrop() {
    if (_currentFirstTry) _firstTryCount++;

    setState(() => _mouthOpen = true);
    _chompController.forward(from: 0).then((_) {
      if (!mounted) return;
      _chompController.reverse();
      setState(() => _mouthOpen = false);
    });

    _playNomNom();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _round++;
      if (_round >= _totalRounds) {
        _finish();
      } else {
        setState(_buildBubbles);
        _playInstruction();
      }
    });
  }

  void _onWrongDrop() {
    _currentFirstTry = false;
    setState(() => _shaking = true);
    _shakeController.forward(from: 0).then((_) {
      if (!mounted) return;
      _shakeController.reset();
      setState(() => _shaking = false);
    });
    _playOops();
  }

  Future<void> _finish() async {
    final accuracy = (_firstTryCount / _totalRounds).clamp(0.0, 1.0);
    setState(() => _complete = true);

    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) widget.onComplete();
    });
  }

  // ── Progress ───────────────────────────────────────────────────────────────

  double get _progress => _round / _totalRounds;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F8),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(progress: _progress, onBack: widget.onExit),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                _complete
                    ? '🎉 Amazing! You fed the monster!'
                    : 'Drag the ${widget.syllable.toUpperCase()} to the monster!',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 20,
                  color: AppColors.textDark,
                ),
              ).animate(key: ValueKey(_round)).fadeIn(duration: 300.ms),
            ),

            Text(
              'Round ${math.min(_round + 1, _totalRounds)} of $_totalRounds',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            // Monster drop target
            Expanded(
              flex: 3,
              child: Center(
                child: DragTarget<bool>(
                  onAcceptWithDetails: (d) => _onDrop(d.data),
                  builder: (ctx, candidateData, rejectedData) {
                    final hovering = candidateData.isNotEmpty;
                    return AnimatedBuilder(
                      animation:
                          Listenable.merge([_chompController, _shakeController]),
                      builder: (ctx, child) {
                        final shakeOffset = _shaking &&
                                _shakeController.isAnimating
                            ? math.sin(_shakeController.value * math.pi * 4) *
                                10
                            : 0.0;
                        return Transform.translate(
                          offset: Offset(shakeOffset, 0),
                          child: _MonsterWidget(
                            mouthOpen: _mouthOpen || hovering,
                            chompValue: _chompController.value,
                            celebrating: _complete,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Draggable bubbles
            if (!_complete)
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _BubbleWidget(
                        bubble: _bubbles[0],
                        bobAnim: _bobControllerA,
                        onDrop: _onDrop),
                    _BubbleWidget(
                        bubble: _bubbles[1],
                        bobAnim: _bobControllerB,
                        onDrop: _onDrop),
                  ],
                ),
              ),

            if (_complete)
              Expanded(
                flex: 2,
                child: const Center(
                  child: Icon(Icons.star_rounded,
                      size: 100, color: AppColors.accent),
                ),
              ).animate().scale(
                    begin: const Offset(0.2, 0.2),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Monster ────────────────────────────────────────────────────────────────────

class _MonsterWidget extends StatelessWidget {
  const _MonsterWidget({
    required this.mouthOpen,
    required this.chompValue,
    required this.celebrating,
  });
  final bool   mouthOpen;
  final double chompValue;
  final bool   celebrating;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 200,
        height: 200,
        child: CustomPaint(
          painter: _MonsterPainter(
            mouthOpen: mouthOpen,
            chompValue: chompValue,
            celebrating: celebrating,
          ),
        ),
      );
}

class _MonsterPainter extends CustomPainter {
  _MonsterPainter({
    required this.mouthOpen,
    required this.chompValue,
    required this.celebrating,
  });
  final bool   mouthOpen;
  final double chompValue;
  final bool   celebrating;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.42;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = celebrating
            ? const Color(0xFF95D5B2)
            : const Color(0xFF6ECBA0),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color       = const Color(0xFF3A8A5C)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final hornPaint = Paint()..color = const Color(0xFF5BB885);
    for (final dx in [-r * 0.45, r * 0.45]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + dx, cy - r * 0.85), width: 22, height: 36),
        hornPaint,
      );
    }

    _drawEye(canvas, Offset(cx - r * 0.32, cy - r * 0.22), 18);
    _drawEye(canvas, Offset(cx + r * 0.32, cy - r * 0.22), 18);

    final mouthRect = Rect.fromCenter(
      center: Offset(cx, cy + r * 0.30),
      width: r * 1.0,
      height: mouthOpen ? r * 0.70 + chompValue * 12 : r * 0.22,
    );
    canvas.drawOval(mouthRect, Paint()..color = const Color(0xFFBF2B2B));

    if (mouthOpen) {
      final toothPaint = Paint()..color = Colors.white;
      final spacing    = mouthRect.width / 4;
      for (int i = 0; i < 3; i++) {
        final tx = mouthRect.left + spacing * (i + 0.5) + 4;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(tx, mouthRect.top + 4, 12, 14),
            const Radius.circular(4),
          ),
          toothPaint,
        );
      }
    }
  }

  void _drawEye(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius * 0.55, Paint()..color = Colors.black87);
    canvas.drawCircle(
      center + Offset(radius * 0.2, -radius * 0.2),
      radius * 0.18,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_MonsterPainter old) =>
      old.mouthOpen != mouthOpen ||
      old.chompValue != chompValue ||
      old.celebrating != celebrating;
}

// ── Bubble ─────────────────────────────────────────────────────────────────────

class _Bubble {
  _Bubble({required this.id, required this.label, required this.isTarget});
  final String id;
  final String label;
  final bool   isTarget;
}

class _BubbleWidget extends StatelessWidget {
  const _BubbleWidget({
    required this.bubble,
    required this.bobAnim,
    required this.onDrop,
  });

  final _Bubble              bubble;
  final AnimationController  bobAnim;
  final void Function(bool)  onDrop;

  static const Map<String, Color> _colors = {
    'ma': AppColors.primary,
    'pa': AppColors.secondary,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[bubble.id] ?? AppColors.accent;

    final child = Container(
      width: 110, height: 110,
      decoration: BoxDecoration(
        color: color.withAlpha(220),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Center(
        child: Text(
          bubble.label,
          style: AppTextStyles.headlineLarge.copyWith(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: bobAnim,
      builder: (ctx, ch) => Transform.translate(
        offset: Offset(0, -12 + bobAnim.value * 12),
        child: Draggable<bool>(
          data: bubble.isTarget,
          maxSimultaneousDrags: 1,
          feedback: Material(
            color: Colors.transparent,
            child: Transform.scale(scale: 1.08, child: child),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: child),
          child: child,
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, required this.onBack});
  final double       progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.textMedium),
                  const SizedBox(width: 4),
                  Text('Home',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMedium, fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (ctx, v, child) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  backgroundColor: AppColors.primary.withAlpha(38),
                  color: AppColors.accentGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
