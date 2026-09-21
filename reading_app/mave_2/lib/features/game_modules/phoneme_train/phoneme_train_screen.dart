import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Phoneme Train — tap the correct wagon to make the train move.
///
/// 3 rounds. Each round shows 3 wagons (1 target + 2 distractors).
/// Child taps the wagon with the target syllable → train chugs forward.
/// Accuracy = first-try taps / total rounds.
class PhonemeTrainScreen extends ConsumerStatefulWidget {
  const PhonemeTrainScreen({
    super.key,
    required this.syllable,
    required this.activityId,
    required this.onComplete,
    required this.onExit,
  });

  final String syllable;
  final String activityId;
  final VoidCallback onComplete;
  final VoidCallback onExit;

  @override
  ConsumerState<PhonemeTrainScreen> createState() =>
      _PhonemeTrainScreenState();
}

class _PhonemeTrainScreenState extends ConsumerState<PhonemeTrainScreen>
    with SingleTickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────

  static const int _totalRounds  = 3;
  static const List<String> _distractors = ['ba', 'da', 'ta', 'na', 'sa', 'la'];

  int  _round        = 0;
  int  _firstTryOk   = 0;
  bool _firstTry     = true;
  bool _complete     = false;
  bool _chugAnimating = false;

  late List<String> _wagons; // 3 syllables, shuffled
  int?              _tappedIndex;

  late final AnimationController _chugController;
  final _rng = Random();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _chugController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buildWagons();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playInstruction());
  }

  @override
  void dispose() {
    _chugController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _buildWagons() {
    final d = [..._distractors]..shuffle(_rng);
    _wagons = [widget.syllable, d[0], d[1]]..shuffle(_rng);
    _firstTry    = true;
    _tappedIndex = null;
  }

  int get _correctIndex => _wagons.indexOf(widget.syllable);

  Future<void> _playInstruction() async {
    if (!mounted) return;
    try {
      final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
      await ref.read(audioServiceProvider)
          .speak('Tap the wagon that says $phonetic!');
    } catch (_) {}
  }

  // ── Interaction ────────────────────────────────────────────────────────────

  Future<void> _onWagonTap(int index) async {
    if (_chugAnimating || _complete || _tappedIndex != null) return;

    setState(() => _tappedIndex = index);

    final isCorrect = index == _correctIndex;

    if (isCorrect) {
      if (_firstTry) _firstTryOk++;
      setState(() => _chugAnimating = true);
      await _chugController.forward(from: 0);
      _chugController.reset();
      if (!mounted) return;
      setState(() => _chugAnimating = false);

      try {
        await ref.read(audioServiceProvider).speak('Choo choo! Great job!');
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      _round++;
      if (_round >= _totalRounds) {
        _finish();
      } else {
        setState(_buildWagons);
        _playInstruction();
      }
    } else {
      _firstTry = false;
      try {
        final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
        await ref.read(audioServiceProvider).speak('Find the $phonetic wagon!');
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _tappedIndex = null);
    }
  }

  Future<void> _finish() async {
    setState(() => _complete = true);
    final accuracy = (_firstTryOk / _totalRounds).clamp(0.0, 1.0);
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);

    try {
      await ref.read(audioServiceProvider)
          .speak('All aboard! The train is full!');
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) widget.onComplete();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(round: _round, total: _totalRounds, onBack: widget.onExit),

            const Spacer(),

            if (_complete) ...[
              const Text('🚂', style: TextStyle(fontSize: 80))
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 16),
              Text(
                'All aboard! Choo choo!',
                style: AppTextStyles.headlineLarge
                    .copyWith(color: AppColors.accentGreen),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // Train engine
              AnimatedBuilder(
                animation: _chugController,
                builder: (ctx, child) => Transform.translate(
                  offset: Offset(_chugController.value * 20, 0),
                  child: child,
                ),
                child: const Text('🚂', style: TextStyle(fontSize: 72))
                    .animate(key: ValueKey(_round))
                    .fadeIn(duration: 300.ms),
              ),

              const SizedBox(height: 8),

              Text(
                'Tap the ${PhoneticHelper.toPhonetic(widget.syllable)} wagon!',
                style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textDark, fontSize: 20),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Wagons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _wagons.length,
                  (i) => _WagonTile(
                    syllable:  _wagons[i],
                    index:     i,
                    tapped:    _tappedIndex == i,
                    isCorrect: i == _correctIndex,
                    onTap:     () => _onWagonTap(i),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: _playInstruction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up_rounded,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text('Hear it again',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ── Wagon tile ─────────────────────────────────────────────────────────────────

class _WagonTile extends StatelessWidget {
  const _WagonTile({
    required this.syllable,
    required this.index,
    required this.tapped,
    required this.isCorrect,
    required this.onTap,
  });

  final String       syllable;
  final int          index;
  final bool         tapped;
  final bool         isCorrect;
  final VoidCallback onTap;

  static const List<Color> _wagonColors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _wagonColors[index % _wagonColors.length];

    Color bgColor = color.withAlpha(200);
    if (tapped) {
      bgColor = isCorrect
          ? AppColors.accentGreen.withAlpha(220)
          : Colors.red.withAlpha(120);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: tapped
              ? Border.all(
                  color: isCorrect ? AppColors.accentGreen : Colors.red,
                  width: 3)
              : Border.all(color: Colors.white.withAlpha(180), width: 2),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(80),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              syllable.toUpperCase(),
              style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900),
            ),
            if (tapped && isCorrect)
              const Icon(Icons.check_rounded, color: Colors.white, size: 20),
            if (tapped && !isCorrect)
              const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.round, required this.total, required this.onBack});
  final int          round;
  final int          total;
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text('Phoneme Train 🚂',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textDark, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${round + 1} / $total',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
