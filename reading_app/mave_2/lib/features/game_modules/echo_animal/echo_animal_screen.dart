import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Animal {
  const _Animal({
    required this.emoji,
    required this.name,
    required this.sound,
  });
  final String emoji;
  final String name;
  final String sound; // what the animal "says" (simple phoneme-friendly text)
}

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Echo the Animal — hear the animal + phoneme, then echo it back into the mic.
///
/// 3 rounds of different animals, each associated with the target phoneme.
/// MicrophoneController detects any vocalization → celebrate → next round.
class EchoAnimalScreen extends ConsumerStatefulWidget {
  const EchoAnimalScreen({
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
  ConsumerState<EchoAnimalScreen> createState() => _EchoAnimalScreenState();
}

class _EchoAnimalScreenState extends ConsumerState<EchoAnimalScreen>
    with SingleTickerProviderStateMixin {
  // ── Animals ────────────────────────────────────────────────────────────────

  static const List<_Animal> _maAnimals = [
    _Animal(emoji: '🐄', name: 'Cow',    sound: 'Moo'),
    _Animal(emoji: '🐒', name: 'Monkey', sound: 'Ooh ooh'),
    _Animal(emoji: '🐱', name: 'Cat',    sound: 'Meow'),
  ];

  static const List<_Animal> _paAnimals = [
    _Animal(emoji: '🦜', name: 'Parrot',  sound: 'Squawk'),
    _Animal(emoji: '🐧', name: 'Penguin', sound: 'Honk'),
    _Animal(emoji: '🦚', name: 'Peacock', sound: 'Meeow'),
  ];

  // ── State ──────────────────────────────────────────────────────────────────

  static const int _totalRounds = 3;

  int  _round        = 0;
  int  _successCount = 0;
  bool _waitingForEcho  = false;
  bool _echoed          = false; // child made a sound this round
  bool _complete        = false;

  Timer? _listenTimer;
  late final AnimationController _pulseController;

  // Cached so dispose() can call stop() without using ref.
  late final MicrophoneController _mic;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _mic = ref.read(microphoneControllerProvider);

    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startRound());
  }

  @override
  void dispose() {
    _listenTimer?.cancel();
    _pulseController.dispose();
    _mic.stop();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<_Animal> get _animals =>
      widget.syllable == 'ma' ? _maAnimals : _paAnimals;

  _Animal get _currentAnimal => _animals[_round % _animals.length];

  // ── Round logic ────────────────────────────────────────────────────────────

  Future<void> _startRound() async {
    if (!mounted) return;
    setState(() {
      _waitingForEcho = false;
      _echoed         = false;
    });

    final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
    final animal   = _currentAnimal;
    try {
      await ref.read(audioServiceProvider).speak(
          '${animal.name} says ${animal.sound}! Now you say $phonetic!');
    } catch (e) {
      debugPrint('[Echo] Audio failed: $e');
    }

    if (!mounted) return;
    setState(() => _waitingForEcho = true);

    // Start mic
    await _mic.start();

    // Listen for up to 6 seconds
    _listenTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _echoed) return;
      // Gently nudge
      ref.read(audioServiceProvider)
          .speak('Try saying ${PhoneticHelper.toPhonetic(widget.syllable)}!')
          .ignore();
    });

    // Poll mic for any vocalization
    Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _complete) { t.cancel(); return; }
      if (_echoed) { t.cancel(); return; }
      if (_mic.isSpeaking && _waitingForEcho) {
        t.cancel();
        _onEcho();
      }
    });
  }

  Future<void> _onEcho() async {
    if (_echoed || !mounted) return;
    _listenTimer?.cancel();
    setState(() {
      _echoed         = true;
      _waitingForEcho = false;
      _successCount++;
    });

    _mic.stop();

    final audio = ref.read(audioServiceProvider);

    try {
      await audio.speak(
          PhoneticHelper.praiseFor(widget.syllable));
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    _round++;
    if (_round >= _totalRounds) {
      _finish();
    } else {
      _startRound();
    }
  }

  Future<void> _finish() async {
    setState(() => _complete = true);
    final accuracy = (_successCount / _totalRounds).clamp(0.0, 1.0);
    
    final levelNotifier = ref.read(levelProvider.notifier);
    final audio = ref.read(audioServiceProvider);

    await levelNotifier.record(widget.activityId, accuracy);
    if (!mounted) return;

    try {
      await audio.speak('Amazing! You echoed every animal!');
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) widget.onComplete();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mic = ref.watch(microphoneControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              round: _round,
              total: _totalRounds,
              onBack: widget.onExit,
            ),

            const Spacer(),

            if (_complete) ...[
              const Text('🎉', style: TextStyle(fontSize: 80))
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 16),
              Text(
                'You echoed every animal!',
                style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.accentGreen),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // Animal display
              Text(
                _currentAnimal.emoji,
                style: const TextStyle(fontSize: 100),
              )
                  .animate(key: ValueKey(_round))
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: 16),

              Text(
                '${_currentAnimal.name} says "${_currentAnimal.sound}"',
                style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                _waitingForEcho
                    ? 'Now you say: ${PhoneticHelper.toPhonetic(widget.syllable)}'
                    : 'Listen carefully...',
                style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey(_waitingForEcho)).fadeIn(),

              const SizedBox(height: 32),

              // Mic pulse indicator
              if (_waitingForEcho)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (ctx, child) => Transform.scale(
                    scale: 1.0 + _pulseController.value * 0.15,
                    child: child,
                  ),
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: mic.isSpeaking
                          ? AppColors.accentGreen.withAlpha(200)
                          : AppColors.primary.withAlpha(60),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: mic.isSpeaking
                              ? AppColors.accentGreen
                              : AppColors.primary,
                          width: 3),
                    ),
                    child: Icon(
                      mic.isSpeaking
                          ? Icons.record_voice_over_rounded
                          : Icons.mic_rounded,
                      size: 48,
                      color: mic.isSpeaking
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  ),
                ),

              if (_echoed && !_complete)
                const Icon(Icons.check_circle_rounded,
                        size: 80, color: AppColors.accentGreen)
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),
            ],

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.round,
    required this.total,
    required this.onBack,
  });
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
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Echo the Animal',
            style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${round + 1} / $total',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
