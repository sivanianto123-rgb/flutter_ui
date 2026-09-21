import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _DoorRound {
  const _DoorRound({required this.doors, required this.correctIndex});
  final List<_DoorItem> doors;
  final int             correctIndex;
}

class _DoorItem {
  const _DoorItem({required this.label, required this.painterIndex});
  final String label;
  final int    painterIndex;
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class WhosBehindDoorScreen extends ConsumerStatefulWidget {
  const WhosBehindDoorScreen({
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
  ConsumerState<WhosBehindDoorScreen> createState() => _WhosBehindDoorScreenState();
}

class _WhosBehindDoorScreenState extends ConsumerState<WhosBehindDoorScreen> {
  // Painter indices 0-5: 0=Bear,1=Cat,2=Rabbit,3=Owl,4=Fish,5=Star
  static const _maRounds = [
    _DoorRound(doors: [
      _DoorItem(label: 'Monkey', painterIndex: 1),
      _DoorItem(label: 'Lion',   painterIndex: 4),
      _DoorItem(label: 'Fish',   painterIndex: 4),
    ], correctIndex: 0),
    _DoorRound(doors: [
      _DoorItem(label: 'Dog',      painterIndex: 2),
      _DoorItem(label: 'Moon',     painterIndex: 5),
      _DoorItem(label: 'Frog',     painterIndex: 4),
    ], correctIndex: 1),
    _DoorRound(doors: [
      _DoorItem(label: 'Cat',      painterIndex: 1),
      _DoorItem(label: 'Rainbow',  painterIndex: 5),
      _DoorItem(label: 'Mountain', painterIndex: 0),
    ], correctIndex: 2),
  ];

  static const _paRounds = [
    _DoorRound(doors: [
      _DoorItem(label: 'Parrot', painterIndex: 3),
      _DoorItem(label: 'Whale',  painterIndex: 4),
      _DoorItem(label: 'Fox',    painterIndex: 2),
    ], correctIndex: 0),
    _DoorRound(doors: [
      _DoorItem(label: 'Mouse',    painterIndex: 2),
      _DoorItem(label: 'Pizza',    painterIndex: 5),
      _DoorItem(label: 'Butterfly',painterIndex: 3),
    ], correctIndex: 1),
    _DoorRound(doors: [
      _DoorItem(label: 'Octopus', painterIndex: 4),
      _DoorItem(label: 'Frog',    painterIndex: 0),
      _DoorItem(label: 'Panda',   painterIndex: 0),
    ], correctIndex: 2),
  ];

  int  _round        = 0;
  int  _firstTryOk   = 0;
  bool _firstTry     = true;
  bool _complete     = false;
  int? _openedDoor;
  bool _showingResult = false;

  final _rng = math.Random();
  late List<_DoorRound> _rounds;

  @override
  void initState() {
    super.initState();
    _rounds = (widget.syllable == 'ma' ? _maRounds : _paRounds).toList()..shuffle(_rng);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playInstruction());
  }

  _DoorRound get _current => _rounds[_round % _rounds.length];

  Future<void> _playInstruction() async {
    if (!mounted) return;
    try {
      final phonetic = PhoneticHelper.toPhonetic(widget.syllable);
      await ref.read(audioServiceProvider).speak('Which one starts with $phonetic? Tap to find out!');
    } catch (_) {}
  }

  Future<void> _onDoorTap(int index) async {
    if (_showingResult || _complete) return;
    setState(() { _openedDoor = index; _showingResult = true; });
    final isCorrect = index == _current.correctIndex;

    if (isCorrect) {
      if (_firstTry) _firstTryOk++;
      try {
        await ref.read(audioServiceProvider).speak(
            '${_current.doors[index].label}! That starts with ${PhoneticHelper.toPhonetic(widget.syllable)}!');
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      _nextRound();
    } else {
      _firstTry = false;
      try { await ref.read(audioServiceProvider).speak('Try another door!'); } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() { _openedDoor = null; _showingResult = false; });
    }
  }

  void _nextRound() {
    _round++;
    if (_round >= 3) {
      _finish();
    } else {
      setState(() { _openedDoor = null; _showingResult = false; _firstTry = true; });
      _playInstruction();
    }
  }

  Future<void> _finish() async {
    setState(() => _complete = true);
    final accuracy = (_firstTryOk / 3).clamp(0.0, 1.0);
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);
    try { await ref.read(audioServiceProvider).speak('You found them all! Amazing!'); } catch (_) {}
    Future.delayed(const Duration(milliseconds: 1800), () { if (mounted) widget.onComplete(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A2E), Color(0xFF2D1B55)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(round: _round, total: 3, onBack: widget.onExit),
              const Spacer(),

              if (_complete) ...[
                const Icon(Icons.star_rounded, size: 100, color: AppColors.accent)
                    .animate().scale(begin: const Offset(0.3, 0.3), duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                const Text('You found them all!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.accentGreen),
                    textAlign: TextAlign.center),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Tap the door that hides the ${PhoneticHelper.toPhonetic(widget.syllable)} sound!',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (i) => _DoorTile(
                    item:      _current.doors[i],
                    index:     i,
                    isOpen:    _openedDoor == i,
                    isCorrect: i == _current.correctIndex,
                    onTap:     () => _onDoorTap(i),
                  )),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _playInstruction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded, color: AppColors.secondary, size: 22),
                        SizedBox(width: 8),
                        Text('Hear it again', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Door tile ─────────────────────────────────────────────────────────────────

class _DoorTile extends StatelessWidget {
  const _DoorTile({
    required this.item, required this.index, required this.isOpen,
    required this.isCorrect, required this.onTap,
  });
  final _DoorItem    item;
  final int          index;
  final bool         isOpen;
  final bool         isCorrect;
  final VoidCallback onTap;

  static const List<Color> _doorColors = [
    Color(0xFF5C6BC0), Color(0xFF26A69A), Color(0xFFEF6C00),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _doorColors[index % _doorColors.length];
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100, height: 160,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: isOpen
              ? _OpenDoor(key: const ValueKey('open'), item: item, isCorrect: isCorrect)
              : _ClosedDoor(key: const ValueKey('closed'), color: color, doorNumber: index + 1),
        ),
      ),
    );
  }
}

class _ClosedDoor extends StatelessWidget {
  const _ClosedDoor({super.key, required this.color, required this.doorNumber});
  final Color color;
  final int   doorNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Drawn door
          SizedBox(width: 56, height: 80, child: CustomPaint(painter: _DoorPainter(color: color))),
          const SizedBox(height: 8),
          Text('$doorNumber', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }
}

class _OpenDoor extends StatelessWidget {
  const _OpenDoor({super.key, required this.item, required this.isCorrect});
  final _DoorItem item;
  final bool      isCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.accentGreen.withOpacity(0.2) : Colors.red.withOpacity(0.15),
        border: Border.all(
          color: isCorrect ? AppColors.accentGreen : Colors.red,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 72, height: 72,
            child: CustomPaint(painter: _RevealPainter(index: item.painterIndex, isCorrect: isCorrect)),
          ).animate().scale(begin: const Offset(0.4, 0.4), duration: 350.ms, curve: Curves.elasticOut),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: TextStyle(
              color: isCorrect ? AppColors.accentGreen : Colors.red.shade300,
              fontWeight: FontWeight.w700, fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Painters ───────────────────────────────────────────────────────────────────

class _DoorPainter extends CustomPainter {
  const _DoorPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final border = Paint()..color = Colors.white.withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 3;
    final fill   = Paint()..color = color.withOpacity(0.3);
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(4, 0, w - 8, h - 4), const Radius.circular(8));
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, border);
    // Door knob
    canvas.drawCircle(Offset(w * 0.72, h * 0.55), 5, Paint()..color = Colors.white.withOpacity(0.8));
    // Door panels
    canvas.drawRect(Rect.fromLTWH(10, 8, w - 20, h * 0.38), border..strokeWidth = 1.5);
    canvas.drawRect(Rect.fromLTWH(10, h * 0.48, w - 20, h * 0.38), border..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RevealPainter extends CustomPainter {
  const _RevealPainter({required this.index, required this.isCorrect});
  final int  index;
  final bool isCorrect;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; final cy = size.height / 2;
    final r  = size.width * 0.38;
    final color = isCorrect ? AppColors.accentGreen : Colors.red.shade400;

    // Draw based on index 0-5
    switch (index % 6) {
      case 0: // Bear
        canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFF8D6E63));
        for (final dx in [-r * 0.55, r * 0.55]) {
          canvas.drawCircle(Offset(cx + dx, cy - r * 0.7), r * 0.3, Paint()..color = const Color(0xFF6D4C41));
        }
        canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.15), r * 0.12, Paint()..color = Colors.black87);
        canvas.drawCircle(Offset(cx + r * 0.25, cy - r * 0.15), r * 0.12, Paint()..color = Colors.black87);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.18), width: r * 0.4, height: r * 0.28),
            Paint()..color = const Color(0xFFBCAAA4));
        break;
      case 1: // Cat
        canvas.drawCircle(Offset(cx, cy), r, Paint()..color = AppColors.accentOrange);
        for (final dx in [-r * 0.52, r * 0.52]) {
          final tri = Path()
            ..moveTo(cx + dx, cy - r * 0.6)
            ..lineTo(cx + dx - r * 0.2, cy - r * 0.95)
            ..lineTo(cx + dx + r * 0.2, cy - r * 0.95)
            ..close();
          canvas.drawPath(tri, Paint()..color = AppColors.accentOrange);
        }
        canvas.drawCircle(Offset(cx - r * 0.22, cy - r * 0.12), r * 0.13, Paint()..color = Colors.black87);
        canvas.drawCircle(Offset(cx + r * 0.22, cy - r * 0.12), r * 0.13, Paint()..color = Colors.black87);
        break;
      case 2: // Rabbit
        canvas.drawCircle(Offset(cx, cy + r * 0.1), r * 0.8, Paint()..color = Colors.white);
        for (final dx in [-r * 0.3, r * 0.3]) {
          canvas.drawOval(Rect.fromCenter(center: Offset(cx + dx, cy - r * 0.95), width: r * 0.28, height: r * 0.55),
              Paint()..color = Colors.white);
          canvas.drawOval(Rect.fromCenter(center: Offset(cx + dx, cy - r * 0.95), width: r * 0.14, height: r * 0.38),
              Paint()..color = const Color(0xFFFFB6C1));
        }
        canvas.drawCircle(Offset(cx - r * 0.2, cy - r * 0.1), r * 0.1, Paint()..color = Colors.black87);
        canvas.drawCircle(Offset(cx + r * 0.2, cy - r * 0.1), r * 0.1, Paint()..color = Colors.black87);
        canvas.drawCircle(Offset(cx, cy + r * 0.1), r * 0.1, Paint()..color = const Color(0xFFFFB6C1));
        break;
      case 3: // Owl/Bird
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.4, height: r * 1.8),
            Paint()..color = const Color(0xFF4E342E));
        canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.25), r * 0.32, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx + r * 0.28, cy - r * 0.25), r * 0.32, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx - r * 0.28, cy - r * 0.25), r * 0.18, Paint()..color = Colors.black87);
        canvas.drawCircle(Offset(cx + r * 0.28, cy - r * 0.25), r * 0.18, Paint()..color = Colors.black87);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.05), width: r * 0.28, height: r * 0.22),
            Paint()..color = AppColors.accent);
        break;
      case 4: // Fish
        final bodyPath = Path()
          ..moveTo(cx - r * 0.7, cy)
          ..quadraticBezierTo(cx, cy - r * 0.55, cx + r * 0.7, cy)
          ..quadraticBezierTo(cx, cy + r * 0.55, cx - r * 0.7, cy)
          ..close();
        canvas.drawPath(bodyPath, Paint()..color = AppColors.secondary);
        final tailPath = Path()
          ..moveTo(cx + r * 0.65, cy)
          ..lineTo(cx + r * 1.1, cy - r * 0.4)
          ..lineTo(cx + r * 1.1, cy + r * 0.4)
          ..close();
        canvas.drawPath(tailPath, Paint()..color = AppColors.secondary.withOpacity(0.7));
        canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.1), r * 0.12, Paint()..color = Colors.black87);
        break;
      case 5: // Star shape
        final starPath = Path();
        for (int i = 0; i < 10; i++) {
          final angle = i * math.pi / 5 - math.pi / 2;
          final sr = i.isEven ? r * 0.88 : r * 0.42;
          final pt = Offset(cx + sr * math.cos(angle), cy + sr * math.sin(angle));
          i == 0 ? starPath.moveTo(pt.dx, pt.dy) : starPath.lineTo(pt.dx, pt.dy);
        }
        starPath.close();
        canvas.drawPath(starPath, Paint()..color = AppColors.accent);
        canvas.drawCircle(Offset(cx, cy), r * 0.28, Paint()..color = Colors.white.withOpacity(0.6));
        break;
    }

    // Correctness ring
    canvas.drawCircle(Offset(cx, cy), r + 3,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(_RevealPainter old) => old.index != index || old.isCorrect != isCorrect;
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
          const Text("Who's Behind the Door?",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.accentPurple.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
            child: Text('${round + 1} / $total',
                style: const TextStyle(color: AppColors.accentPurple, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
