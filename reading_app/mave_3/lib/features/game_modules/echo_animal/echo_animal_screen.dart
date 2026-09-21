import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Animal {
  const _Animal({required this.name, required this.sound, required this.painterIndex});
  final String name;
  final String sound;
  final int    painterIndex; // index into _AnimalPainter factory
}

// ── Screen ─────────────────────────────────────────────────────────────────────

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
  static const List<_Animal> _maAnimals = [
    _Animal(name: 'Cow',    sound: 'Moo',      painterIndex: 0),
    _Animal(name: 'Monkey', sound: 'Ooh ooh',  painterIndex: 1),
    _Animal(name: 'Cat',    sound: 'Meow',     painterIndex: 2),
  ];

  static const List<_Animal> _paAnimals = [
    _Animal(name: 'Parrot',  sound: 'Squawk',  painterIndex: 3),
    _Animal(name: 'Penguin', sound: 'Honk',    painterIndex: 4),
    _Animal(name: 'Peacock', sound: 'Meeow',   painterIndex: 5),
  ];

  static const int _totalRounds = 3;

  int  _round        = 0;
  int  _successCount = 0;
  bool _waitingForEcho = false;
  bool _echoed         = false;
  bool _complete       = false;
  Timer? _listenTimer;

  late final AnimationController _pulseController;
  late final MicrophoneController _mic;

  @override
  void initState() {
    super.initState();
    _mic = ref.read(microphoneControllerProvider);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRound());
  }

  @override
  void dispose() {
    _listenTimer?.cancel();
    _pulseController.dispose();
    _mic.stopQuietly();
    super.dispose();
  }

  List<_Animal> get _animals => widget.syllable == 'ma' ? _maAnimals : _paAnimals;
  _Animal get _currentAnimal => _animals[_round % _animals.length];

  Future<void> _startRound() async {
    if (!mounted) return;
    setState(() { _waitingForEcho = false; _echoed = false; });
    final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
    final animal   = _currentAnimal;
    try {
      await ref.read(audioServiceProvider).speak('${animal.name} says ${animal.sound}! Now you say $phonetic!');
    } catch (_) {}
    if (!mounted) return;
    setState(() => _waitingForEcho = true);
    await _mic.start();
    _listenTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _echoed) return;
      ref.read(audioServiceProvider).speak('Try saying ${PhoneticHelper.toPhonetic(widget.syllable)}!').ignore();
    });
    Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _complete) { t.cancel(); return; }
      if (_echoed) { t.cancel(); return; }
      if (_mic.isSpeaking && _waitingForEcho) { t.cancel(); _onEcho(); }
    });
  }

  Future<void> _onEcho() async {
    if (_echoed || !mounted) return;
    _listenTimer?.cancel();
    setState(() { _echoed = true; _waitingForEcho = false; _successCount++; });
    _mic.stop();
    try {
      await ref.read(audioServiceProvider).speak(PhoneticHelper.praiseFor(widget.syllable));
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _round++;
    if (_round >= _totalRounds) { _finish(); } else { _startRound(); }
  }

  Future<void> _finish() async {
    setState(() => _complete = true);
    final accuracy = (_successCount / _totalRounds).clamp(0.0, 1.0);
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);
    if (!mounted) return;
    try { await ref.read(audioServiceProvider).speak('Amazing! You echoed every animal!'); } catch (_) {}
    Future.delayed(const Duration(milliseconds: 1800), () { if (mounted) widget.onComplete(); });
  }

  @override
  Widget build(BuildContext context) {
    final mic = ref.watch(microphoneControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(round: _round, total: _totalRounds, onBack: widget.onExit),
              const Spacer(),

              if (_complete) ...[
                SizedBox(
                  width: 140, height: 140,
                  child: CustomPaint(painter: _CelebrationStarPainter()),
                ).animate().scale(begin: const Offset(0.3, 0.3), duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                const Text('You echoed every animal!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.accentGreen),
                    textAlign: TextAlign.center),
              ] else ...[
                // Animal illustration
                SizedBox(
                  width: 180, height: 180,
                  child: CustomPaint(painter: _AnimalPainter(index: _currentAnimal.painterIndex)),
                ).animate(key: ValueKey(_round)).fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.6, 0.6), duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: 16),

                Text(
                  '${_currentAnimal.name} says "${_currentAnimal.sound}"',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  _waitingForEcho
                      ? 'Now you say: ${PhoneticHelper.toPhonetic(widget.syllable)}'
                      : 'Listen carefully...',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: _waitingForEcho ? AppColors.accent : Colors.white60,
                  ),
                  textAlign: TextAlign.center,
                ).animate(key: ValueKey(_waitingForEcho)).fadeIn(),

                const SizedBox(height: 32),

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
                        gradient: RadialGradient(colors: [
                          mic.isSpeaking ? AppColors.accentGreen.withOpacity(0.9) : AppColors.primary.withOpacity(0.3),
                          mic.isSpeaking ? AppColors.accentGreen.withOpacity(0.4) : AppColors.primary.withOpacity(0.1),
                        ]),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: mic.isSpeaking ? AppColors.accentGreen : AppColors.primary,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        mic.isSpeaking ? Icons.record_voice_over_rounded : Icons.mic_rounded,
                        size: 48,
                        color: mic.isSpeaking ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),

                if (_echoed && !_complete)
                  const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.accentGreen)
                      .animate().scale(begin: const Offset(0.3, 0.3), duration: 400.ms, curve: Curves.elasticOut),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animal Painter ─────────────────────────────────────────────────────────────

