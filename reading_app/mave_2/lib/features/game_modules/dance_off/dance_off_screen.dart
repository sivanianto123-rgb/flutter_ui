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

/// Dance Off — tap the target phoneme pad each time it lights up in the sequence.
///
/// A 4-pad rhythm game. One pad is the target syllable; 3 are distractors.
/// Each round plays a short beat sequence (3 beats), lighting up 1–2 target pads.
/// Child taps the lit target pad to score.  3 rounds total.
class DanceOffScreen extends ConsumerStatefulWidget {
  const DanceOffScreen({
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
  ConsumerState<DanceOffScreen> createState() => _DanceOffScreenState();
}

class _DanceOffScreenState extends ConsumerState<DanceOffScreen> {
  // ── Pads ───────────────────────────────────────────────────────────────────

  static const List<String> _distractors = ['ba', 'da', 'ta'];

  late final List<_Pad> _pads; // 4 pads: 1 target + 3 distractors

  // ── State ──────────────────────────────────────────────────────────────────

  static const int _totalRounds  = 3;
  static const int _beatsPerRound = 4;

  int  _round        = 0;
  int  _score        = 0; // correct taps
  int  _beatIndex    = 0;
  bool _complete     = false;
  bool _sequencePlaying = false;

  /// Which pad index is currently "lit" (null = none).
  int? _litPad;

  /// Expected taps this round (only lit pads that are the target).
  int _roundScore = 0;

  Timer? _beatTimer;

  late List<int> _beatSequence; // pad indices for this round's beats

  final _rng = Random();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Build pads: target first, then distractors, then shuffle display order.
    _pads = [
      _Pad(syllable: widget.syllable, isTarget: true),
      ..._distractors.map((d) => _Pad(syllable: d, isTarget: false)),
    ]..shuffle(_rng);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startRound());
  }

  @override
  void dispose() {
    _beatTimer?.cancel();
    super.dispose();
  }

  // ── Round logic ────────────────────────────────────────────────────────────

  Future<void> _startRound() async {
    if (!mounted) return;

    // Build a sequence of 4 beats; target appears 1–2 times.
    final targetIndex = _pads.indexWhere((p) => p.isTarget);
    _beatSequence = _buildBeatSequence(targetIndex);
    _roundScore   = 0;

    setState(() {
      _litPad          = null;
      _sequencePlaying = false;
      _beatIndex       = 0;
    });

    try {
      final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
      await ref.read(audioServiceProvider)
          .speak('Tap $phonetic when it lights up! Ready?');
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _playBeatSequence();
  }

  List<int> _buildBeatSequence(int targetIndex) {
    // Guarantee target appears at least once.
    final sequence = <int>[targetIndex];
    final nonTarget = List.generate(_pads.length, (i) => i)
        .where((i) => i != targetIndex)
        .toList()
      ..shuffle(_rng);

    // Fill remaining beats with mix of target + distractors.
    for (int i = 1; i < _beatsPerRound; i++) {
      // 40% chance of target on remaining beats
      if (_rng.nextDouble() < 0.40 && sequence.where((s) => s == targetIndex).length < 2) {
        sequence.add(targetIndex);
      } else {
        sequence.add(nonTarget[i % nonTarget.length]);
      }
    }
    sequence.shuffle(_rng);
    return sequence;
  }

  void _playBeatSequence() {
    setState(() => _sequencePlaying = true);
    _beatIndex = 0;

    _beatTimer = Timer.periodic(const Duration(milliseconds: 900), (t) {
      if (!mounted || _complete) { t.cancel(); return; }

      if (_beatIndex >= _beatSequence.length) {
        t.cancel();
        _endRound();
        return;
      }

      setState(() => _litPad = _beatSequence[_beatIndex]);
      _beatIndex++;

      // Unlight after 600 ms
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _litPad = null);
      });
    });
  }

  void _endRound() {
    setState(() => _sequencePlaying = false);
    _score += (_roundScore > 0 ? 1 : 0);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _round++;
      if (_round >= _totalRounds) {
        _finish();
      } else {
        _startRound();
      }
    });
  }

  // ── Tap handling ───────────────────────────────────────────────────────────

  void _onPadTap(int index) {
    if (_complete || !_sequencePlaying) return;
    if (_litPad != index) return; // only accept taps while the pad is lit

    final isTarget = _pads[index].isTarget;
    if (isTarget) {
      _roundScore++;
      setState(() {}); // trigger visual feedback
    }
  }

  // ── Finish ─────────────────────────────────────────────────────────────────

  Future<void> _finish() async {
    setState(() => _complete = true);
    final accuracy = (_score / _totalRounds).clamp(0.0, 1.0);
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);

    try {
      await ref.read(audioServiceProvider).speak('You rocked the dance floor!');
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) widget.onComplete();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(round: _round, total: _totalRounds, onBack: widget.onExit),

            const Spacer(),

            if (_complete) ...[
              const Text('🕺', style: TextStyle(fontSize: 80))
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 1200.ms,
                      color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                'You rocked it!',
                style: AppTextStyles.headlineLarge
                    .copyWith(color: AppColors.accent),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                _sequencePlaying
                    ? 'Tap ${PhoneticHelper.toPhonetic(widget.syllable)} when it lights up!'
                    : 'Get ready...',
                style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey(_sequencePlaying)).fadeIn(),

              const SizedBox(height: 32),

              // 2×2 grid of pads
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: List.generate(_pads.length, (i) => _PadTile(
                  pad:      _pads[i],
                  index:    i,
                  isLit:    _litPad == i,
                  onTap:    () => _onPadTap(i),
                )),
              ),

              const SizedBox(height: 24),

              if (!_sequencePlaying && _round < _totalRounds)
                Text(
                  'Round ${_round + 1} of $_totalRounds',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white60),
                ),
            ],

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ── Pad tile ───────────────────────────────────────────────────────────────────

class _Pad {
  _Pad({required this.syllable, required this.isTarget});
  final String syllable;
  final bool   isTarget;
}

class _PadTile extends StatelessWidget {
  const _PadTile({
    required this.pad,
    required this.index,
    required this.isLit,
    required this.onTap,
  });

  final _Pad         pad;
  final int          index;
  final bool         isLit;
  final VoidCallback onTap;

  static const List<Color> _baseColors = [
    Color(0xFF6200EA),
    Color(0xFF00BCD4),
    Color(0xFFFF6F00),
    Color(0xFF2E7D32),
  ];

  static const List<Color> _litColors = [
    Color(0xFFD500F9),
    Color(0xFF00E5FF),
    Color(0xFFFFD600),
    Color(0xFF69F0AE),
  ];

  @override
  Widget build(BuildContext context) {
    final base = _baseColors[index % _baseColors.length];
    final lit  = _litColors[index % _litColors.length];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: isLit ? lit : base,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isLit
              ? [
                  BoxShadow(
                      color: lit.withAlpha(180),
                      blurRadius: 24,
                      spreadRadius: 4),
                ]
              : [
                  BoxShadow(
                      color: base.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 4)),
                ],
        ),
        child: Center(
          child: Text(
            pad.syllable.toUpperCase(),
            style: AppTextStyles.headlineLarge.copyWith(
              color: isLit ? Colors.black87 : Colors.white.withAlpha(200),
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
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
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: Colors.white.withAlpha(200)),
                  const SizedBox(width: 4),
                  Text('Home',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white.withAlpha(200))),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text('Dance Off 🕺',
              style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${round + 1} / $total',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
