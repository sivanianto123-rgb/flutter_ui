import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/milestone_model.dart';

/// Full-screen overlay showing child progress across four developmental pillars.
///
/// Pillar → metric mapping (derived from recent [BabyDevelopment] sessions):
///   Vocalization — average vocalizationQuality  (STT phoneme score)
///   Fine Motor   — average motorPrecision       (correct/total taps on Level 3)
///   Cognitive    — average visualAttention      (normalised Level 1 dwell time)
///   Emotional    — average overallMastery       (composite of all three)
///
/// The overlay is displayed by pushing it as a full-screen route from the
/// home screen's profile icon tap.
class ParentInsightsOverlay extends StatelessWidget {
  const ParentInsightsOverlay({
    super.key,
    required this.sessions,
    required this.childName,
    required this.onClose,
  });

  final List<BabyDevelopment> sessions;
  final String childName;
  final VoidCallback onClose;

  // ── Metric derivation ──────────────────────────────────────────────────────

  double _avg(double Function(BabyDevelopment) f) {
    if (sessions.isEmpty) return 0.0;
    final recent = sessions.take(10);
    return (recent.fold(0.0, (s, d) => s + f(d)) / recent.length)
        .clamp(0.0, 1.0);
  }

  double get _vocalization => _avg((d) => d.vocalizationQuality);
  double get _fineMotor    => _avg((d) => d.motorPrecision);
  double get _cognitive    => _avg((d) => d.visualAttention);
  double get _emotional    => _avg((d) => d.overallMastery);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sessionCount = sessions.length;

    return Material(
      color: Colors.black.withAlpha(185),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
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
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sessionCount == 0
                              ? 'No sessions yet — start learning!'
                              : 'From $sessionCount recent session${sessionCount > 1 ? 's' : ''}',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(28),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Four pillar grid ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount:   2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing:  16,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _PillarCard(
                      label:       'Vocalization',
                      icon:        Icons.mic_rounded,
                      color:       AppColors.primary,
                      value:       _vocalization,
                      description: 'Sound accuracy & clarity',
                      delay:       0,
                    ),
                    _PillarCard(
                      label:       'Fine Motor',
                      icon:        Icons.pan_tool_alt_rounded,
                      color:       AppColors.secondary,
                      value:       _fineMotor,
                      description: 'Tap precision & control',
                      delay:       100,
                    ),
                    _PillarCard(
                      label:       'Cognitive',
                      icon:        Icons.psychology_rounded,
                      color:       AppColors.accent,
                      value:       _cognitive,
                      description: 'Focus & attention span',
                      delay:       200,
                    ),
                    _PillarCard(
                      label:       'Emotional',
                      icon:        Icons.favorite_rounded,
                      color:       AppColors.accentPurple,
                      value:       _emotional,
                      description: 'Engagement & joy',
                      delay:       300,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Close CTA ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withAlpha(220),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Back to Learning',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color:      Colors.white,
                      fontSize:   20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Pillar card ────────────────────────────────────────────────────────────────

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
  final double   value; // 0.0–1.0
  final String   description;
  final int      delay;

  String get _pct => '${(value * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        color.withAlpha(22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withAlpha(70), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular arc progress indicator.
          SizedBox(
            width:  72,
            height: 72,
            child: CustomPaint(
              painter: _ArcPainter(value: value, color: color),
              child: Center(
                child: Icon(icon, color: color, size: 26),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _pct,
            style: AppTextStyles.headlineMedium.copyWith(
              color:      Colors.white,
              fontWeight: FontWeight.w800,
              fontSize:   24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color:      Colors.white,
              fontWeight: FontWeight.w700,
              fontSize:   15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color:    Colors.white60,
              fontSize: 11,
              height:   1.3,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.18, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

// ── Arc painter ────────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.value, required this.color});

  final double value;
  final Color  color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Track.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color       = color.withAlpha(40),
    );

    // Filled arc.
    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,       // start at 12 o'clock
        2 * math.pi * value, // clockwise sweep
        false,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap   = StrokeCap.round
          ..color       = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.value != value;
}
