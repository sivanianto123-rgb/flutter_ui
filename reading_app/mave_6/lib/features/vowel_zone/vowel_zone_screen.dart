import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/child_performance_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/services/progress_report_service.dart';
import '../../core/utils/syllable_utils.dart';
import '../consonant_zone/consonant_zone_screen.dart';
import '../shared/kid_game_button.dart';
import '../shared/train_sort_game.dart';
import '../shared/zone_shell.dart';

// ─── Data ────────────────────────────────────────────────────────────────────

class _VowelInfo {
  const _VowelInfo({
    required this.letter,
    required this.sound,
    required this.word,
    required this.color,
    required this.emoji,
  });
  final String letter;
  final String sound;   // e.g. "sounds like aah"
  final String word;    // example word
  final Color color;
  final IconData emoji; // icon instead of emoji text
}

const _vowels = <_VowelInfo>[
  _VowelInfo(letter: 'A', sound: '"aah"  as in', word: 'Apple', color: Color(0xFFEF5350), emoji: Icons.set_meal),
  _VowelInfo(letter: 'E', sound: '"eh"  as in',  word: 'Egg',   color: Color(0xFFAB47BC), emoji: Icons.egg_alt_rounded),
  _VowelInfo(letter: 'I', sound: '"ih"  as in',  word: 'Igloo', color: Color(0xFF42A5F5), emoji: Icons.home_rounded),
  _VowelInfo(letter: 'O', sound: '"oh"  as in',  word: 'Orange',color: Color(0xFFFF7043), emoji: Icons.circle_rounded),
  _VowelInfo(letter: 'U', sound: '"uh"  as in',  word: 'Umbrella', color: Color(0xFF26A69A), emoji: Icons.umbrella_rounded),
];

// balloon grid: each row has a letter and whether it is a vowel
class _BalloonRound {
  const _BalloonRound(this.letters);
  final List<String> letters; // 9 letters
}

const _balloonRounds = <_BalloonRound>[
  _BalloonRound(['a', 'g', 'b', 'i', 'j', 'e', 'c', 'u', 's']),
  _BalloonRound(['m', 'o', 't', 'a', 'z', 'y', 'i', 'n', 'e']),
  _BalloonRound(['d', 'u', 'k', 'o', 'f', 'a', 'r', 'e', 'p']),
];

class _WordFindRound {
  const _WordFindRound(this.word);
  final String word;
}

const _wordRounds = <_WordFindRound>[
  _WordFindRound('cat'),
  _WordFindRound('bat'),
  _WordFindRound('sun'),
  _WordFindRound('dog'),
  _WordFindRound('map'),
];

// ─── Screen ──────────────────────────────────────────────────────────────────

enum _Phase { teach, balloon, findInWord, train }

const _trainItems = <TrainSortItem>[
  TrainSortItem(letter: 'a', word: 'apple', icon: Icons.set_meal),
  TrainSortItem(letter: 'b', word: 'ball', icon: Icons.sports_baseball),
  TrainSortItem(letter: 'e', word: 'egg', icon: Icons.egg_alt_rounded),
  TrainSortItem(letter: 'z', word: 'zebra', icon: Icons.pets),
  TrainSortItem(letter: 'i', word: 'ink', icon: Icons.edit),
  TrainSortItem(letter: 'm', word: 'map', icon: Icons.map),
  TrainSortItem(letter: 'o', word: 'orange', icon: Icons.circle),
  TrainSortItem(letter: 't', word: 'tiger', icon: Icons.cruelty_free),
  TrainSortItem(letter: 'u', word: 'umbrella', icon: Icons.umbrella),
  TrainSortItem(letter: 'c', word: 'cat', icon: Icons.pets_outlined),
];

class VowelZoneScreen extends ConsumerStatefulWidget {
  const VowelZoneScreen({super.key});

  @override
  ConsumerState<VowelZoneScreen> createState() => _VowelZoneScreenState();
}

class _VowelZoneScreenState extends ConsumerState<VowelZoneScreen> {
  _Phase _phase = _Phase.teach;

  // teach phase
  int _teachIndex = 0;

  // balloon phase
  int _balloonRound = 0;
  final Set<int> _popped = {};

  // word-find phase
  int _wordRound = 0;
  int? _tappedIndex;
  bool _wordCorrect = false;

  double get _progress {
    switch (_phase) {
      case _Phase.teach:
        return (_teachIndex + 1) / _vowels.length / 4;
      case _Phase.balloon:
        return 1 / 4 + (_balloonRound + 1) / _balloonRounds.length / 4;
      case _Phase.findInWord:
        return 2 / 4 + (_wordRound + 1) / _wordRounds.length / 4;
      case _Phase.train:
        return 0.9;
    }
  }

  int get _checkpoint {
    switch (_phase) {
      case _Phase.teach:      return 0;
      case _Phase.balloon:    return 1;
      case _Phase.findInWord: return 2;
      case _Phase.train:      return 3;
    }
  }