class _AnimalPainter extends CustomPainter {
  const _AnimalPainter({required this.index});
  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    switch (index % 6) {
      case 0: _drawCow(canvas, size);     break;
      case 1: _drawMonkey(canvas, size);  break;
      case 2: _drawCat(canvas, size);     break;
      case 3: _drawParrot(canvas, size);  break;
      case 4: _drawPenguin(canvas, size); break;
      case 5: _drawPeacock(canvas, size); break;
    }
  }

  void _drawCow(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    final r  = size.width * 0.36;
    // Body
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white);
    // Spots
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.3, cy + r * 0.2), width: r * 0.5, height: r * 0.4),
        Paint()..color = Colors.black54);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.35, cy - r * 0.1), width: r * 0.4, height: r * 0.35),
        Paint()..color = Colors.black54);
    // Face
    canvas.drawCircle(Offset(cx, cy - r * 0.05), r * 0.55, Paint()..color = const Color(0xFFFFF3E0));
    // Horns
    _drawHorn(canvas, Offset(cx - r * 0.28, cy - r * 0.85), AppColors.accentOrange);
    _drawHorn(canvas, Offset(cx + r * 0.28, cy - r * 0.85), AppColors.accentOrange);
    // Eyes & nose
    canvas.drawCircle(Offset(cx - r * 0.18, cy - r * 0.15), r * 0.1, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(cx + r * 0.18, cy - r * 0.15), r * 0.1, Paint()..color = Colors.black87);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.15), width: r * 0.35, height: r * 0.22),
        Paint()..color = const Color(0xFFFFB6C1));
  }

  void _drawHorn(Canvas canvas, Offset tip, Color color) {
    final path = Path()
      ..moveTo(tip.dx, tip.dy - 18)
      ..lineTo(tip.dx - 8, tip.dy)
      ..lineTo(tip.dx + 8, tip.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawMonkey(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    final r  = size.width * 0.36;
    // Body
    canvas.drawCircle(Offset(cx, cy + r * 0.1), r * 0.8, Paint()..color = const Color(0xFF8D6E63));
    // Ears
    for (final dx in [-r * 0.92, r * 0.92]) {
      canvas.drawCircle(Offset(cx + dx, cy - r * 0.1), r * 0.32, Paint()..color = const Color(0xFF8D6E63));
      canvas.drawCircle(Offset(cx + dx, cy - r * 0.1), r * 0.18, Paint()..color = const Color(0xFFFFCCBC));
    }
    // Face
    canvas.drawCircle(Offset(cx, cy - r * 0.1), r * 0.58, Paint()..color = const Color(0xFFA1887F));
    // Eyes
    canvas.drawCircle(Offset(cx - r * 0.2, cy - r * 0.22), r * 0.11, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(cx + r * 0.2, cy - r * 0.22), r * 0.11, Paint()..color = Colors.black87);
    // Muzzle
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.08), width: r * 0.45, height: r * 0.28),
        Paint()..color = const Color(0xFFFFCCBC));
    // Smile
    final smilePaint = Paint()..color = Colors.brown.shade700..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + r * 0.08), width: r * 0.28, height: r * 0.18), 0, math.pi, false, smilePaint);
  }

  void _drawCat(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    final r  = size.width * 0.36;
    // Body
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = AppColors.accentOrange);
    // Ears
    for (final dx in [-r * 0.58, r * 0.58]) {
      final tri = Path()
        ..moveTo(cx + dx, cy - r * 0.78)
        ..lineTo(cx + dx - r * 0.22, cy - r * 1.1)
        ..lineTo(cx + dx + r * 0.22, cy - r * 1.1)
        ..close();
      canvas.drawPath(tri, Paint()..color = AppColors.accentOrange);
    }
    // Face
    canvas.drawCircle(Offset(cx, cy - r * 0.05), r * 0.62, Paint()..color = const Color(0xFFFFF3E0));
    // Eyes
    _drawCatEye(canvas, Offset(cx - r * 0.22, cy - r * 0.15), r * 0.12);
    _drawCatEye(canvas, Offset(cx + r * 0.22, cy - r * 0.15), r * 0.12);
    // Nose
    final nosePaint = Paint()..color = const Color(0xFFFF85A1);
    final nosePath = Path()
      ..moveTo(cx, cy + r * 0.08)
      ..lineTo(cx - r * 0.08, cy + r * 0.02)
      ..lineTo(cx + r * 0.08, cy + r * 0.02)
      ..close();
    canvas.drawPath(nosePath, nosePaint);
    // Whiskers
    final wPaint = Paint()..color = Colors.white..strokeWidth = 1.5;
    for (final dy in [-r * 0.02, r * 0.06]) {
      canvas.drawLine(Offset(cx - r * 0.12, cy + dy), Offset(cx - r * 0.55, cy + dy - r * 0.06), wPaint);
      canvas.drawLine(Offset(cx + r * 0.12, cy + dy), Offset(cx + r * 0.55, cy + dy - r * 0.06), wPaint);
    }
  }

  void _drawCatEye(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(center, r * 1.1, Paint()..color = Colors.white);
    // Slit pupil
    canvas.drawOval(Rect.fromCenter(center: center, width: r * 0.5, height: r * 2.0), Paint()..color = Colors.black87);
  }

  void _drawParrot(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    final r  = size.width * 0.36;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.15), width: r * 1.2, height: r * 1.6),
        Paint()..color = const Color(0xFF4CAF50));
    // Wing
    final wingPath = Path()
      ..moveTo(cx + r * 0.4, cy - r * 0.2)
      ..quadraticBezierTo(cx + r * 1.1, cy, cx + r * 0.5, cy + r * 0.7)
      ..quadraticBezierTo(cx + r * 0.2, cy + r * 0.5, cx + r * 0.4, cy - r * 0.2)
      ..close();
    canvas.drawPath(wingPath, Paint()..color = const Color(0xFF2E7D32));
    // Head
    canvas.drawCircle(Offset(cx - r * 0.05, cy - r * 0.65), r * 0.55, Paint()..color = const Color(0xFF4CAF50));
    // Eye
    canvas.drawCircle(Offset(cx + r * 0.1, cy - r * 0.72), r * 0.13, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + r * 0.1, cy - r * 0.72), r * 0.07, Paint()..color = Colors.black87);
    // Beak
    final beakPath = Path()
      ..moveTo(cx + r * 0.2, cy - r * 0.65)
      ..lineTo(cx + r * 0.55, cy - r * 0.55)
      ..lineTo(cx + r * 0.2, cy - r * 0.5)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = AppColors.accent);
    // Tail feathers
    for (int i = -1; i <= 1; i++) {
      final tailPath = Path()
        ..moveTo(cx + i * r * 0.18, cy + r * 0.9)
        ..quadraticBezierTo(cx + i * r * 0.35, cy + r * 1.3, cx + i * r * 0.28, cy + r * 1.55);
      canvas.drawPath(tailPath,
          Paint()..color = const Color(0xFFFF6B6B)..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round);
    }
  }

  void _drawPenguin(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    final r  = size.width * 0.36;
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.1), width: r * 1.2, height: r * 1.7),
        Paint()..color = const Color(0xFF1A237E));
    // Belly
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.2), width: r * 0.7, height: r * 1.1),
        Paint()..color = Colors.white);
    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.65), r * 0.52, Paint()..color = const Color(0xFF1A237E));
    // Face white patch
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.62), width: r * 0.7, height: r * 0.6),
        Paint()..color = Colors.white);
    // Eyes
    canvas.drawCircle(Offset(cx - r * 0.15, cy - r * 0.72), r * 0.1, Paint()..color = Colors.black87);
    canvas.drawCircle(Offset(cx + r * 0.15, cy - r * 0.72), r * 0.1, Paint()..color = Colors.black87);
    // Beak
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.52), width: r * 0.25, height: r * 0.14),
        Paint()..color = AppColors.accentOrange);
    // Flippers
    for (final dx in [-r * 0.7, r * 0.7]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + dx, cy + r * 0.05), width: r * 0.32, height: r * 0.8),
        Paint()..color = const Color(0xFF283593),
      );
    }
  }

  void _drawPeacock(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height * 0.6;
    final r  = size.width * 0.28;
    // Fan feathers
    for (int i = 0; i < 7; i++) {
      final angle = -math.pi * 0.8 + i * math.pi * 0.8 / 6 + math.pi / 2;
      final tipX  = cx + (r * 2.2) * math.cos(angle);
      final tipY  = cy + (r * 2.2) * math.sin(angle) - r * 1.5;
      final colors = [AppColors.secondary, AppColors.accentGreen, AppColors.primary];
      canvas.drawLine(Offset(cx, cy - r), Offset(tipX, tipY),
          Paint()..color = colors[i % 3].withOpacity(0.7)..strokeWidth = 5..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(tipX, tipY), r * 0.3,
          Paint()..color = colors[(i + 1) % 3].withOpacity(0.85));
    }
    // Body
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.2, height: r * 1.6),
        Paint()..color = const Color(0xFF1565C0));
    // Head
    canvas.drawCircle(Offset(cx, cy - r * 0.95), r * 0.42, Paint()..color = const Color(0xFF1565C0));
    // Crest
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(Offset(cx + i * r * 0.18, cy - r * 1.32),
          Offset(cx + i * r * 0.22, cy - r * 1.65),
          Paint()..color = AppColors.accentGreen..strokeWidth = 3..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(cx + i * r * 0.22, cy - r * 1.65), r * 0.1, Paint()..color = AppColors.accent);
    }
    // Eye & beak
    canvas.drawCircle(Offset(cx + r * 0.12, cy - r * 0.98), r * 0.1, Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.28, cy - r * 0.85), width: r * 0.3, height: r * 0.14),
        Paint()..color = AppColors.accentOrange);
  }

  @override
  bool shouldRepaint(_AnimalPainter old) => old.index != index;
}

// ── Celebration star ───────────────────────────────────────────────────────────

class _CelebrationStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r1 = size.width * 0.42;
    final r2 = size.width * 0.20;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? r1 : r2;
      final angle = i * math.pi / 5 - math.pi / 2;
      final pt = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = AppColors.accent
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawPath(path, Paint()..color = AppColors.accent);
    canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.round, required this.total, required this.onBack});
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
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.white70),
                  SizedBox(width: 4),
                  Text('Home', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
          const Spacer(),
          const Text('Echo the Animal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${round + 1} / $total',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
