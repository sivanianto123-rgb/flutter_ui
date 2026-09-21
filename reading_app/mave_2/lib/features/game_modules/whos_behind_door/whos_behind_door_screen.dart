import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _DoorRound {
  const _DoorRound({
    required this.doors,       // 3 items (emoji + label)
    required this.correctIndex,
  });
  final List<_DoorItem> doors;
  final int             correctIndex;
}

class _DoorItem {
  const _DoorItem({required this.emoji, required this.label});
  final String emoji;
  final String label;
}

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Who's Behind the Door? — hear a phoneme, open the matching door.
///
/// 3 rounds. Each round plays the target phoneme and shows 3 doors;
/// one hides an image/emoji whose name starts with that phoneme.
/// Accuracy = correct first-try taps / total rounds.
class WhosBehindDoorScreen extends ConsumerStatefulWidget {
  const WhosBehindDoorScreen({
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
  ConsumerState<WhosBehindDoorScreen> createState() =>
      _WhosBehindDoorScreenState();
}

class _WhosBehindDoorScreenState extends ConsumerState<WhosBehindDoorScreen> {
  // ── Round data ─────────────────────────────────────────────────────────────

  static const _maRounds = [
    _DoorRound(
      doors: [
        _DoorItem(emoji: '🐒', label: 'Monkey'),
        _DoorItem(emoji: '🦁', label: 'Lion'),
        _DoorItem(emoji: '🐠', label: 'Fish'),
      ],
      correctIndex: 0, // Monkey → starts with M
    ),
    _DoorRound(
      doors: [
        _DoorItem(emoji: '🐶', label: 'Dog'),
        _DoorItem(emoji: '🌙', label: 'Moon'),
        _DoorItem(emoji: '🐸', label: 'Frog'),
      ],
      correctIndex: 1, // Moon → M
    ),
    _DoorRound(
      doors: [
        _DoorItem(emoji: '🐱', label: 'Cat'),
        _DoorItem(emoji: '🌈', label: 'Rainbow'),
        _DoorItem(emoji: '🏔️', label: 'Mountain'),
      ],
      correctIndex: 2, // Mountain → M
    ),
  ];

  static const _paRounds = [
    _DoorRound(
      doors: [
        _DoorItem(emoji: '🦜', label: 'Parrot'),
        _DoorItem(emoji: '🐳', label: 'Whale'),
        _DoorItem(emoji: '🦊', label: 'Fox'),
      ],
      correctIndex: 0, // Parrot → P
    ),
    _DoorRound(
      doors: [
        _DoorItem(emoji: '🐭', label: 'Mouse'),
        _DoorItem(emoji: '🍕', label: 'Pizza'),
        _DoorItem(emoji: '🦋', label: 'Butterfly'),
      ],
      correctIndex: 1, // Pizza → P
    ),
    _DoorRound(
      doors: [
        _DoorItem(emoji: '🐙', label: 'Octopus'),
        _DoorItem(emoji: '🐸', label: 'Frog'),
        _DoorItem(emoji: '🐼', label: 'Panda'),
      ],
      correctIndex: 2, // Panda → P
    ),
  ];

  // ── State ──────────────────────────────────────────────────────────────────

  int  _round        = 0;
  int  _firstTryOk   = 0;
  bool _firstTry     = true;
  bool _complete     = false;
  int? _openedDoor;         // index of the door currently open
  bool _showingResult = false;

  final _rng = Random();
  late List<_DoorRound> _rounds;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _rounds = (widget.syllable == 'ma' ? _maRounds : _paRounds).toList()
      ..shuffle(_rng);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playInstruction());
  }

  // ── Round helpers ──────────────────────────────────────────────────────────

  _DoorRound get _current => _rounds[_round % _rounds.length];

  Future<void> _playInstruction() async {
    if (!mounted) return;
    try {
      final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
      await ref.read(audioServiceProvider)
          .speak('Which one starts with $phonetic? Tap to find out!');
    } catch (_) {}
  }

  Future<void> _onDoorTap(int index) async {
    if (_showingResult || _complete) return;

    setState(() {
      _openedDoor  = index;
      _showingResult = true;
    });

    final isCorrect = index == _current.correctIndex;

    if (isCorrect) {
      if (_firstTry) _firstTryOk++;
      try {
        await ref.read(audioServiceProvider).speak(
            '${_current.doors[index].label}! That starts with '
            '${PhoneticHelper.toPhonetic(widget.syllable)}!');
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      _nextRound();
    } else {
      _firstTry = false;
      try {
        await ref.read(audioServiceProvider).speak('Try another door!');
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _openedDoor    = null;
        _showingResult = false;
      });
    }
  }

  void _nextRound() {
    _round++;
    if (_round >= 3) {
      _finish();
    } else {
      setState(() {
        _openedDoor    = null;
        _showingResult = false;
        _firstTry      = true;
      });
      _playInstruction();
    }
  }

  Future<void> _finish() async {
    setState(() => _complete = true);
    final accuracy = (_firstTryOk / 3).clamp(0.0, 1.0);
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);

    try {
      await ref.read(audioServiceProvider).speak('You found them all! Amazing!');
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) widget.onComplete();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(round: _round, total: 3, onBack: widget.onExit),

            const Spacer(),

            if (_complete) ...[
              const Text('🎉', style: TextStyle(fontSize: 80))
                  .animate().scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                'You found them all!',
                style: AppTextStyles.headlineLarge
                    .copyWith(color: AppColors.accentGreen),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Tap the door that hides the '
                  '${PhoneticHelper.toPhonetic(widget.syllable)} sound!',
                  style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textDark, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (i) => _DoorTile(
                  item:     _current.doors[i],
                  index:    i,
                  isOpen:   _openedDoor == i,
                  isCorrect: i == _current.correctIndex,
                  onTap:    () => _onDoorTap(i),
                )),
              ),

              const SizedBox(height: 16),

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

// ── Door tile ─────────────────────────────────────────────────────────────────

class _DoorTile extends StatelessWidget {
  const _DoorTile({
    required this.item,
    required this.index,
    required this.isOpen,
    required this.isCorrect,
    required this.onTap,
  });

  final _DoorItem    item;
  final int          index;
  final bool         isOpen;
  final bool         isCorrect;
  final VoidCallback onTap;

  static const List<Color> _doorColors = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF6C00),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _doorColors[index % _doorColors.length];

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        height: 160,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: isOpen
              ? _OpenDoor(
                  key: const ValueKey('open'),
                  item: item,
                  isCorrect: isCorrect,
                  color: color,
                )
              : _ClosedDoor(
                  key: const ValueKey('closed'),
                  color: color,
                  doorNumber: index + 1,
                ),
        ),
      ),
    );
  }
}

class _ClosedDoor extends StatelessWidget {
  const _ClosedDoor({super.key, required this.color, required this.doorNumber});
  final Color color;
  final int   doorNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🚪', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Container(
            width: 16, height: 16,
            decoration: const BoxDecoration(
                color: Colors.white60, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _OpenDoor extends StatelessWidget {
  const _OpenDoor({
    super.key,
    required this.item,
    required this.isCorrect,
    required this.color,
  });
  final _DoorItem item;
  final bool      isCorrect;
  final Color     color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.accentGreen.withAlpha(60) : Colors.red.withAlpha(30),
        border: Border.all(
            color: isCorrect ? AppColors.accentGreen : Colors.red,
            width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 52))
              .animate()
              .scale(
                begin: const Offset(0.4, 0.4),
                end: const Offset(1.0, 1.0),
                duration: 350.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
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
          Text('Who\'s Behind the Door?',
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