  String get _subtitle {
    switch (_phase) {
      case _Phase.teach:      return 'Learn each vowel and its sound';
      case _Phase.balloon:    return 'Pop every vowel balloon!';
      case _Phase.findInWord: return 'Find the vowel hiding in the word';
      case _Phase.train:      return 'Drop letters into the train crates!';
    }
  }

  // ── teach ──
  void _nextVowel() {
    if (_teachIndex >= _vowels.length - 1) {
      setState(() {
        _phase = _Phase.balloon;
        _teachIndex = 0;
      });
    } else {
      setState(() => _teachIndex += 1);
    }
  }

  // ── balloon ──
  void _popBalloon(int index) {
    final letter = _balloonRounds[_balloonRound].letters[index];
    if (!isVowel(letter)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That is a consonant. Pop the vowels: A E I O U'),
          duration: Duration(milliseconds: 900),
        ),
      );
      return;
    }
    setState(() => _popped.add(index));
    final totalVowels = _balloonRounds[_balloonRound]
        .letters
        .where(isVowel)
        .length;
    if (_popped.length >= totalVowels) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        if (_balloonRound >= _balloonRounds.length - 1) {
          setState(() {
            _phase = _Phase.findInWord;
            _balloonRound = 0;
            _popped.clear();
          });
        } else {
          setState(() {
            _balloonRound += 1;
            _popped.clear();
          });
        }
      });
    }
  }

  // ── word find ──
  void _tapWordLetter(int index) {
    if (_wordCorrect) return;
    final word = _wordRounds[_wordRound].word;
    final letter = word[index];
    setState(() => _tappedIndex = index);
    if (isVowel(letter)) {
      setState(() => _wordCorrect = true);
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        if (_wordRound >= _wordRounds.length - 1) {
          setState(() => _phase = _Phase.train);
        } else {
          setState(() {
            _wordRound += 1;
            _tappedIndex = null;
            _wordCorrect = false;
          });
        }
      });
    } else {
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _tappedIndex = null);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not a vowel. Remember: A E I O U'),
          duration: Duration(milliseconds: 900),
        ),
      );
    }
  }

  Future<void> _finishZone() async {
    final unlocked = await ref
        .read(childPerformanceProvider.notifier)
        .completeVowelZone();
    if (!mounted) return;
    unawaited(_sendReport());
    if (unlocked) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ConsonantZoneScreen()),
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
      zoneName: 'Vowel Zone',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ZoneShell(
      title: 'Vowel Zone',
      subtitle: _subtitle,
      progress: _progress,
      checkpointCount: 4,
      currentCheckpoint: _checkpoint,
      onCheckpointTap: (_) {},
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        child: switch (_phase) {
          _Phase.teach      => _TeachPhase(
              key: ValueKey('teach-$_teachIndex'),
              info: _vowels[_teachIndex],
              isLast: _teachIndex >= _vowels.length - 1,
              onNext: _nextVowel,
            ),
          _Phase.balloon    => _BalloonPhase(
              key: ValueKey('balloon-$_balloonRound'),
              letters: _balloonRounds[_balloonRound].letters,
              popped: _popped,
              onPop: _popBalloon,
              round: _balloonRound + 1,
              total: _balloonRounds.length,
            ),
          _Phase.findInWord => _WordFindPhase(
              key: ValueKey('find-$_wordRound'),
              word: _wordRounds[_wordRound].word,
              tappedIndex: _tappedIndex,
              correct: _wordCorrect,
              round: _wordRound + 1,
              total: _wordRounds.length,
              done: false,
              onTap: _tapWordLetter,
              onHome: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          _Phase.train => TrainSortGame(
              key: const ValueKey('train'),
              items: _trainItems,
              mode: TrainCrateMode.vowelsOnly,
              targetCount: 5,
              onComplete: () => unawaited(_finishZone()),
            ),
        },
      ),
    );
  }
}

// ─── Phase 1: Teach ──────────────────────────────────────────────────────────

class _TeachPhase extends StatelessWidget {
  const _TeachPhase({
    super.key,
    required this.info,
    required this.isLast,
    required this.onNext,
  });

