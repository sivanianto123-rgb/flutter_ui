import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/child_performance_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/services/progress_report_service.dart';
import '../phonics/phonics_forest_background.dart';
import '../shared/cartoon_progress_bar.dart';
import '../shared/kid_game_button.dart';
import '../shared/kid_word_art.dart';

/// Sentence Zone — three toddler-friendly activities:
/// 1) Word Parade (watch words appear)
/// 2) Line Them Up (tap words in order)
/// 3) Missing Word (fill the blank with a picture clue)
class SentenceZoneScreen extends ConsumerStatefulWidget {
  const SentenceZoneScreen({super.key});

  @override
  ConsumerState<SentenceZoneScreen> createState() => _SentenceZoneScreenState();
}

class _SentenceItem {
  const _SentenceItem({
    required this.words,
    required this.picture,
    required this.blankIndex,
    required this.options,
  });

  final List<String> words;
  final KidPicture picture;
  final int blankIndex;
  final List<String> options;

  String get full => words.join(' ');
  String get answer => words[blankIndex];
}

class _SentenceZoneScreenState extends ConsumerState<SentenceZoneScreen> {
  static const _items = <_SentenceItem>[
    _SentenceItem(
      words: ['I', 'see', 'a', 'cat'],
      picture: KidPicture.cat,
      blankIndex: 3,
      options: ['cat', 'bat', 'bag'],
    ),
    _SentenceItem(
      words: ['A', 'man', 'has', 'a', 'bag'],
      picture: KidPicture.bag,
      blankIndex: 4,
      options: ['bag', 'map', 'mat'],
    ),
    _SentenceItem(
      words: ['The', 'cat', 'sits', 'on', 'a', 'mat'],
      picture: KidPicture.mat,
      blankIndex: 5,
      options: ['mat', 'map', 'man'],
    ),
    _SentenceItem(
      words: ['We', 'look', 'at', 'a', 'map'],
      picture: KidPicture.map,
      blankIndex: 4,
      options: ['map', 'bat', 'ball'],
    ),
  ];

  int _step = 0;
  int _round = 0;
  int _correct = 0;
  int _attempts = 0;
  bool _done = false;

  void _goStep(int step) {
    setState(() {
      _step = step.clamp(0, 2);
      _round = 0;
    });
  }

  Future<void> _finishZone() async {
    final total = math.max(_attempts, 1);
    await ref.read(childPerformanceProvider.notifier).recordSentenceZoneResult(
          correctAnswers: _correct,
          totalQuestions: total,
        );
    if (!mounted) return;
    setState(() => _done = true);
    unawaited(_sendZoneReport());
  }

  Future<void> _sendZoneReport() async {
    final profile = ref.read(profileProvider).valueOrNull;
    final performance = ref.read(childPerformanceProvider).valueOrNull;
    if (profile == null || performance == null) return;
    await ProgressReportService.sendAutomaticReport(
      profile: profile,
      performance: performance,
      zoneName: 'Sentence Zone',
    );
  }

  void _onRoundResult({required bool correct}) {
    _attempts += 1;
    if (correct) _correct += 1;
  }

