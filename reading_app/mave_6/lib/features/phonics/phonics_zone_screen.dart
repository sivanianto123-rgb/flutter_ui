import 'dart:async';
import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/child_performance_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/services/ai_story_service.dart';
import '../../core/services/phonics_tts_service.dart';
import '../../core/services/progress_report_service.dart';
import '../shared/cartoon_progress_bar.dart';
import '../vowel_zone/vowel_zone_screen.dart';
import 'phonics_bubble_pop_game.dart';
import 'phonics_forest_background.dart';
import 'phonics_story_book_game.dart';

class PhonicsZoneScreen extends ConsumerStatefulWidget {
  const PhonicsZoneScreen({super.key, required this.sound});

  final String sound;

  @override
  ConsumerState<PhonicsZoneScreen> createState() => _PhonicsZoneScreenState();
}

class _PhonicsZoneScreenState extends ConsumerState<PhonicsZoneScreen> {
  int _step = 0; // 0 reading, 1 bubble, 2 story
  bool _readingTracked = false;
  bool _bubbleTracked = false;
  bool _storyTracked = false;
  int _bubbleCorrectPops = 0;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(phonicsTtsServiceProvider).playReadingIntro(widget.sound);
    });
  }

  void _goStep(int step) {
    if (!mounted) return;
    setState(() => _step = step.clamp(0, 2));
  }

  Future<void> _sendZoneReport(String zoneName) async {
    final profile = ref.read(profileProvider).valueOrNull;
    final performance = ref.read(childPerformanceProvider).valueOrNull;
    if (profile == null || performance == null) return;
    await ProgressReportService.sendAutomaticReport(
      profile: profile,
      performance: performance,
      zoneName: zoneName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / 3;
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
                          value: progress,
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
                        icon: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                        ),
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
                        return SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0.15, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: switch (_step) {
                        0 => _ReadingStep(
                          key: const ValueKey('reading-step'),
                          sound: widget.sound,
                          onRepeatTap: () => ref
                              .read(phonicsTtsServiceProvider)
                              .playReadingIntro(widget.sound),
                          onNext: () {
                            if (!_readingTracked) {
                              _readingTracked = true;
                              ref
                                  .read(childPerformanceProvider.notifier)
                                  .markReadingCompleted();
                            }
                            _goStep(1);
                          },
                        ),
                        1 => _BubbleStep(
                          key: const ValueKey('bubble-step'),
                          targetSound: widget.sound.toLowerCase(),
                          onNext: () => _goStep(2),
                          onStepStart: () => ref
                              .read(phonicsTtsServiceProvider)
                              .playBubbleIntro(widget.sound),
                          onPrompt: () => ref
                              .read(phonicsTtsServiceProvider)
                              .playBubblePrompt(widget.sound),
                          onCorrectPopAudio: () => ref
                              .read(phonicsTtsServiceProvider)
                              .playPositiveFeedback(),
                          onWrongPopAudio: () => ref
                              .read(phonicsTtsServiceProvider)
                              .playTryAgainFeedback(),
                          onActivityCompleted: (correctPops) {
                            if (_bubbleTracked) return;
                            _bubbleTracked = true;
                            _bubbleCorrectPops = correctPops;
                            ref
                                .read(childPerformanceProvider.notifier)
                                .recordBubbleResult(
                                  correctPops: correctPops,
                                  totalTargetPops: 4,
                                );
                          },
                        ),
                        _ => _StoryStep(
                          key: const ValueKey('story-step'),
                          sound: widget.sound.toLowerCase(),
                          onStepStart: () => ref
                              .read(phonicsTtsServiceProvider)
                              .playStoryIntro(widget.sound),
                          onNarrateLine: (line) => ref
                              .read(phonicsTtsServiceProvider)
                              .playStoryLine(line),
                          onActivityCompleted: () {
                            if (_storyTracked) return;
                            _storyTracked = true;
                            ref.read(childPerformanceProvider.notifier).markStoryCompleted();
                            Future<void>.microtask(() async {
                              final unlocked = await ref
                                  .read(childPerformanceProvider.notifier)
                                  .completePhonicsZone(
                                    bubbleCorrectPops: _bubbleCorrectPops,
                                    totalBubbleTargets: 4,
                                  );
                              unawaited(_sendZoneReport('Phonic Zone'));
                              if (!context.mounted || !unlocked) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const VowelZoneScreen(),
                                ),
                              );
                            });
                          },
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

class _ReadingStep extends StatefulWidget {
  const _ReadingStep({
    super.key,
    required this.sound,
    required this.onNext,
    required this.onRepeatTap,
  });

  final String sound;
  final VoidCallback onNext;
  final VoidCallback onRepeatTap;

  @override
  State<_ReadingStep> createState() => _ReadingStepState();
}

class _ReadingStepState extends State<_ReadingStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sound = widget.sound.toLowerCase();
    final first = sound.isNotEmpty ? sound[0] : 'm';
    final second = sound.length > 1 ? sound[1] : 'a';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onRepeatTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  return Stack(
                    children: [
                      _Butterfly(
                        animation: _controller,
                        startX: w * 0.08,
                        startY: 24,
                        size: 24,
                      ),
                      _Butterfly(
                        animation: _controller,
                        startX: w * 0.30,
                        startY: 66,
                        size: 22,
                      ),
                      _Butterfly(
                        animation: _controller,
                        startX: w * 0.54,
                        startY: 18,
                        size: 26,
                      ),
                      _Butterfly(
                        animation: _controller,
                        startX: w * 0.80,
                        startY: 52,
                        size: 24,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 6),
              const Text(
                'Sound Time',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                ),
              ),
              const SizedBox(height: 16),
              _WordCard(first: first, second: second, animation: _controller),
              const SizedBox(height: 12),
              const Text(
                '→',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 170,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    return Stack(
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) {
                            final dx = -34 + (_controller.value * (w + 68));
                            final hop =
                                math.sin(_controller.value * math.pi * 8) * 11;
                            final legPhase = math.sin(
                              _controller.value * math.pi * 8,
                            );
                            return Positioned(
                              left: dx,
                              bottom: 30 + hop.abs(),
                              child: _RabbitHopper(legPhase: legPhase),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6F61),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Butterfly extends StatelessWidget {
  const _Butterfly({
    required this.animation,
    required this.startX,
    required this.startY,
    required this.size,
  });

  final Animation<double> animation;
  final double startX;
  final double startY;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final dx = math.sin((animation.value * math.pi * 2) + startX / 40) * 16;
        final dy = math.cos((animation.value * math.pi * 2) + startY / 30) * 10;
        return Positioned(
          left: startX + dx,
          top: startY + dy,
          child: Text('🦋', style: TextStyle(fontSize: size)),
        );
      },
    );
  }
}

class _RabbitHopper extends StatelessWidget {
  const _RabbitHopper({required this.legPhase});

  final double legPhase;

  @override
  Widget build(BuildContext context) {
    final pawOffset = legPhase > 0 ? 4.0 : -4.0;
    return SizedBox(
      width: 72,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 2,
            bottom: 6,
            child: Transform.translate(
              offset: Offset(pawOffset, 0),
              child: Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFF1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 10,
            child: Container(
              width: 38,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 44,
            bottom: 22,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: 38,
            child: Container(
              width: 6,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Positioned(
            left: 58,
            bottom: 36,
            child: Container(
              width: 6,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const Positioned(
            left: 57,
            bottom: 30,
            child: CircleAvatar(radius: 2.2, backgroundColor: Colors.black87),
          ),
          Positioned(
            left: 14,
            bottom: 24,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFF8BBD0),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({
    required this.first,
    required this.second,
    required this.animation,
  });

  final String first;
  final String second;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          final t = animation.value;
          final phase = t % 1.0;
          final firstBreathe = phase < 0.5
              ? math.sin(math.pi * (phase / 0.5))
              : 0.0;
          final secondBreathe = phase >= 0.5
              ? math.sin(math.pi * ((phase - 0.5) / 0.5))
              : 0.0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.scale(
                scale: 1 + (firstBreathe * 0.13),
                child: Text(
                  first.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 82,
                    color: Color(0xFFFFF59D),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Transform.scale(
                scale: 1 + (secondBreathe * 0.13),
                child: Text(
                  second.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 82,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BubbleStep extends StatefulWidget {
  const _BubbleStep({
    super.key,
    required this.targetSound,
    required this.onNext,
    required this.onActivityCompleted,
    required this.onStepStart,
    required this.onPrompt,
    required this.onCorrectPopAudio,
    required this.onWrongPopAudio,
  });

  final String targetSound;
  final VoidCallback onNext;
  final ValueChanged<int> onActivityCompleted;
  final VoidCallback onStepStart;
  final VoidCallback onPrompt;
  final VoidCallback onCorrectPopAudio;
  final VoidCallback onWrongPopAudio;

  @override
  State<_BubbleStep> createState() => _BubbleStepState();
}

class _BubbleStepState extends State<_BubbleStep>
    with SingleTickerProviderStateMixin {
  late final PhonicsBubblePopGame _game;
  late final AnimationController _ticker;
  int _popped = 0;
  bool _done = false;
  bool _reported = false;
  Timer? _promptTimer;
  DateTime _lastFeedbackAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _game = PhonicsBubblePopGame(
      targetSound: widget.targetSound,
      onCorrectTap: _onCorrectTapAudio,
      onWrongTap: _onWrongTapAudio,
      onProgress: (v) {
        if (!mounted) return;
        setState(() => _popped = v);
      },
      onCompleted: () {
        if (!mounted) return;
        setState(() => _done = true);
        if (!_reported) {
          _reported = true;
          widget.onActivityCompleted(_popped);
        }
      },
    );
    widget.onStepStart();
    _promptTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || _done) return;
      widget.onPrompt();
    });
  }

  void _onCorrectTapAudio() {
    final now = DateTime.now();
    if (now.difference(_lastFeedbackAt).inMilliseconds < 900) return;
    _lastFeedbackAt = now;
    widget.onCorrectPopAudio();
  }

  void _onWrongTapAudio() {
    final now = DateTime.now();
    if (now.difference(_lastFeedbackAt).inMilliseconds < 900) return;
    _lastFeedbackAt = now;
    widget.onWrongPopAudio();
  }

  @override
  void dispose() {
    _promptTimer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 8),
            Text(
              'Pop only "${widget.targetSound.toUpperCase()}" bubbles!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Correct pops: $_popped / 4',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GameWidget(game: _game),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F61),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
        if (_done)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ticker,
                builder: (context, _) {
                  final fade =
                      0.28 + (math.sin(_ticker.value * math.pi * 2) * 0.04);
                  return ColoredBox(
                    color: Colors.black.withValues(
                      alpha: fade.clamp(0.24, 0.34),
                    ),
                  );
                },
              ),
            ),
          ),
        if (_done)
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Text(
                  'Great Job!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    fontFamilyFallback: [
                      'Comic Sans MS',
                      'Marker Felt',
                      'Chalkboard SE',
                    ],
                    shadows: [Shadow(color: Color(0xCC000000), blurRadius: 14)],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StoryStep extends StatefulWidget {
  const _StoryStep({
    super.key,
    required this.sound,
    required this.onActivityCompleted,
    required this.onStepStart,
    required this.onNarrateLine,
  });
  final String sound;
  final VoidCallback onActivityCompleted;
  final VoidCallback onStepStart;
  final Future<double> Function(String line) onNarrateLine;

  @override
  State<_StoryStep> createState() => _StoryStepState();
}

class _StoryStepState extends State<_StoryStep> {
  final _service = AiStoryService();
  final _bookGame = PhonicsStoryBookGame();
  late final Future<GeneratedStory> _future;
  Timer? _timer;
  int _index = 0;
  int _session = 0;
  List<String> _pages = const [];
  bool _reported = false;
  double _lastNarrationSeconds = 7.0;

  @override
  void initState() {
    super.initState();
    _future = _service.generateForSound(widget.sound);
    widget.onStepStart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _showPage() async {
    if (_pages.isEmpty) return;
    final line = _pages[_index.clamp(0, _pages.length - 1)];
    _bookGame.setPageBody(line);
    final spoken = await widget.onNarrateLine(line);
    if (spoken > 0) {
      _lastNarrationSeconds = spoken;
    }
    if (!_reported && _index >= _pages.length - 1) {
      _reported = true;
      widget.onActivityCompleted();
    }
  }

  void _schedule() {
    _timer?.cancel();
    if (_index >= _pages.length - 1) return;
    final words = _pages[_index]
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .length;
    final textBased = (4 + words * 0.32).clamp(6, 14).toDouble();
    final seconds = math.max(_lastNarrationSeconds + 0.8, textBased);
    final currentSession = _session;
    _timer = Timer(Duration(milliseconds: (seconds * 1000).round()), () async {
      if (!mounted || currentSession != _session) return;
      if (_index < _pages.length - 1) {
        _index += 1;
        await _showPage();
      }
      _schedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GeneratedStory>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD54F)),
          );
        }
        final story = snapshot.data!;
        if (_pages.isEmpty) {
          _pages = [...story.paragraphs];
          _session = DateTime.now().microsecondsSinceEpoch;
          _index = 0;
          unawaited(_showPage());
          _schedule();
        }
        return Column(
          children: [
            const SizedBox(height: 6),
            const Text(
              'Story Time',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: GameWidget(game: _bookGame)),
          ],
        );
      },
    );
  }
}
