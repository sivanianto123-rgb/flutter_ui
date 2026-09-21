import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'phonics_bubble_pop_game.dart';
import 'phonics_forest_background.dart';
import 'phonics_routes.dart';
import 'phonics_story_screen.dart';
import '../shared/cartoon_progress_bar.dart';

class PhonicsBubblePopScreen extends StatefulWidget {
  const PhonicsBubblePopScreen({
    super.key,
    required this.targetSound,
  });

  final String targetSound;

  @override
  State<PhonicsBubblePopScreen> createState() => _PhonicsBubblePopScreenState();
}

class _PhonicsBubblePopScreenState extends State<PhonicsBubblePopScreen>
    with SingleTickerProviderStateMixin {
  late final PhonicsBubblePopGame _game;
  late final AnimationController _uiTicker;
  int _targetTotal = 4;
  int _poppedTargets = 0;
  bool _completed = false;

  String get _targetSound => widget.targetSound.toLowerCase();

  void _goToCheckpoint(int checkpoint) {
    if (checkpoint >= 1) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _uiTicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _game = PhonicsBubblePopGame(
      targetSound: _targetSound,
      onProgress: (value) {
        if (!mounted) return;
        setState(() => _poppedTargets = value);
      },
      onCompleted: () {
        if (!mounted) return;
        setState(() => _completed = true);
      },
    );
  }

  @override
  void dispose() {
    _uiTicker.dispose();
    super.dispose();
  }

  // Hot-reload compatibility for stale listeners from older widget versions.
  void _onFrameTick() {}

  @override
  Widget build(BuildContext context) {
    final target = _targetSound.toUpperCase();
    final progress = _targetTotal == 0 ? 0.0 : _poppedTargets / _targetTotal;

    return Scaffold(
      body: Stack(
        children: [
          const PhonicsForestBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: (0.33 + (progress * 0.33)).clamp(0.0, 1.0),
                          ),
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => CartoonProgressBar(
                            value: v,
                            height: 28,
                            checkpointCount: 3,
                            currentCheckpoint: 1,
                            onCheckpointTap: _goToCheckpoint,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        icon: const Icon(Icons.home_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.30),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Pop only "$target" bubbles!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Correct pops: $_poppedTargets / $_targetTotal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: GameWidget(game: _game),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          buildPhonicsSlideRoute(
                            PhonicsStoryScreen(sound: _targetSound),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6F61),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      child: const Text('Next'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_completed)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _uiTicker,
                  builder: (context, _) {
                    final fade = 0.28 + (math.sin(_uiTicker.value * math.pi * 2) * 0.04);
                    return ColoredBox(
                      color: Colors.black.withValues(alpha: fade.clamp(0.24, 0.34)),
                    );
                  },
                ),
              ),
            ),
          if (_completed)
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
      ),
    );
  }
}
