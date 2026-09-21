import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/profile_provider.dart';
import '../home/home_screen.dart';

// ─── Landing / Onboarding ────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final AnimationController _floatCtrl;
  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _floatCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    setState(() => _isLoading = true);
    await ref
        .read(profileProvider.notifier)
        .createProfile(name, parentEmail: email);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Animated background ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              size: Size.infinite,
              painter: _BubblyBgPainter(_bgCtrl.value),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ── Floating "mave" title ─────────────────────────────
                      AnimatedBuilder(
                        animation: _floatCtrl,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(
                            0,
                            math.sin(_floatCtrl.value * math.pi) * 10,
                          ),
                          child: const _MaveTitle(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Where learning feels like magic ✨',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.95),
                          shadows: const [
                            Shadow(
                              color: Color(0x77000000),
                              offset: Offset(1, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ).animate(delay: 250.ms).fadeIn(duration: 600.ms),

                      const SizedBox(height: 48),

                      // ── Kid's name ────────────────────────────────────────
                      _InputCard(
                            controller: _nameController,
                            hint: "Child's name",
                            emoji: '🧒',
                            borderColor: const Color(0xFFFF8A80),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Please enter a name'
                                : null,
                          )
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: 16),

                      _InputCard(
                            controller: _emailController,
                            hint: "Parent email",
                            emoji: '📧',
                            borderColor: const Color(0xFF82B1FF),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty) return 'Please enter parent email';
                              return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
                                  ? null
                                  : 'Enter a valid email';
                            },
                          )
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: 16),

                      const SizedBox(height: 44),

                      // ── Start button ──────────────────────────────────────
                      GestureDetector(
                            onTap: _isLoading ? null : _start,
                            child: Container(
                              width: double.infinity,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFFD93D),
                                    Color(0xFF6BCB77),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      )
                                    : const Text(
                                        "Let's Begin! 🚀",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Color(0x55000000),
                                              offset: Offset(1, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          )
                          .animate(delay: 700.ms)
                          .fadeIn(duration: 500.ms)
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),

                      const SizedBox(height: 28),
                    ],
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

// ─── "mave" title – each letter its own colour ─────────────────────────────

class _MaveTitle extends StatelessWidget {
  const _MaveTitle();

  static const _letters = ['m', 'a', 'v', 'e'];
  static const _colors = [
    Color(0xFFFFD93D),
    Color(0xFFFF6BCB),
    Color(0xFF6BCBFF),
    Color(0xFF6BCB77),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_letters.length, (i) {
        return Text(
              _letters[i],
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w900,
                color: _colors[i],
                height: 1,
                shadows: [
                  const Shadow(
                    color: Color(0x66000000),
                    offset: Offset(3, 4),
                    blurRadius: 8,
                  ),
                  Shadow(
                    color: _colors[i].withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
            )
            .animate(delay: (i * 100).ms)
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.elasticOut,
            );
      }),
    );
  }
}

// ─── Input field card ──────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.hint,
    required this.emoji,
    required this.borderColor,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final String emoji;
  final Color borderColor;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.7),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              validator: validator,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D2B1F),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3D2B1F).withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                errorStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated colorful background painter ─────────────────────────────────

class _BubblyBgPainter extends CustomPainter {
  const _BubblyBgPainter(this.t);
  final double t; // animation value 0..1

  @override
  void paint(Canvas canvas, Size size) {
    // Animated gradient that slowly shifts
    final topColor = Color.lerp(
      const Color(0xFFFF6B9D),
      const Color(0xFFC44EFF),
      t,
    )!;
    final bottomColor = Color.lerp(
      const Color(0xFF44D7A8),
      const Color(0xFF4E9EFF),
      t,
    )!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            topColor,
            const Color(0xFFC44EFF),
            const Color(0xFF4E9EFF),
            bottomColor,
          ],
          stops: const [0.0, 0.35, 0.65, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Soft white overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0x14FFFFFF),
    );

    // Decorative bubbles
    final bubbles = [
      (0.05, 0.05, 80.0, const Color(0x33FF8A80)),
      (0.88, 0.03, 100.0, const Color(0x33FFD740)),
      (0.92, 0.44, 70.0, const Color(0x3382B1FF)),
      (0.08, 0.55, 90.0, const Color(0x33B388FF)),
      (0.50, 0.90, 110.0, const Color(0x3369F0AE)),
      (0.75, 0.78, 60.0, const Color(0x33FF6D00)),
      (0.35, 0.15, 48.0, const Color(0x44FFFFFF)),
      (0.65, 0.35, 74.0, const Color(0x33FFAB40)),
    ];

    for (final (xf, yf, r, color) in bubbles) {
      // slight breathing motion
      final drift = math.sin(t * math.pi * 2 + xf * 10) * 6;
      final center = Offset(xf * size.width, yf * size.height + drift);
      canvas.drawCircle(center, r, Paint()..color = color);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = const Color(0x2EFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Stars / sparkles
    final starPaint = Paint()..color = const Color(0x88FFFFFF);
    const starPositions = [
      (0.20, 0.12),
      (0.78, 0.22),
      (0.55, 0.08),
      (0.10, 0.38),
      (0.90, 0.62),
      (0.45, 0.94),
      (0.30, 0.70),
      (0.62, 0.50),
    ];
    for (final (xf, yf) in starPositions) {
      _drawStar(
        canvas,
        Offset(xf * size.width, yf * size.height),
        8,
        starPaint,
      );
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer =
          c +
          Offset(
            math.cos(i * 4 * math.pi / 5 - math.pi / 2) * r,
            math.sin(i * 4 * math.pi / 5 - math.pi / 2) * r,
          );
      final inner =
          c +
          Offset(
            math.cos(i * 4 * math.pi / 5 + 2 * math.pi / 5 - math.pi / 2) *
                r *
                0.4,
            math.sin(i * 4 * math.pi / 5 + 2 * math.pi / 5 - math.pi / 2) *
                r *
                0.4,
          );
      if (i == 0)
        path.moveTo(outer.dx, outer.dy);
      else
        path.lineTo(outer.dx, outer.dy);
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubblyBgPainter old) => old.t != t;
}
