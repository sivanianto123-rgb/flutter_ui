import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/child_performance_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/services/progress_report_service.dart';
import '../../core/utils/syllable_utils.dart';
import '../sentence_zone/sentence_zone_screen.dart';
import '../shared/kid_game_button.dart';
import '../shared/zone_shell.dart';

/// Word Zone — reading theory: mark vowels, mark consonants, split & read.
class WordZoneScreen extends ConsumerStatefulWidget {
  const WordZoneScreen({super.key});

  @override
  ConsumerState<WordZoneScreen> createState() => _WordZoneScreenState();
}

class _TheoryWord {
  const _TheoryWord(this.word);
  final String word;
}

class _WordZoneScreenState extends ConsumerState<WordZoneScreen> {
  static const _words = <_TheoryWord>[
    _TheoryWord('cat'),
    _TheoryWord('bat'),
    _TheoryWord('map'),
    _TheoryWord('rabbit'),
    _TheoryWord('basket'),
  ];

  int _step = 0; // 0 vowels, 1 consonants, 2 split
  int _round = 0;
  int _correct = 0;
  int _attempts = 0;
  bool _done = false;

  _TheoryWord get _current => _words[_round];

  void _goStep(int step) {
    setState(() {
      _step = step.clamp(0, 2);
    });
  }

  void _onResult(bool ok) {
    _attempts += 1;
    if (ok) _correct += 1;
  }

  void _advanceAfterRound() {
    if (_done) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }
    if (_round >= _words.length - 1) {
      if (_step >= 2) {
        unawaited(_finishZone());
      } else {
        _goStep(_step + 1);
        setState(() => _round = 0);
      }
      return;
    }
    setState(() => _round += 1);
  }

  Future<void> _finishZone() async {
    final total = math.max(_attempts, 1);
    final unlocked = await ref
        .read(childPerformanceProvider.notifier)
        .recordWordZoneResult(
          correctAnswers: _correct,
          totalQuestions: total,
        );
    if (!mounted) return;
    setState(() => _done = true);
    unawaited(_sendReport());
    if (unlocked) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SentenceZoneScreen()),
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
      zoneName: 'Word Zone',
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + (_round + 1) / _words.length) / 3;
    final subtitles = [
      'Tap every vowel in the word',
      'Tap every consonant in the word',
      'Split and read each chunk — meaning not needed!',
    ];
    return ZoneShell(
      title: 'Word Zone',
      subtitle: subtitles[_step],
      progress: progress,
      checkpointCount: 3,
      currentCheckpoint: _step,
      onCheckpointTap: (i) {
        if (i <= _step) _goStep(i);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        child: switch (_step) {
          0 => _MarkVowelsStep(
              key: ValueKey('vowels-$_round'),
              word: _current.word,
              roundLabel: '${_round + 1} / ${_words.length}',
              onResult: _onResult,
              onNext: _advanceAfterRound,
            ),
          1 => _MarkConsonantsStep(
              key: ValueKey('cons-$_round'),
              word: _current.word,
              roundLabel: '${_round + 1} / ${_words.length}',
              onResult: _onResult,
              onNext: _advanceAfterRound,
            ),
          _ => _SplitAndReadStep(
              key: ValueKey('split-$_round'),
              word: _current.word,
              roundLabel: '${_round + 1} / ${_words.length}',
              onResult: _onResult,
              onNext: _advanceAfterRound,
              isLast: _round >= _words.length - 1,
              done: _done,
            ),
        },
      ),
    );
  }
}

// ─── Step 1: Mark vowels ────────────────────────────────────────────────────

class _MarkVowelsStep extends StatefulWidget {
  const _MarkVowelsStep({
    super.key,
    required this.word,
    required this.roundLabel,
    required this.onResult,
    required this.onNext,
  });

  final String word;
  final String roundLabel;
  final ValueChanged<bool> onResult;
  final VoidCallback onNext;

  @override
  State<_MarkVowelsStep> createState() => _MarkVowelsStepState();
}

class _MarkVowelsStepState extends State<_MarkVowelsStep> {
  final Set<int> _marked = {};
  bool _reported = false;
  bool _complete = false;

  void _tap(int index) {
    if (_complete) return;
    final letter = widget.word[index];
    if (!isVowel(letter)) {
      _flashWrong();
      return;
    }
    setState(() => _marked.add(index));
    final needed = vowelIndices(widget.word).toSet();
    if (_marked.containsAll(needed)) {
      setState(() => _complete = true);
      if (!_reported) {
        _reported = true;
        widget.onResult(true);
      }
    }
  }

