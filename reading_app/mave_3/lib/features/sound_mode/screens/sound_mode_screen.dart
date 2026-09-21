import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/app_providers.dart';
import '../../../core/services/report_service.dart';
import '../providers/sound_mode_provider.dart';
import '../../game_modules/echo_animal/echo_animal_screen.dart';
import '../../game_modules/feed_the_monster/feed_the_monster_screen.dart';
import '../../game_modules/phoneme_train/phoneme_train_screen.dart';
import '../../game_modules/sound_tracing/sound_tracing_screen.dart';
import '../../game_modules/tap_and_grow/tap_and_grow_screen.dart';
import '../../game_modules/whos_behind_door/whos_behind_door_screen.dart';
import '../../game_modules/word_reading/word_reading_screen.dart';
import 'level1_screen.dart';
import 'level3_screen.dart';
import 'level4_screen.dart';

class SoundModeScreen extends ConsumerStatefulWidget {
  const SoundModeScreen({
    super.key,
    required this.syllable,
    required this.onFinish,
  });

  final String syllable;
  final VoidCallback onFinish;

  @override
  ConsumerState<SoundModeScreen> createState() => _SoundModeScreenState();
}

class _SoundModeScreenState extends ConsumerState<SoundModeScreen> {
  static const int _totalPages = 10;

  late final PageController _pageController;
  bool _initialized = false;
  int  _currentPage = 0;

  late final ValueNotifier<String?> _offlineNotifier;
  VoidCallback? _offlineListener;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onScrollChanged);
    _offlineNotifier = ref.read(audioServiceProvider).offlineModeNotifier;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(soundModeProvider.notifier).initSync(widget.syllable);
      if (mounted) setState(() => _initialized = true);

      ref.read(soundModeProvider.notifier)
          .preloadAudio(widget.syllable)
          .catchError((e) => debugPrint('[SoundMode] preload error: $e'));

      _offlineListener = () {
        final msg = _offlineNotifier.value;
        if (msg != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.orange.shade700),
          );
        }
      };
      _offlineNotifier.addListener(_offlineListener!);
    });
  }

  @override
  void dispose() {
    if (_offlineListener != null) {
      _offlineNotifier.removeListener(_offlineListener!);
    }
    _pageController.removeListener(_onScrollChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) setState(() => _currentPage = page);
  }

  Future<void> _onNext() async {
    ref.read(soundModeProvider.notifier).advanceLevel();
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onSkip() {
    final notifier = ref.read(soundModeProvider.notifier);
    notifier.markAudioReady();
    notifier.markLevelComplete();
    if (_currentPage < _totalPages - 1) {
      _onNext();
    } else {
      _finishSession();
    }
  }

  /// Collects session scores for this syllable, sends an email report to the
  /// parent, then invokes [widget.onFinish].
  void _finishSession() {
    final profile = ref.read(childProfileProvider);
    final levelState = ref.read(levelProvider);

    // Gather only activities that belong to this syllable (e.g. 'ma_feed_monster')
    final scores = <String, double>{};
    for (final entry in levelState.scores.entries) {
      if (entry.key.startsWith('${widget.syllable}_')) {
        scores[entry.key] = entry.value.accuracy;
      }
    }

    ReportService.instance.sendSessionReport(
      parentEmail: profile?.parentEmail ?? '',
      childName:   profile?.name ?? 'your child',
      syllable:    widget.syllable,
      scores:      scores,
      totalStars:  profile?.totalStars ?? 0,
    );

    widget.onFinish();
  }

  String _activityId(String suffix) => '${widget.syllable}_$suffix';

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Level1Screen(syllable: widget.syllable, onNext: _onNext),

              FeedTheMonsterScreen(
                syllable:   widget.syllable,
                activityId: _activityId('feed_monster'),
                onComplete: _onNext,
                onExit:     _finishSession,
              ),

              Level3Screen(
                syllable:   widget.syllable,
                activityId: _activityId('bubble_hunt'),
                onNext:     _onNext,
              ),

              SoundTracingScreen(
                syllable:   widget.syllable,
                activityId: _activityId('sound_tracing'),
                onComplete: _onNext,
                onExit:     _finishSession,
              ),

              EchoAnimalScreen(
                syllable:   widget.syllable,
                activityId: _activityId('echo_animal'),
                onComplete: _onNext,
                onExit:     _finishSession,
              ),

              TapAndGrowScreen(
                syllable:   widget.syllable,
                activityId: _activityId('tap_grow'),
                onComplete: _onNext,
                onExit:     _finishSession,
              ),

              WhosBehindDoorScreen(
                syllable:   widget.syllable,
                activityId: _activityId('whos_door'),
                onComplete: _onNext,
                onExit:     _finishSession,
              ),

              PhonemeTrainScreen(
                syllable:   widget.syllable,
                activityId: _activityId('phoneme_train'),
                onComplete: _onNext,
                onExit:     _finishSession,
              ),

              Level4Screen(
                syllable: widget.syllable,
                onFinish: _onNext,
              ),

              WordReadingScreen(
                syllable:   widget.syllable,
                activityId: _activityId('word_reading'),
                onComplete: _finishSession,
                onExit:     _finishSession,
              ),
            ],
          ),

          // ── Top nav bar ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _NavChip(
                    icon:  Icons.arrow_back_ios_new_rounded,
                    label: 'Home',
                    onTap: _finishSession,
                  ),
                  const Spacer(),
                  _StepDots(
                    current: _currentPage,
                    total:   _totalPages,
                    onDotTapped: (i) => _pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  const Spacer(),
                  _NavChip(
                    icon:   Icons.skip_next_rounded,
                    label:  isLastPage ? 'Finish' : 'Skip',
                    onTap:  _onSkip,
                    filled: true,
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

// ── Step dots ──────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total, required this.onDotTapped});

  final int current;
  final int total;
  final ValueChanged<int> onDotTapped;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return GestureDetector(
          onTap: () => onDotTapped(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width:  active ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

// ── Nav chip ───────────────────────────────────────────────────────────────────

class _NavChip extends StatelessWidget {
  const _NavChip({required this.icon, required this.label, required this.onTap, this.filled = false});

  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  final bool         filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primary.withOpacity(0.9)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: filled
              ? [
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(width: 4),
                  Icon(icon, size: 16, color: Colors.white),
                ]
              : [
                  Icon(icon, size: 16, color: AppColors.textMedium),
                  const SizedBox(width: 4),
                  Text(label, style: TextStyle(color: AppColors.textMedium, fontSize: 14)),
                ],
        ),
      ),
    );
  }
}