  void _advanceAfterRound() {
    if (_done) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }
    if (_round >= _items.length - 1) {
      if (_step >= 2) {
        unawaited(_finishZone());
      } else {
        _goStep(_step + 1);
      }
      return;
    }
    setState(() => _round += 1);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + (_round + 1) / _items.length) / 3;
    return Scaffold(
      body: Stack(
        children: [
          const PhonicsForestBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CartoonProgressBar(
                          value: progress.clamp(0.0, 1.0),
                          height: 28,
                          checkpointCount: 3,
                          currentCheckpoint: _step,
                          onCheckpointTap: (i) {
                            if (i <= _step) _goStep(i);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                        icon: const Icon(Icons.home_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.30),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.12, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: switch (_step) {
                        0 => _WordParadeStep(
                          key: ValueKey('parade-$_round'),
                          item: _items[_round],
                          roundLabel: '${_round + 1} / ${_items.length}',
                          onNext: _advanceAfterRound,
                        ),
                        1 => _LineThemUpStep(
                          key: ValueKey('order-$_round'),
                          item: _items[_round],
                          roundLabel: '${_round + 1} / ${_items.length}',
                          onResult: (ok) => _onRoundResult(correct: ok),
                          onNext: _advanceAfterRound,
                        ),
                        _ => _MissingWordStep(
                          key: ValueKey('blank-$_round'),
                          item: _items[_round],
                          roundLabel: '${_round + 1} / ${_items.length}',
                          onResult: (ok) => _onRoundResult(correct: ok),
                          onNext: _advanceAfterRound,
                          isLast: _round >= _items.length - 1 && _step >= 2,
                          done: _done,
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity 1: Word Parade ────────────────────────────────────────────────

class _WordParadeStep extends StatefulWidget {
  const _WordParadeStep({
    super.key,
    required this.item,
    required this.roundLabel,
    required this.onNext,
  });

  final _SentenceItem item;
  final String roundLabel;
  final VoidCallback onNext;

  @override
  State<_WordParadeStep> createState() => _WordParadeStepState();
}

class _WordParadeStepState extends State<_WordParadeStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _visibleCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _startParade();
  }

  void _startParade() {
    _timer?.cancel();
    _visibleCount = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 550), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_visibleCount >= widget.item.words.length) {
        t.cancel();
        return;
      }
      setState(() => _visibleCount += 1);
    });
  }

  @override
  void didUpdateWidget(covariant _WordParadeStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.full != widget.item.full) {
      _startParade();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allShown = _visibleCount >= widget.item.words.length;
    return Column(
      children: [
        const Text(
          'Word Parade',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
          ),
        ),
        Text(
          'Watch the words march in  ·  ${widget.roundLabel}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return KidWordArt(
              picture: widget.item.picture,
              size: 120,
              bob: _ctrl.value,
            );
          },
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(
              begin: const Offset(0.75, 0.75),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 650.ms,
            ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: List.generate(widget.item.words.length, (i) {
            final shown = i < _visibleCount;
            return AnimatedOpacity(
              opacity: shown ? 1 : 0,
              duration: const Duration(milliseconds: 280),
              child: shown
                  ? _WordChip(
                      text: widget.item.words[i],
                      highlight: i == widget.item.blankIndex,
                    )
                      .animate()
                      .fadeIn(duration: 280.ms)
                      .slideX(
                        begin: 0.35,
                        end: 0,
                        curve: Curves.easeOutBack,
                        duration: 400.ms,
                      )
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1, 1),
                      )
                  : const SizedBox(width: 48, height: 44),
            );
          }),
        ),
        const Spacer(),
        if (allShown)
          KidGameButton(
            label: 'Next',
            onPressed: widget.onNext,
            color: const Color(0xFFFF6F61),
            icon: Icons.arrow_forward_rounded,
          ).animate().fadeIn(duration: 350.ms)
        else
          Text(
            'Listening...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

// ─── Activity 2: Line Them Up ───────────────────────────────────────────────

class _LineThemUpStep extends StatefulWidget {
  const _LineThemUpStep({
    super.key,
    required this.item,
    required this.roundLabel,
    required this.onResult,
    required this.onNext,
  });

  final _SentenceItem item;
  final String roundLabel;
  final ValueChanged<bool> onResult;
  final VoidCallback onNext;

  @override
  State<_LineThemUpStep> createState() => _LineThemUpStepState();
}

class _LineThemUpStepState extends State<_LineThemUpStep>
    with SingleTickerProviderStateMixin {
  late List<String> _slots;
  late List<_PoolWord> _pool;
  int _nextIndex = 0;
  bool _complete = false;
  bool _reported = false;
  String? _shakeId;
  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _resetBoard();
  }

  @override
  void didUpdateWidget(covariant _LineThemUpStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.full != widget.item.full) {
      _resetBoard();
    }
  }

  void _resetBoard() {
    final words = widget.item.words;
    _slots = List.filled(words.length, '');
    final shuffled = List<String>.from(words)..shuffle(math.Random());
    if (shuffled.join(' ') == words.join(' ') && words.length > 1) {
      shuffled.insert(0, shuffled.removeLast());
    }
    _pool = [
      for (var i = 0; i < shuffled.length; i++)
        _PoolWord(id: '$i-${shuffled[i]}', word: shuffled[i], used: false),
    ];
    _nextIndex = 0;
    _complete = false;
    _reported = false;
    _shakeId = null;
  }

  Future<void> _tap(_PoolWord tile) async {
    if (_complete || tile.used) return;
    final expected = widget.item.words[_nextIndex];
    if (tile.word != expected) {
      setState(() => _shakeId = tile.id);
      await _shakeCtrl.forward(from: 0);
      if (mounted) setState(() => _shakeId = null);
      return;
    }
    setState(() {
      tile.used = true;
      _slots[_nextIndex] = tile.word;
      _nextIndex += 1;
      if (_nextIndex >= _slots.length) _complete = true;
    });
    if (_complete && !_reported) {
      _reported = true;
      widget.onResult(true);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Line Them Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
          ),
        ),
        Text(
          'Tap the words in order  ·  ${widget.roundLabel}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        KidWordArt(picture: widget.item.picture, size: 90)
            .animate()
            .fadeIn(duration: 350.ms)
            .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1)),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_slots.length, (i) {
            final filled = _slots[i].isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: filled
                    ? const Color(0xFFFFD54F)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.65),
                  width: 2,
                ),
              ),
              child: Text(
                filled
                    ? _slots[i]
                    : (i == _nextIndex && !_complete ? '...' : '   '),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: filled
                      ? const Color(0xFF4E342E)
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: _pool.map((tile) {
            if (tile.used) {
              return Opacity(
                opacity: 0.25,
                child: _WordChip(text: tile.word, muted: true),
              );
            }
            final shaking = _shakeId == tile.id;
            return AnimatedBuilder(
              animation: _shakeCtrl,
              builder: (_, child) {
                final dx =
                    shaking ? math.sin(_shakeCtrl.value * math.pi * 6) * 8 : 0.0;
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: GestureDetector(
                onTap: () => _tap(tile),
                child: _WordChip(text: tile.word, color: const Color(0xFF5A7DFF)),
              ),
            );
          }).toList(),
        ),
        const Spacer(),
        if (_complete)
          Column(
            children: [
              const Text(
                'Nice sentence!',
                style: TextStyle(
                  color: Color(0xFFFFF59D),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 12),
              KidGameButton(
                label: 'Next',
                onPressed: widget.onNext,
                color: const Color(0xFFFF6F61),
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          )
        else
          const SizedBox(height: 56),
      ],
    );
  }
}

