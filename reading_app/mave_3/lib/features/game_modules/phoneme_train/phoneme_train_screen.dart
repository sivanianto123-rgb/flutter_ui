import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

class PhonemeTrainScreen extends ConsumerStatefulWidget {
  const PhonemeTrainScreen({
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
  ConsumerState<PhonemeTrainScreen> createState() => _PhonemeTrainScreenState();
}

class _PhonemeTrainScreenState extends ConsumerState<PhonemeTrainScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalRounds  = 3;
  static const List<String> _distractors = ['ba', 'da', 'ta', 'na', 'sa', 'la'];

  int  _round        = 0;
  int  _firstTryOk   = 0;
  bool _firstTry     = true;
  bool _complete     = false;
  bool _chugAnimating = false;

  late List<String> _wagons;
  int?              _tappedIndex;

  late final AnimationController _chugController;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _chugController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _buildWagons();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playInstruction());
  }

  @override
  void dispose() {
    _chugController.dispose();
    super.dispose();
  }

  void _buildWagons() {
    final d = [..._distractors]..shuffle(_rng);
    _wagons = [widget.syllable, d[0], d[1]]..shuffle(_rng);
    _firstTry    = true;
    _tappedIndex = null;
  }

  int get _correctIndex => _wagons.indexOf(widget.syllable);

  Future<void> _playInstruction() async {
    if (!mounted) return;
    try {
      final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
      await ref.read(audioServiceProvider).speak('Tap the wagon that says $phonetic!');
    } catch (_) {}
  }

  Future<void> _onWagonTap(int index) async {
    if (_chugAnimating || _complete || _tappedIndex != null) return;
    setState(() => _tappedIndex = index);
    final isCorrect = index == _correctIndex;

    if (isCorrect) {
      if (_firstTry) _firstTryOk++;
      setState(() => _chugAnimating = true);
      // Animate train forward
      final target = (_round + 1) / _totalRounds;
      await _chugController.animateTo(target, curve: Curves.easeOut);
      if (!mounted) return;
      setState(() { _chugAnimating = false; });
      try { await ref.read(audioServiceProvider).speak('Choo choo! Great job!'); } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      _round++;
      if (_round >= _totalRounds) { _finish(); } else { setState(_buildWagons); _playInstruction(); }
    } else {
      _firstTry = false;
      try {
        final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
        await ref.read(audioServiceProvider).speak('Find the $phonetic wagon!');
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _tappedIndex = null);
    }
  }

  Future<void> _finish() async {
    setState(() => _complete = true);
    final accuracy = (_firstTryOk / _totalRounds).clamp(0.0, 1.0);
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);
    try { await ref.read(audioServiceProvider).speak('All aboard! The train is full!'); } catch (_) {}
    Future.delayed(const Duration(milliseconds: 1800), () { if (mounted) widget.onComplete(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A2E), Color(0xFF0D1B3E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(round: _round, total: _totalRounds, onBack: widget.onExit),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _complete
                      ? 'All aboard! Woohoo!'
                      : 'Tap the ${widget.syllable.toUpperCase()} wagon!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                  textAlign: TextAlign.center,
                ).animate(key: ValueKey(_complete)).fadeIn(duration: 300.ms),
              ),

              const SizedBox(height: 12),

              // Train display
              SizedBox(
                height: 140,
                child: AnimatedBuilder(
                  animation: _chugController,
                  builder: (ctx, _) => CustomPaint(
                    painter: _TrainPainter(
                      progress:    _chugController.value,
                      syllable:    widget.syllable,
                      complete:    _complete,
                    ),
                    size: Size(MediaQuery.of(ctx).size.width, 140),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (!_complete) ...[
                const Text('Choose the right wagon:',
                    style: TextStyle(color: Colors.white60, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_wagons.length, (i) {
                    final isCorrect = i == _correctIndex;
                    final isTapped  = _tappedIndex == i;
                    return _WagonTile(
                      syllable:  _wagons[i],
                      isCorrect: isCorrect,
                      isTapped:  isTapped,
                      onTap:     () => _onWagonTap(i),
                    );
                  }),
                ),
              ],

              if (_complete) ...[
                const SizedBox(height: 16),
                const Icon(Icons.stars_rounded, size: 80, color: AppColors.accent)
                    .animate().scale(begin: const Offset(0.2, 0.2), duration: 600.ms, curve: Curves.elasticOut),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Wagon tile ─────────────────────────────────────────────────────────────────

class _WagonTile extends StatelessWidget {
  const _WagonTile({required this.syllable, required this.isCorrect, required this.isTapped, required this.onTap});
  final String       syllable;
  final bool         isCorrect;
  final bool         isTapped;
  final VoidCallback onTap;

  static const Map<String, Color> _colors = {
    'ma': AppColors.primary,
    'pa': AppColors.secondary,
  };

  @override
  Widget build(BuildContext context) {
    final baseColor = _colors[syllable] ?? AppColors.accentPurple;
    Color bgColor   = baseColor.withOpacity(0.25);
    Color border    = baseColor;

    if (isTapped) {
      bgColor = isCorrect ? AppColors.accentGreen.withOpacity(0.3) : Colors.red.withOpacity(0.2);
      border  = isCorrect ? AppColors.accentGreen : Colors.red;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 95, height: 95,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 3),
          boxShadow: [BoxShadow(color: border.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 40, height: 40, child: CustomPaint(painter: _SmallWagonPainter(color: baseColor))),
            const SizedBox(height: 4),
            Text(syllable.toUpperCase(),
                style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900,
                  color: isTapped && isCorrect ? AppColors.accentGreen
                       : isTapped ? Colors.red.shade300
                       : Colors.white,
                )),
          ],
        ),
      ),
    );
  }
}

// ── CustomPainter: Train ───────────────────────────────────────────────────────

class _TrainPainter extends CustomPainter {
  const _TrainPainter({required this.progress, required this.syllable, required this.complete});
  final double progress;
  final String syllable;
  final bool   complete;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Track
    final trackPaint = Paint()..color = Colors.white.withOpacity(0.2)..strokeWidth = 6;
    canvas.drawLine(Offset(0, h * 0.75), Offset(w, h * 0.75), trackPaint);
    // Track ties
    for (int i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(w * i / 10 + 20, h * 0.72),
        Offset(w * i / 10 + 20, h * 0.78),
        Paint()..color = Colors.white.withOpacity(0.15)..strokeWidth = 3,
      );
    }

    // Train offset X
    final trainX = w * 0.05 + (w * 0.6) * progress;

    // Steam puffs
    if (progress > 0 && progress < 0.95) {
      for (int i = 0; i < 3; i++) {
        final puffX = trainX + 60 + i * 18.0;
        final puffY = h * 0.22 - i * 12.0;
        final puffR = 8.0 + i * 4.0;
        canvas.drawCircle(Offset(puffX, puffY), puffR,
            Paint()..color = Colors.white.withOpacity((1 - i * 0.3) * 0.6));
      }
    }

    // Engine body
    _drawEngine(canvas, Offset(trainX, h * 0.55), complete);

    // Wagons
    _drawWagon(canvas, Offset(trainX - 80, h * 0.6), AppColors.primary);
    _drawWagon(canvas, Offset(trainX - 155, h * 0.6), AppColors.secondary);
  }

  void _drawEngine(Canvas canvas, Offset origin, bool celebrate) {
    final color = celebrate ? AppColors.accentGreen : const Color(0xFFE53935);
    // Main body
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx, origin.dy - 28, 72, 40), const Radius.circular(6)),
      Paint()..color = color,
    );
    // Cab
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx + 4, origin.dy - 42, 30, 20), const Radius.circular(4)),
      Paint()..color = color.withOpacity(0.8),
    );
    // Chimney
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx + 52, origin.dy - 44, 12, 18), const Radius.circular(3)),
      Paint()..color = const Color(0xFF37474F),
    );
    // Window
    canvas.drawOval(
      Rect.fromCenter(center: Offset(origin.dx + 14, origin.dy - 32), width: 16, height: 14),
      Paint()..color = Colors.lightBlue.withOpacity(0.7),
    );
    // Wheels
    for (final dx in [12.0, 38.0, 60.0]) {
      canvas.drawCircle(Offset(origin.dx + dx, origin.dy + 14), 12, Paint()..color = const Color(0xFF37474F));
      canvas.drawCircle(Offset(origin.dx + dx, origin.dy + 14), 6, Paint()..color = Colors.white.withOpacity(0.3));
    }
    // Cowcatcher
    final catcherPath = Path()
      ..moveTo(origin.dx, origin.dy - 2)
      ..lineTo(origin.dx - 18, origin.dy + 12)
      ..lineTo(origin.dx, origin.dy + 12)
      ..close();
    canvas.drawPath(catcherPath, Paint()..color = const Color(0xFF757575));
  }

  void _drawWagon(Canvas canvas, Offset origin, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(origin.dx, origin.dy - 22, 65, 34), const Radius.circular(5)),
      Paint()..color = color.withOpacity(0.8),
    );
    // Wheels
    for (final dx in [10.0, 48.0]) {
      canvas.drawCircle(Offset(origin.dx + dx, origin.dy + 14), 10, Paint()..color = const Color(0xFF37474F));
      canvas.drawCircle(Offset(origin.dx + dx, origin.dy + 14), 5, Paint()..color = Colors.white.withOpacity(0.3));
    }
    // Coupler
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + 62, origin.dy - 2, 10, 6),
      Paint()..color = Colors.grey.shade600,
    );
  }

  @override
  bool shouldRepaint(_TrainPainter old) => old.progress != progress || old.complete != complete;
}

class _SmallWagonPainter extends CustomPainter {
  const _SmallWagonPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h * 0.6), const Radius.circular(4)),
      Paint()..color = color.withOpacity(0.7),
    );
    for (final dx in [w * 0.18, w * 0.72]) {
      canvas.drawCircle(Offset(dx, h * 0.82), h * 0.18, Paint()..color = const Color(0xFF37474F));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.round, required this.total, required this.onBack});
  final int round; final int total; final VoidCallback onBack;

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
          const Text('Phoneme Train', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${round + 1} / $total',
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
