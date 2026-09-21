import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_providers.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  int    _step     = 0; // 0 = name, 1 = email
  bool   _loading  = false;
  String _name     = '';

  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  final _emailFocus      = FocusNode();

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _bgController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _bgController    = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    _bgController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // ── Logic ─────────────────────────────────────────────────────────────────

  void _onNameNext() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() { _name = name; _step = 1; });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _emailFocus.requestFocus();
    });
  }

  Future<void> _onEmailDone() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
    setState(() => _loading = true);

    await ref.read(childProfileProvider.notifier).createProfile(_name, email);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (ctx, _) {
              final t = _bgController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(math.sin(t * math.pi * 2) * 0.5, -1),
                    end:   Alignment(math.cos(t * math.pi * 2) * 0.5,  1),
                    colors: const [Color(0xFF0D1B3E), Color(0xFF533483), Color(0xFF0F3460)],
                  ),
                ),
              );
            },
          ),

          // Floating sparkles
          ..._buildSparkles(),

          // Content
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end:   Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: _step == 0
                  ? _NameStep(
                      key:            const ValueKey('name'),
                      controller:     _nameController,
                      floatAnim:      _floatController,
                      onNext:         _onNameNext,
                    )
                  : _EmailStep(
                      key:            const ValueKey('email'),
                      childName:      _name,
                      controller:     _emailController,
                      focusNode:      _emailFocus,
                      floatAnim:      _floatController,
                      isLoading:      _loading,
                      onBack:         () => setState(() => _step = 0),
                      onDone:         _onEmailDone,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles() {
    const positions = [
      Alignment(-0.85, -0.7), Alignment(0.80, -0.6), Alignment(-0.7, 0.3),
      Alignment(0.75, 0.2),   Alignment(-0.5, 0.7),  Alignment(0.60, 0.65),
    ];
    const colors = [
      Color(0xFFFFE66D), Color(0xFFFF6B9D), Color(0xFF4ECDC4),
      Color(0xFF6BCB77), Color(0xFFA855F7), Color(0xFFFF9F43),
    ];
    return List.generate(positions.length, (i) {
      return Align(
        alignment: positions[i],
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (ctx, child) {
            final scale = 0.7 + 0.3 * math.sin(_floatController.value * math.pi + i * 0.5);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: colors[i].withOpacity(0.7),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: colors[i].withOpacity(0.4), blurRadius: 8)],
            ),
          ),
        ),
      );
    });
  }
}

// ── Step 1: Child's name ───────────────────────────────────────────────────────

class _NameStep extends StatelessWidget {
  const _NameStep({
    super.key,
    required this.controller,
    required this.floatAnim,
    required this.onNext,
  });

  final TextEditingController controller;
  final AnimationController   floatAnim;
  final VoidCallback          onNext;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascot
            AnimatedBuilder(
              animation: floatAnim,
              builder: (ctx, child) => Transform.translate(
                offset: Offset(0, math.sin(floatAnim.value * math.pi) * -12),
                child: child,
              ),
              child: SizedBox(width: 140, height: 140, child: CustomPaint(painter: _OwlPainter())),
            ),

            const SizedBox(height: 28),

            const Text('Mave',
              style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white,
                  letterSpacing: 2,
                  shadows: [Shadow(color: Color(0x88FF6B6B), blurRadius: 20, offset: Offset(0, 4))])),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Text("Reading starts with a sound",
                  style: TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w500)),
            ),

            const SizedBox(height: 44),

            // Step indicator
            _StepDots(current: 0, total: 2),

            const SizedBox(height: 24),

            const Text("What's your little one's name?",
                style: TextStyle(fontSize: 17, color: Colors.white70, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),

            const SizedBox(height: 16),

            // Name field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: TextField(
                controller:         controller,
                style:              const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                textAlign:          TextAlign.center,
                textCapitalization: TextCapitalization.words,
                textInputAction:    TextInputAction.next,
                onSubmitted:        (_) => onNext(),
                decoration: const InputDecoration(
                  hintText:       "Child's name",
                  hintStyle:      TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xFFB0B0C8)),
                  border:         InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Next button
            GestureDetector(
              onTap: onNext,
              child: Container(
                width: double.infinity, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF9F43)]),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Next", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Parent's email ────────────────────────────────────────────────────

class _EmailStep extends StatelessWidget {
  const _EmailStep({
    super.key,
    required this.childName,
    required this.controller,
    required this.focusNode,
    required this.floatAnim,
    required this.isLoading,
    required this.onBack,
    required this.onDone,
  });

  final String                childName;
  final TextEditingController controller;
  final FocusNode             focusNode;
  final AnimationController   floatAnim;
  final bool                  isLoading;
  final VoidCallback          onBack;
  final VoidCallback          onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Envelope illustration
            AnimatedBuilder(
              animation: floatAnim,
              builder: (ctx, child) => Transform.translate(
                offset: Offset(0, math.sin(floatAnim.value * math.pi) * -8),
                child: child,
              ),
              child: SizedBox(width: 120, height: 120, child: CustomPaint(painter: _EnvelopePainter())),
            ),

