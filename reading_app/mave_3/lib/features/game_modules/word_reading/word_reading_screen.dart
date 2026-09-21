import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

// ── Word data ─────────────────────────────────────────────────────────────────

class _Word {
  const _Word({required this.text, required this.highlight});
  final String text;
  final String highlight;
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class WordReadingScreen extends ConsumerStatefulWidget {
  const WordReadingScreen({
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
  ConsumerState<WordReadingScreen> createState() => _WordReadingScreenState();
}

class _WordReadingScreenState extends ConsumerState<WordReadingScreen>
    with SingleTickerProviderStateMixin {
  static const _maWords = [
    _Word(text: 'MA',  highlight: 'MA'),
    _Word(text: 'MAP', highlight: 'MA'),
    _Word(text: 'MAT', highlight: 'MA'),
    _Word(text: 'MAN', highlight: 'MA'),
  ];

  static const _paWords = [
    _Word(text: 'PA',  highlight: 'PA'),
    _Word(text: 'PAN', highlight: 'PA'),
    _Word(text: 'PAT', highlight: 'PA'),
    _Word(text: 'PAD', highlight: 'PA'),
  ];

  static const int _wordsPerSession = 4;

  late final List<_Word> _words;
  int  _index        = 0;
  int  _readCount    = 0;
  bool _listening    = false;
  bool _didRead      = false;
  bool _complete     = false;
  bool _ttsPlaying   = false;
  Timer? _listenTimer;

  late final AnimationController _micPulseController;
  late final MicrophoneController _mic;

  @override
  void initState() {
    super.initState();
    _mic = ref.read(microphoneControllerProvider);
    final all = (widget.syllable == 'ma' ? _maWords : _paWords).toList()
      ..shuffle(math.Random());
    _words = all.take(_wordsPerSession).toList();

    _micPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _presentWord());
  }

  @override
  void dispose() {
    _listenTimer?.cancel();
    _micPulseController.dispose();
    _mic.stopQuietly();
    super.dispose();
  }

  _Word get _current => _words[_index];

  Future<void> _presentWord() async {
    if (!mounted) return;
    setState(() { _listening = false; _didRead = false; _ttsPlaying = true; });

    try {
      await ref.read(audioServiceProvider).speak(
          'This word is ${_current.text}. Now you say it!');
    } catch (_) {}

    if (!mounted) return;
    setState(() => _ttsPlaying = false);
    _startListening();
  }

  Future<void> _startListening() async {
    setState(() => _listening = true);
    await _mic.start();

    _listenTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted || _didRead) return;
      _onReadDetected();
    });

    Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _complete) { t.cancel(); return; }
      if (_didRead) { t.cancel(); return; }
      if (_mic.isSpeaking && _listening) { t.cancel(); _onReadDetected(); }
    });
  }

  Future<void> _onReadDetected() async {
    if (_didRead || !mounted) return;
    _listenTimer?.cancel();
    _mic.stop();
    setState(() { _didRead = true; _listening = false; _readCount++; });

    try {
      await ref.read(audioServiceProvider).speak(PhoneticHelper.praiseFor(widget.syllable));
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    _index++;
    if (_index >= _words.length) {
      _finish();
    } else {
      _presentWord();
    }
  }

  Future<void> _finish() async {
    setState(() => _complete = true);
    final accuracy = (_readCount / _words.length).clamp(0.0, 1.0);
    await ref.read(levelProvider.notifier).record(widget.activityId, accuracy);
    if (!mounted) return;
    try { await ref.read(audioServiceProvider).speak('Brilliant reading! You are a star!'); } catch (_) {}
    Future.delayed(const Duration(milliseconds: 2000), () { if (mounted) widget.onComplete(); });
  }

  @override
  Widget build(BuildContext context) {
    final mic = ref.watch(microphoneControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B3E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                progress: _words.isEmpty ? 0 : _index / _words.length,
                onBack:   widget.onExit,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  _complete
                      ? 'Brilliant reading!'
                      : _ttsPlaying ? 'Listen...' : 'Your turn!',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: _complete ? AppColors.accentGreen : Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Expanded(
                child: _complete
                    ? _CompletionView()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Word card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E2A5E), Color(0xFF2A3A7E)],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 30, spreadRadius: 4),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Word illustration
                                SizedBox(
                                  width: 100, height: 80,
                                  child: CustomPaint(painter: _WordIllustrationPainter(
                                    word: _current.text, syllable: widget.syllable,
                                  )),
                                ),
                                const SizedBox(height: 16),
                                // Highlighted word
                                _buildHighlightedWord(_current.text, _current.highlight),
                                const SizedBox(height: 8),
                                Text(
                                  '${_index + 1} of ${_words.length}',
                                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5)),
                                ),
                              ],
                            ),
                          ).animate(key: ValueKey(_index))
                              .fadeIn(duration: 300.ms)
                              .scale(begin: const Offset(0.9, 0.9), duration: 400.ms, curve: Curves.easeOut),

                          const SizedBox(height: 32),

                          // Mic indicator
                          if (_listening && !_didRead)
                            AnimatedBuilder(
                              animation: _micPulseController,
                              builder: (ctx, child) => Transform.scale(
                                scale: 1.0 + _micPulseController.value * 0.12,
                                child: child,
                              ),
                              child: Container(
                                width: 90, height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [
                                    mic.isSpeaking ? AppColors.accentGreen.withOpacity(0.85) : AppColors.primary.withOpacity(0.25),
                                    mic.isSpeaking ? AppColors.accentGreen.withOpacity(0.4) : AppColors.primary.withOpacity(0.08),
                                  ]),
                                  border: Border.all(
                                    color: mic.isSpeaking ? AppColors.accentGreen : AppColors.primary,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  mic.isSpeaking ? Icons.record_voice_over_rounded : Icons.mic_rounded,
                                  size: 44, color: Colors.white,
                                ),
                              ),
                            ),

                          if (_didRead && !_complete)
                            const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.accentGreen)
                                .animate().scale(begin: const Offset(0.3, 0.3), duration: 400.ms, curve: Curves.elasticOut),

                          if (_ttsPlaying)
                            const Icon(Icons.volume_up_rounded, size: 56, color: AppColors.secondary)
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 600.ms),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedWord(String text, String highlight) {
    final upper   = text.toUpperCase();
    final hUpper  = highlight.toUpperCase();
    final idx     = upper.indexOf(hUpper);
    if (idx < 0) {
      return Text(upper, style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 12)]));
    }
    return RichText(
      text: TextSpan(children: [
        if (idx > 0)
          TextSpan(text: upper.substring(0, idx),
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white)),
        TextSpan(text: upper.substring(idx, idx + hUpper.length),
            style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: AppColors.primary,
                shadows: [Shadow(color: AppColors.primary.withOpacity(0.6), blurRadius: 20)])),
        if (idx + hUpper.length < upper.length)
          TextSpan(text: upper.substring(idx + hUpper.length),
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white)),
      ]),
    );
  }
}

