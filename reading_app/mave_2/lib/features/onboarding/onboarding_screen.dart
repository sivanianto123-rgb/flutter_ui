import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_providers.dart';
import '../home/home_screen.dart';

// ─── Landing / Onboarding Screen ───────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey         = GlobalKey<FormState>();
  bool _isLoading        = false;

  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name  = _nameController.text.trim();
    final email = _emailController.text.trim();
    setState(() => _isLoading = true);
    await ref.read(childProfileProvider.notifier).createProfile(
      name,
      parentEmail: email.isEmpty ? null : email,
    );
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
          // ── Colorful animated background ──────────────────────────────────
          const _BubblyBackground(),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // ── Floating title ──────────────────────────────────
                      AnimatedBuilder(
                        animation: _floatController,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, math.sin(_floatController.value * math.pi) * 8),
                          child: const _MaveTitle(),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Where learning feels like magic ✨',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.92),
                          shadows: const [
                            Shadow(color: Color(0x66000000), offset: Offset(1, 1), blurRadius: 4),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 600.ms),

                      const SizedBox(height: 44),

                      // ── Kid's name field ────────────────────────────────
                      _InputCard(
                        controller: _nameController,
                        hint: "Child's name",
                        icon: '🧒',
                        color: const Color(0xFFFF8A80),
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
                      )
                          .animate(delay: 350.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),

                      const SizedBox(height: 16),

                      // ── Parent's email field ────────────────────────────
                      _InputCard(
                        controller: _emailController,
                        hint: "Parent's email (optional)",
                        icon: '✉️',
                        color: const Color(0xFF82B1FF),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
                          return ok ? null : 'Please enter a valid email';
                        },
                      )
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),

                      const SizedBox(height: 40),

                      // ── Start button ────────────────────────────────────
                      GestureDetector(
                        onTap: _isLoading ? null : _start,
                        child: Container(
                          width: double.infinity,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFF6BCB77)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                : const Text(
                                    "Let's Begin! 🚀",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(color: Color(0x55000000), offset: Offset(1, 2), blurRadius: 4),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      )
                          .animate(delay: 650.ms)
                          .fadeIn(duration: 500.ms)
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1, 1),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          ),

                      const SizedBox(height: 24),
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

// ─── Animated bubbly background ────────────────────────────────────────────

class _BubblyBackground extends StatelessWidget {
  const _BubblyBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _BubblyPainter()),
    );
  }
}

class _BubblyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFFFF6B9D),
          Color(0xFFC44EFF),
          Color(0xFF4E9EFF),
          Color(0xFF44D7A8),
          Color(0xFFFFD93D),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Soft light overlay
    final overlayPaint = Paint()
      ..color = Colors.white.withOpacity(0.08);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // Decorative circles / bubbles
    final bubbles = [
      _Bubble(0.05, 0.05, 80, const Color(0x33FF8A80)),
      _Bubble(0.85, 0.02, 100, const Color(0x33FFD740)),
      _Bubble(0.92, 0.45, 70,  const Color(0x3382B1FF)),
      _Bubble(0.1,  0.55, 90,  const Color(0x33B388FF)),
      _Bubble(0.5,  0.88, 110, const Color(0x3369F0AE)),
      _Bubble(0.75, 0.78, 60,  const Color(0x33FF6D00)),
      _Bubble(0.35, 0.15, 50,  const Color(0x33FFFFFF)),
      _Bubble(0.65, 0.35, 75,  const Color(0x33FFAB40)),
    ];

    for (final b in bubbles) {
      final paint = Paint()
        ..color = b.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(b.xFrac * size.width, b.yFrac * size.height),
        b.radius,
        paint,
      );
      // Bubble rim
      final rimPaint = Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(
        Offset(b.xFrac * size.width, b.yFrac * size.height),
        b.radius,
        rimPaint,
      );
    }

    // Scattered stars / sparkles
    final starPaint = Paint()..color = Colors.white.withOpacity(0.55);
    final stars = [
      Offset(size.width * 0.2,  size.height * 0.12),
      Offset(size.width * 0.78, size.height * 0.22),
      Offset(size.width * 0.55, size.height * 0.08),
      Offset(size.width * 0.1,  size.height * 0.38),
      Offset(size.width * 0.9,  size.height * 0.62),
      Offset(size.width * 0.45, size.height * 0.95),
      Offset(size.width * 0.3,  size.height * 0.7),
    ];
    for (final s in stars) {
      _drawStar(canvas, s, 8, starPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = center + Offset(
        math.cos((i * 4 * math.pi / 5) - math.pi / 2) * size,
        math.sin((i * 4 * math.pi / 5) - math.pi / 2) * size,
      );
      final inner = center + Offset(
        math.cos((i * 4 * math.pi / 5 + 2 * math.pi / 5) - math.pi / 2) * size * 0.4,
        math.sin((i * 4 * math.pi / 5 + 2 * math.pi / 5) - math.pi / 2) * size * 0.4,
      );
      if (i == 0) path.moveTo(outer.dx, outer.dy);
      else path.lineTo(outer.dx, outer.dy);
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubblyPainter old) => false;
}

class _Bubble {
  final double xFrac, yFrac, radius;
  final Color color;
  const _Bubble(this.xFrac, this.yFrac, this.radius, this.color);
}

// ─── "mave" title with letter-by-letter colours ────────────────────────────

class _MaveTitle extends StatelessWidget {
  const _MaveTitle();

  static const _letters = ['m', 'a', 'v', 'e'];
  static const _colors  = [
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
              const Shadow(color: Color(0x66000000), offset: Offset(3, 4), blurRadius: 8),
              Shadow(color: _colors[i].withOpacity(0.4), offset: const Offset(0, 0), blurRadius: 20),
            ],
          ),
        )
            .animate(delay: (i * 100).ms)
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
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
    required this.icon,
    required this.color,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final String icon;
  final Color color;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.6), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(icon, style: const TextStyle(fontSize: 28)),
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
                  color: const Color(0xFF3D2B1F).withOpacity(0.4),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                errorStyle: const TextStyle(fontSize: 13, color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