            const SizedBox(height: 24),

            Text('Hi, $childName!',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white,
                    shadows: [Shadow(color: Color(0x88FF6B6B), blurRadius: 16, offset: Offset(0, 3))])),

            const SizedBox(height: 12),

            // Step indicator
            _StepDots(current: 1, total: 2),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline_rounded, color: Color(0xFF4ECDC4), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "We'll send $childName's learning reports to your email after each session.",
                      style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Parent's email",
                  style: TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w600)),
            ),

            const SizedBox(height: 10),

            // Email field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFF4ECDC4).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: TextField(
                controller:     controller,
                focusNode:      focusNode,
                keyboardType:   TextInputType.emailAddress,
                textAlign:      TextAlign.center,
                textInputAction: TextInputAction.done,
                onSubmitted:    (_) => onDone(),
                style:          const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                decoration: const InputDecoration(
                  hintText:       'parent@email.com',
                  hintStyle:      TextStyle(fontSize: 16, color: Color(0xFFB0B0C8)),
                  border:         InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  prefixIcon:     Icon(Icons.mail_outline_rounded, color: Color(0xFF4ECDC4)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'No spam, ever. Only your child\'s progress.',
              style: TextStyle(fontSize: 12, color: Colors.white38),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // Start button
            GestureDetector(
              onTap: isLoading ? null : onDone,
              child: Container(
                width: double.infinity, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF6BCB77)]),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: const Color(0xFF4ECDC4).withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                      : const Text("Let's Play! 🚀",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Back link
            GestureDetector(
              onTap: onBack,
              child: const Text('← Change name',
                  style: TextStyle(color: Colors.white38, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step dots ─────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width:  active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFF6B6B) : Colors.white30,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Owl mascot ─────────────────────────────────────────────────────────────────

class _OwlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final cx = w / 2;    final cy = h / 2;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.05), width: w * 0.70, height: h * 0.80),
        Paint()..color = const Color(0xFF8B5CF6));
    canvas.drawCircle(Offset(cx, cy - h * 0.28), w * 0.35, Paint()..color = const Color(0xFF7C3AED));
    for (final dx in [-w * 0.18, w * 0.18]) {
      final path = Path()
        ..moveTo(cx + dx, cy - h * 0.48)
        ..lineTo(cx + dx - w * 0.08, cy - h * 0.62)
        ..lineTo(cx + dx + w * 0.08, cy - h * 0.62)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFF5B21B6));
    }
    for (final dx in [-w * 0.13, w * 0.13]) {
      canvas.drawCircle(Offset(cx + dx, cy - h * 0.30), w * 0.14, Paint()..color = const Color(0xFFFFE66D));
      canvas.drawCircle(Offset(cx + dx, cy - h * 0.30), w * 0.09, Paint()..color = const Color(0xFF1A1A2E));
      canvas.drawCircle(Offset(cx + dx - w * 0.03, cy - h * 0.33), w * 0.03, Paint()..color = Colors.white);
    }
    final beakPath = Path()
      ..moveTo(cx, cy - h * 0.20)
      ..lineTo(cx - w * 0.06, cy - h * 0.13)
      ..lineTo(cx + w * 0.06, cy - h * 0.13)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = const Color(0xFFFFB347));
    for (final dx in [-w * 0.35, w * 0.35]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + dx, cy + h * 0.10), width: w * 0.22, height: h * 0.50),
          Paint()..color = const Color(0xFF5B21B6));
    }
    final starPaint = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(Offset(cx - w * 0.08, cy + h * 0.12), w * 0.04, starPaint);
    canvas.drawCircle(Offset(cx + w * 0.10, cy + h * 0.05), w * 0.03, starPaint);
    canvas.drawCircle(Offset(cx, cy + h * 0.22), w * 0.035, starPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Envelope illustration ──────────────────────────────────────────────────────

class _EnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(4, h * 0.18, w - 8, h * 0.64), const Radius.circular(12));

    // Envelope body
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF4ECDC4));
    canvas.drawRRect(rect, Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Flap (top triangle)
    final flapPath = Path()
      ..moveTo(4, h * 0.18)
      ..lineTo(w / 2, h * 0.52)
      ..lineTo(w - 4, h * 0.18)
      ..close();
    canvas.drawPath(flapPath, Paint()..color = const Color(0xFF26A69A));

    // Bottom fold lines
    final linePaint = Paint()..color = Colors.white.withOpacity(0.4)..strokeWidth = 1.5;
    canvas.drawLine(Offset(4, h * 0.82), Offset(w / 2, h * 0.56), linePaint);
    canvas.drawLine(Offset(w - 4, h * 0.82), Offset(w / 2, h * 0.56), linePaint);

    // Star on envelope
    const cx = 0.0;
    final starPaint = Paint()..color = const Color(0xFFFFE66D);
    canvas.drawCircle(Offset(w / 2, h * 0.7), 8, starPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