// ── Completion View ────────────────────────────────────────────────────────────

class _CompletionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 160, height: 160,
            child: CustomPaint(painter: _BookOpenPainter()),
          ).animate().scale(begin: const Offset(0.3, 0.3), duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          const Text('You are a star reader!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.accent),
              textAlign: TextAlign.center)
              .animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

// ── Custom Painters ────────────────────────────────────────────────────────────

class _WordIllustrationPainter extends CustomPainter {
  const _WordIllustrationPainter({required this.word, required this.syllable});
  final String word;
  final String syllable;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final color = syllable == 'ma' ? AppColors.primary : AppColors.secondary;

    // Draw a simple geometric shape based on word length
    switch (word.length) {
      case 2: // MA / PA — face
        canvas.drawCircle(Offset(cx, cy), size.height * 0.38, Paint()..color = color.withOpacity(0.8));
        canvas.drawCircle(Offset(cx - size.width * 0.15, cy - size.height * 0.08), size.width * 0.08, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx + size.width * 0.15, cy - size.height * 0.08), size.width * 0.08, Paint()..color = Colors.white);
        final smilePaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
        canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + size.height * 0.08), width: size.width * 0.28, height: size.height * 0.2),
            0, math.pi, false, smilePaint);
        break;
      case 3: // MAP/MAT/MAN/PAN/PAT/PAD
        // Diamond
        final path = Path()
          ..moveTo(cx, cy - size.height * 0.38)
          ..lineTo(cx + size.width * 0.38, cy)
          ..lineTo(cx, cy + size.height * 0.38)
          ..lineTo(cx - size.width * 0.38, cy)
          ..close();
        canvas.drawPath(path, Paint()..color = color.withOpacity(0.8));
        canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5);
        break;
    }
  }

  @override
  bool shouldRepaint(_WordIllustrationPainter old) => old.word != word;
}

class _BookOpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w  = size.width * 0.45;
    final h  = size.height * 0.55;

    // Left page
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - w - 4, cy - h / 2, w, h), const Radius.circular(4)),
      Paint()..color = const Color(0xFFFFF8E7),
    );
    // Right page
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 4, cy - h / 2, w, h), const Radius.circular(4)),
      Paint()..color = const Color(0xFFFFF3D0),
    );
    // Spine
    canvas.drawRect(Rect.fromLTWH(cx - 4, cy - h / 2, 8, h), Paint()..color = AppColors.primary);

    // Lines on pages
    final linePaint = Paint()..color = Colors.brown.shade200..strokeWidth = 1.5;
    for (int i = 1; i <= 4; i++) {
      final y = cy - h / 2 + h * i / 5;
      canvas.drawLine(Offset(cx - w + 8, y), Offset(cx - 10, y), linePaint);
      canvas.drawLine(Offset(cx + 10, y), Offset(cx + w - 8, y), linePaint);
    }

    // Star on right page
    final starPath = Path();
    const r1 = 18.0; const r2 = 8.0;
    for (int i = 0; i < 10; i++) {
      final r     = i.isEven ? r1 : r2;
      final angle = i * math.pi / 5 - math.pi / 2;
      final pt    = Offset(cx + w / 2, cy);
      final ptFinal = Offset(pt.dx + r * math.cos(angle), pt.dy + r * math.sin(angle));
      i == 0 ? starPath.moveTo(ptFinal.dx, ptFinal.dy) : starPath.lineTo(ptFinal.dx, ptFinal.dy);
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, required this.onBack});
  final double       progress;
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
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                builder: (ctx, v, _) => LinearProgressIndicator(
                  value: v, minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