  final _VowelInfo info;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // big vowel card
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  info.color.withValues(alpha: 0.85),
                  info.color.withValues(alpha: 0.55),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 3),
              boxShadow: [
                BoxShadow(
                  color: info.color.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // glowing big letter
                Text(
                  info.letter,
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 12,
                      ),
                      Shadow(
                        color: info.color,
                        blurRadius: 40,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 300.ms),
                const SizedBox(height: 8),
                // sound label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    info.sound,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: 12),
                // example word pill
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(info.emoji, color: Colors.white, size: 32),
                    const SizedBox(width: 10),
                    Text(
                      info.word,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Color(0x66000000), blurRadius: 4)],
                      ),
                    ),
                  ],
                ).animate(delay: 350.ms).fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        KidGameButton(
          label: isLast ? 'Start Playing!' : 'Next Vowel',
          color: info.color,
          icon: isLast ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
          onPressed: onNext,
        ).animate(delay: 500.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Phase 2: Balloon Pop ────────────────────────────────────────────────────

class _BalloonPhase extends StatelessWidget {
  const _BalloonPhase({
    super.key,
    required this.letters,
    required this.popped,
    required this.onPop,
    required this.round,
    required this.total,
  });

  final List<String> letters;
  final Set<int> popped;
  final ValueChanged<int> onPop;
  final int round;
  final int total;

  @override
  Widget build(BuildContext context) {
    final vowelCount = letters.where(isVowel).length;
    final poppedVowels = popped.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Round $round / $total',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Popped: $poppedVowels / $vowelCount',
              style: const TextStyle(
                color: Color(0xFFFFF59D),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Pop all the vowel balloons!  A  E  I  O  U',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFF59D),
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: letters.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemBuilder: (_, i) {
              final isPopped = popped.contains(i);
              final letter = letters[i];
              final vowel = isVowel(letter);
              return _BalloonTile(
                key: ValueKey('b-$i-${letters[i]}'),
                letter: letter,
                isVowel: vowel,
                popped: isPopped,
                delay: i * 60,
                onTap: isPopped ? null : () => onPop(i),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BalloonTile extends StatefulWidget {
  const _BalloonTile({
    super.key,
    required this.letter,
    required this.isVowel,
    required this.popped,
    required this.delay,
    this.onTap,
  });

  final String letter;
  final bool isVowel;
  final bool popped;
  final int delay;
  final VoidCallback? onTap;

  @override
  State<_BalloonTile> createState() => _BalloonTileState();
}

class _BalloonTileState extends State<_BalloonTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(widget.letter.codeUnitAt(0) + widget.delay);
    _bob = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800 + rng.nextInt(700)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isVowel
        ? const Color(0xFFEF5350)
        : const Color(0xFF5A7DFF);

    return AnimatedBuilder(
      animation: _bob,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, widget.popped ? 0 : (_bob.value - 0.5) * 8),
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: widget.popped ? 0.01 : 1.0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInBack,
          child: AnimatedOpacity(
            opacity: widget.popped ? 0 : 1,
            duration: const Duration(milliseconds: 260),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.4),
                  radius: 0.85,
                  colors: [
                    color.withValues(alpha: 0.9),
                    color,
                    _darken(color, 0.2),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 2.5,
                ),
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
                  widget.letter.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [Shadow(color: Color(0x66000000), blurRadius: 3)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 280.ms)
        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut);
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

// ─── Phase 3: Find the vowel in a word ───────────────────────────────────────

class _WordFindPhase extends StatelessWidget {
  const _WordFindPhase({
    super.key,
    required this.word,
    required this.tappedIndex,
    required this.correct,
    required this.round,
    required this.total,
    required this.done,
    required this.onTap,
    required this.onHome,
  });

  final String word;
  final int? tappedIndex;
  final bool correct;
  final int round;
  final int total;
  final bool done;
  final ValueChanged<int> onTap;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Round $round / $total',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Tap the vowel in the word',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFF59D),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 28),
        // letter tiles for the word
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(word.length, (i) {
            final letter = word[i];
            final vowel = isVowel(letter);
            final tapped = tappedIndex == i;
            final revealed = correct && vowel;

            Color tileColor;
            if (revealed) {
              tileColor = const Color(0xFF43A047); // green — correct
            } else if (tapped && !correct) {
              tileColor = const Color(0xFFEF5350); // red — wrong
            } else {
              tileColor = const Color(0xFF5A7DFF); // default blue
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: correct ? null : () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutBack,
                  width: 64,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        tileColor.withValues(alpha: 0.9),
                        tileColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tileColor.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    letter.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [Shadow(color: Color(0x66000000), blurRadius: 4)],
                    ),
                  ),
                ),
              )
                  .animate(delay: (i * 80).ms)
                  .fadeIn(duration: 300.ms)
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),
            );
          }),
        ),
        const SizedBox(height: 28),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: correct
              ? Column(
                  key: const ValueKey('ok'),
                  children: [
                    const Text(
                      'Great job!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFF59D),
                        shadows: [Shadow(color: Color(0xAA000000), blurRadius: 6)],
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          curve: Curves.elasticOut,
                          duration: 400.ms,
                        )
                        .fadeIn(duration: 250.ms),
                    if (done) ...[
                      const SizedBox(height: 16),
                      KidGameButton(
                        label: 'Back to Home',
                        icon: Icons.home_rounded,
                        color: const Color(0xFF5A7DFF),
                        onPressed: onHome,
                      ),
                    ],
                  ],
                )
              : Text(
                  key: const ValueKey('hint'),
                  'Which letter is A, E, I, O or U?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }
}
