import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/services/phonics_tts_service.dart';
import 'phonics_zone_screen.dart';
import 'phonics_forest_background.dart';
import 'phonics_routes.dart';

class PhonicsWheelScreen extends ConsumerStatefulWidget {
  const PhonicsWheelScreen({super.key});

  @override
  ConsumerState<PhonicsWheelScreen> createState() => _PhonicsWheelScreenState();
}

class _PhonicsWheelScreenState extends ConsumerState<PhonicsWheelScreen>
    with SingleTickerProviderStateMixin {
  static const _sounds = ['ma', 'ba'];
  static const _wheelColors = [
    Color(0xFFFF8A65),
    Color(0xFFFFD54F),
    Color(0xFF81C784),
    Color(0xFF4FC3F7),
    Color(0xFFBA68C8),
    Color(0xFFF06292),
    Color(0xFFAED581),
    Color(0xFF64B5F6),
  ];

  late final AnimationController _controller;
  Animation<double>? _spinAnimation;
  final _rng = math.Random();
  double _wheelAngle = 0;
  int _selectedIndex = 0;
  bool _isSpinning = false;
  bool _showSplash = true;
  int _streak = 1;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _controller.addListener(() {
      if (_spinAnimation == null) return;
      setState(() => _wheelAngle = _spinAnimation!.value);
    });
    Future<void>.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
    Future<void>.microtask(() {
      ref.read(phonicsTtsServiceProvider).playWelcome();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    final targetIndex = _rng.nextInt(_sounds.length);
    final segmentAngle = 2 * math.pi / _sounds.length;
    final fullTurns = 5 + _rng.nextInt(3);
    final targetAngle =
        (fullTurns * 2 * math.pi) - (targetIndex * segmentAngle);

    setState(() => _isSpinning = true);
    _spinAnimation = Tween<double>(
      begin: _wheelAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller
      ..reset()
      ..forward().whenComplete(() {
        if (!mounted) return;
        setState(() {
          _wheelAngle = targetAngle % (2 * math.pi);
          _selectedIndex = targetIndex;
          _isSpinning = false;
          _streak += 1;
          _stars += 2;
        });
        ref.read(phonicsTtsServiceProvider).playSound(_sounds[_selectedIndex]);
        Future<void>.delayed(const Duration(milliseconds: 420), () {
          if (!mounted) return;
          Navigator.of(context).push(
            buildPhonicsSlideRoute(
              PhonicsZoneScreen(sound: _sounds[_selectedIndex]),
            ),
          );
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final pickedSound = _sounds[_selectedIndex];
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      body: Stack(
        children: [
          const PhonicsForestBackground(),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.35, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _showSplash
                  ? const _SplashBody()
                  : _WheelContent(
                      wheelAngle: _wheelAngle,
                      isSpinning: _isSpinning,
                      pickedSound: pickedSound,
                      onSpin: _spinWheel,
                      sounds: _sounds,
                      wheelColors: _wheelColors,
                      streak: _streak,
                      stars: _stars,
                      isDarkMode: settings.isDarkMode,
                      onGoHome: () => Navigator.of(context).pop(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: ValueKey('phonicsSplash'),
      child: Text(
        'Phonical\nSounds',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 68,
          height: 0.95,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [Shadow(color: Color(0xAA000000), blurRadius: 10)],
          fontFamilyFallback: ['Comic Sans MS', 'Marker Felt', 'Chalkboard SE'],
        ),
      ),
    );
  }
}

class _WheelContent extends StatelessWidget {
  const _WheelContent({
    required this.wheelAngle,
    required this.isSpinning,
    required this.pickedSound,
    required this.onSpin,
    required this.sounds,
    required this.wheelColors,
    required this.streak,
    required this.stars,
    required this.isDarkMode,
    required this.onGoHome,
  });

  final double wheelAngle;
  final bool isSpinning;
  final String pickedSound;
  final VoidCallback onSpin;
  final List<String> sounds;
  final List<Color> wheelColors;
  final int streak;
  final int stars;
  final bool isDarkMode;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('phonicsWheel'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                _GamifiedPill(
                  icon: Icons.local_fire_department_rounded,
                  label: '$streak streak',
                ),
                const SizedBox(width: 8),
                _GamifiedPill(icon: Icons.stars_rounded, label: '$stars stars'),
                const Spacer(),
                IconButton(
                  onPressed: onGoHome,
                  icon: Icon(
                    Icons.home_rounded,
                    color: isDarkMode ? const Color(0xFFE3F2FD) : Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            const Text(
              'Phonics Lucky Wheel',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [Shadow(color: Color(0xAA000000), blurRadius: 8)],
                fontFamilyFallback: [
                  'Comic Sans MS',
                  'Marker Felt',
                  'Chalkboard SE',
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Today\'s sound: ${pickedSound.toUpperCase()}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamilyFallback: [
                  'Comic Sans MS',
                  'Marker Felt',
                  'Chalkboard SE',
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 390,
              height: 426,
              child: GestureDetector(
                onHorizontalDragEnd: (_) => onSpin(),
                onVerticalDragEnd: (_) => onSpin(),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 2,
                      child: Icon(
                        Icons.arrow_drop_down_circle,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.98),
                      ),
                    ),
                    Positioned(
                      top: 38,
                      child: Transform.rotate(
                        angle: wheelAngle,
                        child: CustomPaint(
                          size: const Size(350, 350),
                          painter: _WheelPainter(
                            sounds: sounds,
                            colors: wheelColors,
                          ),
                        ),
                      ),
                    ),
                    if (!isSpinning)
                      Positioned(
                        right: 4,
                        bottom: 54,
                        child: _SwipeHint(isDarkMode: isDarkMode),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSpinning ? 'Spinning...' : 'Swipe the wheel to spin',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamilyFallback: [
                  'Comic Sans MS',
                  'Marker Felt',
                  'Chalkboard SE',
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter({required this.sounds, required this.colors});

  final List<String> sounds;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * math.pi / sounds.length;

    final wheelRect = Rect.fromCircle(center: center, radius: radius);
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    for (int i = 0; i < sounds.length; i++) {
      final start = -math.pi / 2 + (i * segmentAngle);
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(wheelRect, start, segmentAngle, true, paint);

      final textAngle = start + segmentAngle / 2;
      final textOffset = Offset(
        center.dx + math.cos(textAngle) * radius * 0.62,
        center.dy + math.sin(textAngle) * radius * 0.62,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: sounds[i].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Color(0xAA000000), blurRadius: 4)],
            fontFamilyFallback: [
              'Comic Sans MS',
              'Marker Felt',
              'Chalkboard SE',
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    canvas.drawCircle(center, 18, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

class _GamifiedPill extends StatelessWidget {
  const _GamifiedPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFFF59D)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -8, end: 8),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOut,
      onEnd: () {},
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(value, 0), child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pan_tool_alt_rounded,
              color: isDarkMode
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFFFF59D),
              size: 18,
            ),
            const SizedBox(width: 6),
            const Text(
              'Swipe',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