  void _flashWrong() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('That is not a vowel. Try A, E, I, O, or U.'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mark the Vowels  ·  ${widget.roundLabel}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        _WordLetterRow(
          word: widget.word,
          marked: _marked,
          markColor: const Color(0xFFFF8A65),
          onTap: _tap,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Vowels are  A  E  I  O  U',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFF59D),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _complete
              ? KidGameButton(
                  key: const ValueKey('next'),
                  label: 'Next',
                  onPressed: widget.onNext,
                  color: const Color(0xFFFF6F61),
                  icon: Icons.arrow_forward_rounded,
                )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2, end: 0)
              : Container(
                  key: const ValueKey('hint'),
                  height: 62,
                  alignment: Alignment.center,
                  child: Text(
                    'Tap every vowel to continue',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Step 2: Mark consonants ──────────────────────────────────────────────────

class _MarkConsonantsStep extends StatefulWidget {
  const _MarkConsonantsStep({
    super.key,
    required this.word,
    required this.roundLabel,
    required this.onResult,
    required this.onNext,
  });

  final String word;
  final String roundLabel;
  final ValueChanged<bool> onResult;
  final VoidCallback onNext;

  @override
  State<_MarkConsonantsStep> createState() => _MarkConsonantsStepState();
}

class _MarkConsonantsStepState extends State<_MarkConsonantsStep> {
  final Set<int> _marked = {};
  bool _reported = false;
  bool _complete = false;

  void _tap(int index) {
    if (_complete) return;
    final letter = widget.word[index];
    if (!isConsonant(letter)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That is a vowel. Tap consonants only.'),
          duration: Duration(milliseconds: 900),
        ),
      );
      return;
    }
    setState(() => _marked.add(index));
    final needed = consonantIndices(widget.word).toSet();
    if (_marked.containsAll(needed)) {
      setState(() => _complete = true);
      if (!_reported) {
        _reported = true;
        widget.onResult(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mark the Consonants  ·  ${widget.roundLabel}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        _WordLetterRow(
          word: widget.word,
          marked: _marked,
          markColor: const Color(0xFF5A7DFF),
          onTap: _tap,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Consonants are all letters except A E I O U',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFF59D),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _complete
              ? KidGameButton(
                  key: const ValueKey('next'),
                  label: 'Next',
                  onPressed: widget.onNext,
                  color: const Color(0xFFFF6F61),
                  icon: Icons.arrow_forward_rounded,
                ).animate().fadeIn(duration: 300.ms)
              : Container(
                  key: const ValueKey('hint'),
                  height: 62,
                  alignment: Alignment.center,
                  child: Text(
                    'Tap every consonant to continue',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Step 3: Split & read ───────────────────────────────────────────────────

class _SplitAndReadStep extends StatefulWidget {
  const _SplitAndReadStep({
    super.key,
    required this.word,
    required this.roundLabel,
    required this.onResult,
    required this.onNext,
    required this.isLast,
    required this.done,
  });

  final String word;
  final String roundLabel;
  final ValueChanged<bool> onResult;
  final VoidCallback onNext;
  final bool isLast;
  final bool done;

  @override
  State<_SplitAndReadStep> createState() => _SplitAndReadStepState();
}

class _SplitAndReadStepState extends State<_SplitAndReadStep> {
  late final List<String> _chunks;
  int _readIndex = 0;
  bool _splitShown = false;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    _chunks = splitSyllables(widget.word);
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _splitShown = true);
    });
  }

  void _tapChunk(int index) {
    if (index != _readIndex) return;
    setState(() => _readIndex += 1);
    if (_readIndex >= _chunks.length && !_reported) {
      _reported = true;
      widget.onResult(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRead = _readIndex >= _chunks.length;
    return Column(
      children: [
        Text(
          'Split and Read  ·  ${widget.roundLabel}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          widget.word.toUpperCase(),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Two consonants together? Split between them!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        AnimatedOpacity(
          opacity: _splitShown ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_chunks.length, (i) {
              final read = i < _readIndex;
              final active = i == _readIndex;
              return GestureDetector(
                onTap: () => _tapChunk(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: read
                          ? [const Color(0xFF66BB6A), const Color(0xFF43A047)]
                          : active
                              ? [const Color(0xFFFFD54F), const Color(0xFFFFB300)]
                              : [const Color(0xFF5A7DFF), const Color(0xFF3949AB)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.75),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _chunks[i].toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: read ? Colors.white : const Color(0xFF4E342E),
                    ),
                  ),
                ),
              )
                  .animate(delay: (i * 120).ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.25, end: 0);
            }),
          ),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: allRead
              ? Column(
                  key: const ValueKey('done'),
                  children: [
                    const Text(
                      'You read the whole word!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFFF59D),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Color(0xAA000000), blurRadius: 6)],
                      ),
                    ).animate().fadeIn(duration: 300.ms).scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          curve: Curves.elasticOut,
                        ),
                    const SizedBox(height: 16),
                    KidGameButton(
                      label: widget.done
                          ? 'Back to Home'
                          : (widget.isLast ? 'Finish' : 'Next'),
                      onPressed: widget.onNext,
                      color: const Color(0xFFFF6F61),
                      icon: widget.done ? Icons.home_rounded : Icons.check_rounded,
                    ),
                  ],
                )
              : Padding(
                  key: const ValueKey('prompt'),
                  padding: EdgeInsets.zero,
                  child: Text(
                    'Tap chunk ${_readIndex + 1} to read it',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Shared letter row ──────────────────────────────────────────────────────

class _WordLetterRow extends StatelessWidget {
  const _WordLetterRow({
    required this.word,
    required this.marked,
    required this.markColor,
    required this.onTap,
  });

  final String word;
  final Set<int> marked;
  final Color markColor;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 8,
      children: List.generate(word.length, (i) {
        final isMarked = marked.contains(i);
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            width: 48,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isMarked
                    ? [markColor, markColor.withValues(alpha: 0.75)]
                    : [
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white.withValues(alpha: 0.75),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isMarked ? Colors.white : Colors.white.withValues(alpha: 0.5),
                width: 2.5,
              ),
              boxShadow: isMarked
                  ? [
                      BoxShadow(
                        color: markColor.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              word[i].toUpperCase(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isMarked ? Colors.white : const Color(0xFF4E342E),
              ),
            ),
          ),
        )
            .animate(delay: (i * 50).ms)
            .fadeIn(duration: 280.ms)
            .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1));
      }),
    );
  }
}
