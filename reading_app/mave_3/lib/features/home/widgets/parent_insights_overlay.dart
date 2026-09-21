import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/milestone_model.dart';

class ParentInsightsOverlay extends StatelessWidget {
  const ParentInsightsOverlay({
    super.key,
    required this.sessions,
    required this.childName,
    required this.onClose,
  });

  final List<BabyDevelopment> sessions;
  final String                childName;
  final VoidCallback          onClose;

  double _avg(double Function(BabyDevelopment) f) {
    if (sessions.isEmpty) return 0.0;
    final recent = sessions.take(10);
    return (recent.fold(0.0, (s, d) => s + f(d)) / recent.length).clamp(0.0, 1.0);
  }

  double get _vocalization => _avg((d) => d.vocalizationQuality);
  double get _fineMotor    => _avg((d) => d.motorPrecision);
  double get _cognitive    => _avg((d) => d.visualAttention);
  double get _emotional    => _avg((d) => d.overallMastery);

  @override
  Widget build(BuildContext context) {
    final sessionCount = sessions.length;

    return Material(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$childName's Progress",
                          style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sessionCount == 0
                              ? 'No sessions yet — start learning!'
                              : 'From $sessionCount recent session${sessionCount > 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount:   2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing:  14,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _PillarCard(label: 'Vocalization', icon: Icons.mic_rounded,          color: const Color(0xFFFF6B6B), value: _vocalization, description: 'Sound accuracy & clarity',  delay: 0),
                    _PillarCard(label: 'Fine Motor',   icon: Icons.pan_tool_alt_rounded,  color: const Color(0xFF4ECDC4), value: _fineMotor,    description: 'Tap precision & control',  delay: 100),
                    _PillarCard(label: 'Cognitive',    icon: Icons.psychology_rounded,    color: const Color(0xFFFFE66D), value: _cognitive,    description: 'Focus & attention span',   delay: 200),
                    _PillarCard(label: 'Emotional',    icon: Icons.favorite_rounded,      color: const Color(0xFFA855F7), value: _emotional,    description: 'Engagement & joy',         delay: 300),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: const Text(
                    'Back to Learning',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.description,
    required this.delay,
  });

  final String   label;
  final IconData icon;
  final Color    color;
  final double   value;
  final String   description;
  final int      delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border:       Border.all(color: color.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width:  72, height: 72,
            child: CustomPaint(
              painter: _ArcPainter(value: value, color: color),
              child: Center(child: Icon(icon, color: color, size: 26)),
            ),
          ),
          const SizedBox(height: 10),
          Text('${(value * 100).round()}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5), height: 1.3)),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.18, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.value, required this.color});
  final double value;
  final Color  color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    canvas.drawCircle(center, radius,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 5..color = color.withOpacity(0.15));

    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * value,
        false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.value != value;
}
