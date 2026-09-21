import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../shared/cartoon_progress_bar.dart';
import 'phonics_bubble_pop_screen.dart';
import 'phonics_forest_background.dart';
import 'phonics_routes.dart';

class PhonicsSoundSceneScreen extends StatefulWidget {
  const PhonicsSoundSceneScreen({
    super.key,
    required this.sound,
  });

  final String sound;

  @override
  State<PhonicsSoundSceneScreen> createState() => _PhonicsSoundSceneScreenState();
}

class _PhonicsSoundSceneScreenState extends State<PhonicsSoundSceneScreen>
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

    return Scaffold(
      body: Stack(
        children: [
          const PhonicsForestBackground(),
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  return Stack(
                    children: [
                      _Butterfly(animation: _controller, startX: w * 0.10, startY: 72, size: 24),
                      _Butterfly(animation: _controller, startX: w * 0.27, startY: 128, size: 20),
                      _Butterfly(animation: _controller, startX: w * 0.46, startY: 86, size: 28),
                      _Butterfly(animation: _controller, startX: w * 0.66, startY: 118, size: 22),
                      _Butterfly(animation: _controller, startX: w * 0.84, startY: 78, size: 30),
                    ],
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _LevelProgressBar(
                          label: 'Activity 1 of 3',
                          value: 0.33,
                          onCheckpointTap: (_) {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      _HomeActionButton(
                        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Sound Time',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 18),
                _PhonicsWordCard(
                  first: first,
                  second: second,
                  animation: _controller,
                ),
                const SizedBox(height: 18),
                const Text(
                  '→',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 190,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      return Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (_, __) {
                              final dx = -34 + (_controller.value * (w + 68));
                              final hop = math.sin(_controller.value * math.pi * 8) * 11;
                              final legPhase = math.sin(_controller.value * math.pi * 8);
                              return Positioned(
                                left: dx,
                                bottom: 28 + hop.abs(),
                                child: _RabbitHopper(legPhase: legPhase),
                              );
                            },
                          ),
                        ],
                      );
                    },
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
                            PhonicsBubblePopScreen(targetSound: widget.sound),
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
        ],
      ),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(
        Icons.home_rounded,
        color: Colors.white,
        size: 30,
      ),
      tooltip: 'Home',
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.28),
      ),
    );
  }
}

class _LevelProgressBar extends StatelessWidget {
  const _LevelProgressBar({
    required this.label,
    required this.value,
    required this.onCheckpointTap,
  });

  final String label;
  final double value;
  final ValueChanged<int> onCheckpointTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => CartoonProgressBar(
        value: v,
        height: 28,
        checkpointCount: 3,
        currentCheckpoint: 0,
        onCheckpointTap: onCheckpointTap,
      ),
    );
  }
}

class _PhonicsWordCard extends StatelessWidget {
  const _PhonicsWordCard({
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.2),
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
          final firstPulse = 1 + (firstBreathe * 0.13);
          final secondPulse = 1 + (secondBreathe * 0.13);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.scale(
                scale: firstPulse,
                child: Text(
                  first.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 82,
                    height: 0.95,
                    color: Color(0xFFFFF59D),
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: Color(0xAA000000), blurRadius: 6)],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Transform.scale(
                scale: secondPulse,
                child: Text(
                  second.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 82,
                    height: 0.95,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: Color(0xAA000000), blurRadius: 6)],
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
        final dx = math.sin((animation.value * math.pi * 2) + startX / 40) * 20;
        final dy = math.cos((animation.value * math.pi * 2) + startY / 30) * 12;
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
                  BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
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
