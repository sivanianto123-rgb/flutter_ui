import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/child_performance_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/services/progress_report_service.dart';
import '../../core/utils/syllable_utils.dart';
import '../shared/kid_game_button.dart';
import '../shared/kid_word_art.dart';
import '../shared/train_sort_game.dart';
import '../shared/zone_shell.dart';
import '../word_zone/word_zone_screen.dart';

class ConsonantZoneScreen extends ConsumerStatefulWidget {
  const ConsonantZoneScreen({super.key});

  @override
  ConsumerState<ConsonantZoneScreen> createState() =>
      _ConsonantZoneScreenState();
}

class _Recipe {
  const _Recipe({
    required this.word,
    required this.startLetter,
    required this.answer,
    required this.picture,
  });

  final String word;
  final String startLetter;
  final String answer;
  final KidPicture picture;
}

const _trainItems = <TrainSortItem>[
  TrainSortItem(letter: 'i', word: 'ink', icon: Icons.edit),
  TrainSortItem(letter: 'z', word: 'zebra', icon: Icons.pets),
  TrainSortItem(letter: 'a', word: 'apple', icon: Icons.set_meal),
  TrainSortItem(letter: 'b', word: 'ball', icon: Icons.sports_baseball),
  TrainSortItem(letter: 'e', word: 'egg', icon: Icons.egg_alt_rounded),
  TrainSortItem(letter: 'm', word: 'map', icon: Icons.map),
  TrainSortItem(letter: 'o', word: 'orange', icon: Icons.circle),
  TrainSortItem(letter: 't', word: 'tiger', icon: Icons.cruelty_free),
  TrainSortItem(letter: 'u', word: 'umbrella', icon: Icons.umbrella),
  TrainSortItem(letter: 's', word: 'sun', icon: Icons.wb_sunny),
];

class _ConsonantZoneScreenState extends ConsumerState<ConsonantZoneScreen> {
  static const _startSoundRounds = <_Recipe>[
    _Recipe(
      word: 'cat',
      startLetter: 'c',
      answer: 'c',
      picture: KidPicture.cat,
    ),
    _Recipe(
      word: 'bag',
      startLetter: 'b',
      answer: 'b',
      picture: KidPicture.bag,
    ),
    _Recipe(
      word: 'map',
      startLetter: 'm',
      answer: 'm',
      picture: KidPicture.map,
    ),
  ];

  static const _sortRounds = <String>[
    'b',
    'a',
    'm',
    'e',
    't',
    'o',
  ];

  int _step = 0; // 0 sort, 1 start sound, 2 train
  int _sortRound = 0;
  int _soundRound = 0;

  void _goStep(int step) {
    setState(() {
      _step = step.clamp(0, 2);
      _sortRound = 0;
      _soundRound = 0;
    });
  }