class _PoolWord {
  _PoolWord({required this.id, required this.word, required this.used});
  final String id;
  final String word;
  bool used;
}

// ─── Activity 3: Missing Word ───────────────────────────────────────────────

class _MissingWordStep extends StatefulWidget {
  const _MissingWordStep({
    super.key,
    required this.item,
    required this.roundLabel,
    required this.onResult,
    required this.onNext,
    required this.isLast,
    required this.done,
  });

  final _SentenceItem item;
  final String roundLabel;
  final ValueChanged<bool> onResult;
  final VoidCallback onNext;
  final bool isLast;
  final bool done;

  @override
  State<_MissingWordStep> createState() => _MissingWordStepState();
}

class _MissingWordStepState extends State<_MissingWordStep>
    with SingleTickerProviderStateMixin {
  String? _picked;
  bool _reported = false;
  late List<String> _options;
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _options = List<String>.from(widget.item.options)..shuffle(math.Random());
  }

  @override
  void didUpdateWidget(covariant _MissingWordStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.full != widget.item.full) {
      _picked = null;
      _reported = false;
      _options = List<String>.from(widget.item.options)..shuffle(math.Random());
    }
  }

  void _pick(String word) {
    if (_picked != null) return;
    final ok = word == widget.item.answer;
    setState(() => _picked = word);
    if (!_reported) {
      _reported = true;
      widget.onResult(ok);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final correct = _picked == widget.item.answer;
    final showAnswer = _picked != null;
    return Column(
      children: [
        const Text(
          'Missing Word',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
          ),
        ),
        Text(
          'Look at the picture. Tap the missing word  ·  ${widget.roundLabel}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        AnimatedBuilder(
          animation: _bob,
          builder: (_, __) {
            return KidWordArt(
              picture: widget.item.picture,
              size: 110,
              bob: _bob.value,
            );
          },
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(widget.item.words.length, (i) {
            final isBlank = i == widget.item.blankIndex;
            if (isBlank) {
              final filled = showAnswer;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: filled
                      ? (correct
                          ? const Color(0xFF66BB6A)
                          : const Color(0xFFFFD54F))
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.75),
                    width: 2.5,
                  ),
                ),
                child: Text(
                  filled ? widget.item.answer : '____',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: filled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              );
            }
            return _WordChip(text: widget.item.words[i]);
          }),
        ),
        const SizedBox(height: 28),
        if (_picked == null)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(_options.length, (i) {
              final word = _options[i];
              final pic = pictureForWord(word);
              return GestureDetector(
                onTap: () => _pick(word),
                child: AnimatedBuilder(
                  animation: _bob,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        math.sin((_bob.value + i * 0.3) * math.pi * 2) * 5,
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF5A7DFF),
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (pic != null) KidWordArt(picture: pic, size: 56),
                        const SizedBox(height: 6),
                        Text(
                          word.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF37474F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate(delay: (i * 100).ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.2, end: 0);
            }),
          )
        else ...[
          Text(
            correct ? 'Yes! Great reading!' : 'Good try. The word is ${widget.item.answer}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              shadows: [Shadow(color: Color(0xAA000000), blurRadius: 6)],
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          KidGameButton(
            label: widget.done
                ? 'Back to Home'
                : (widget.isLast ? 'Finish' : 'Next'),
            onPressed: widget.done
                ? () => Navigator.of(context).popUntil((r) => r.isFirst)
                : widget.onNext,
            color: const Color(0xFFFF6F61),
            icon: widget.done ? Icons.home_rounded : Icons.check_rounded,
          ),
        ],
        const Spacer(),
      ],
    );
  }
}

// ─── Shared chips ───────────────────────────────────────────────────────────

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.text,
    this.highlight = false,
    this.muted = false,
    this.color,
  });

  final String text;
  final bool highlight;
  final bool muted;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bg = color ??
        (highlight ? const Color(0xFFFF8A65) : const Color(0xFF26A69A));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: muted ? bg.withValues(alpha: 0.45) : bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 2,
        ),
        boxShadow: muted
            ? null
            : const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

