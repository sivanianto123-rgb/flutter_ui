/// A single learning session's developmental measurements.
class BabyDevelopment {
  const BabyDevelopment({
    required this.vocalizationQuality,
    required this.visualAttention,
    required this.motorPrecision,
    required this.timestamp,
    required this.syllable,
  });

  /// 0–1 score from STT confidence + phoneme overlap.
  final double vocalizationQuality;

  /// 0–1 normalised from time-on-task (capped at 120 s).
  final double visualAttention;

  /// Correct taps / total taps on the bubble-hunt level.
  final double motorPrecision;

  final DateTime timestamp;

  /// Which phoneme was being learned ('ma', 'pa', etc.).
  final String syllable;

  double get overallMastery =>
      (vocalizationQuality + visualAttention + motorPrecision) / 3.0;

  Map<String, dynamic> toMap() => {
    'vocalizationQuality': vocalizationQuality,
    'visualAttention':     visualAttention,
    'motorPrecision':      motorPrecision,
    'timestamp':           timestamp.toIso8601String(),
    'syllable':            syllable,
  };

  factory BabyDevelopment.fromMap(Map<String, dynamic> map) =>
      BabyDevelopment(
        vocalizationQuality: (map['vocalizationQuality'] as num?)?.toDouble() ?? 0,
        visualAttention:     (map['visualAttention']     as num?)?.toDouble() ?? 0,
        motorPrecision:      (map['motorPrecision']      as num?)?.toDouble() ?? 0,
        timestamp:           DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
        syllable:            map['syllable'] as String? ?? '',
      );
}