  Future<void> _finishZone() async {
    final unlocked = await ref
        .read(childPerformanceProvider.notifier)
        .completeConsonantZone();
    if (!mounted) return;
    unawaited(_sendReport());
    if (unlocked) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WordZoneScreen()),
      );
    }
  }

  Future<void> _sendReport() async {
    final profile = ref.read(profileProvider).valueOrNull;
    final performance = ref.read(childPerformanceProvider).valueOrNull;
    if (profile == null || performance == null) return;
    await ProgressReportService.sendAutomaticReport(
      profile: profile,
      performance: performance,
      zoneName: 'Consonant Zone',
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = switch (_step) {
      0 => (_sortRound + 1) / _sortRounds.length / 3,
      1 => 1 / 3 + (_soundRound + 1) / _startSoundRounds.length / 3,
      _ => 0.9,
    };

    final subtitle = switch (_step) {
      0 => 'Is this letter a consonant?',
      1 => 'Pick the starting consonant sound',
      _ => 'Drop letters into the train crates!',
    };

    return ZoneShell(
      title: 'Consonant Zone',
      subtitle: subtitle,
      progress: progress,
      checkpointCount: 3,
      currentCheckpoint: _step,
      onCheckpointTap: (i) {
        if (i <= _step) _goStep(i);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        child: switch (_step) {
          0 => _ConsonantSortStep(
              key: ValueKey('sort-$_sortRound'),
              letter: _sortRounds[_sortRound],
              roundLabel: '${_sortRound + 1} / ${_sortRounds.length}',
              onVowelTap: () {
                if (isConsonant(_sortRounds[_sortRound])) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This is a consonant.')),
                  );
                  return;
                }
                _nextSortRound();
              },
              onConsonantTap: () {
                if (!isConsonant(_sortRounds[_sortRound])) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This one is a vowel.')),
                  );
                  return;
                }
                _nextSortRound();
              },
            ),
          1 => _StartSoundStep(
              key: ValueKey('sound-$_soundRound'),
              recipe: _startSoundRounds[_soundRound],
              roundLabel: '${_soundRound + 1} / ${_startSoundRounds.length}',
              onPick: (picked) {
                if (picked != _startSoundRounds[_soundRound].answer) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Try the first sound.')),
                  );
                  return;
                }
                if (_soundRound >= _startSoundRounds.length - 1) {
                  setState(() => _step = 2);
                } else {
                  setState(() => _soundRound += 1);
                }
              },
              done: false,
              onHome: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          _ => TrainSortGame(
              key: const ValueKey('train'),
              items: _trainItems,
              mode: TrainCrateMode.consonantsOnly,
              targetCount: 5,
              onComplete: () => unawaited(_finishZone()),
            ),
        },
      ),
    );
  }

  void _nextSortRound() {
    if (_sortRound >= _sortRounds.length - 1) {
      setState(() => _step = 1);
      return;
    }
    setState(() => _sortRound += 1);
  }
}

class _ConsonantSortStep extends StatelessWidget {
  const _ConsonantSortStep({
    super.key,
    required this.letter,
    required this.roundLabel,
    required this.onVowelTap,
    required this.onConsonantTap,
  });

  final String letter;
  final String roundLabel;
  final VoidCallback onVowelTap;
  final VoidCallback onConsonantTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Round $roundLabel',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 130,
          height: 130,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFB74D), width: 4),
          ),
          child: Text(
            letter.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF4E342E),
              fontSize: 72,
              fontWeight: FontWeight.w900,
            ),
          ),
        ).animate().scale(
              begin: const Offset(0.75, 0.75),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
            ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: KidGameButton(
                label: 'Vowel',
                color: const Color(0xFFFF8A65),
                icon: Icons.favorite_rounded,
                onPressed: onVowelTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: KidGameButton(
                label: 'Consonant',
                color: const Color(0xFF5A7DFF),
                icon: Icons.star_rounded,
                onPressed: onConsonantTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StartSoundStep extends StatelessWidget {
  const _StartSoundStep({
    super.key,
    required this.recipe,
    required this.roundLabel,
    required this.onPick,
    required this.done,
    required this.onHome,
  });

  final _Recipe recipe;
  final String roundLabel;
  final ValueChanged<String> onPick;
  final bool done;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final choices = <String>[
      recipe.startLetter,
      'b',
      'm',
      'c',
      't',
    ].toSet().toList()
      ..shuffle();

    return Column(
      children: [
        Text(
          'Round $roundLabel',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        KidWordArt(picture: recipe.picture, size: 100),
        const SizedBox(height: 10),
        Text(
          'Word: ${recipe.word.toUpperCase()}',
          style: const TextStyle(
            color: Color(0xFFFFF59D),
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Pick the first sound',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: choices
              .map(
                (letter) => SizedBox(
                  width: 82,
                  child: KidGameButton(
                    label: letter.toUpperCase(),
                    compact: true,
                    color: const Color(0xFF5A7DFF),
                    onPressed: done ? null : () => onPick(letter),
                  ),
                ),
              )
              .toList(),
        ),
        const Spacer(),
        if (done)
          KidGameButton(
            label: 'Back to Home',
            icon: Icons.home_rounded,
            color: const Color(0xFF5A7DFF),
            onPressed: onHome,
          ),
      ],
    );
  }
}
