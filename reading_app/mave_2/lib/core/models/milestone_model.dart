/// Developmental milestone snapshot for a single Mave session.
///
/// Three measurable pillars:
///   vocalizationQuality — how closely the baby's sound matched the target syllable (0–1)
///   visualAttention     — normalised engagement time on Level 1 (seconds / 120 s capped at 1)
///   motorPrecision      — correct bubble taps / total taps on Level 3 (0–1)
///
/// [overallMastery] is the equal-weight average of all three pillars.
///
/// Storage:
///   Hive  — [toMap] / [fromMap] with ISO-8601 timestamp string
///   Firestore — [toFirestoreMap] writes a native Timestamp instead of string
class BabyDevelopment {
  const BabyDevelopment({
    required this.vocalizationQuality,
    required this.visualAttention,
    required this.motorPrecision,
    required this.timestamp,
    required this.syllable,
  });

  /// 0.0–1.0. Derived from STT confidence + phoneme overlap scoring.
  final double vocalizationQuality;

  /// 0.0–1.0. Derived from seconds spent engaged on Level 1, capped at 120 s.
  final double visualAttention;

  /// 0.0–1.0. correctTargetTaps / totalTaps on Level 3.
  final double motorPrecision;

  /// Wall-clock time of the session.
  final DateTime timestamp;

  /// The syllable being practised (e.g. "ma").
  final String syllable;

  /// Equal-weight composite across all three developmental pillars.
  double get overallMastery =>
      ((vocalizationQuality + visualAttention + motorPrecision) / 3.0)
          .clamp(0.0, 1.0);

  // ── Hive serialisation (timestamp as ISO-8601 string) ─────────────────────

  Map<String, dynamic> toMap() => {
        'vocalizationQuality': vocalizationQuality,
        'visualAttention': visualAttention,
        'motorPrecision': motorPrecision,
        'timestamp': timestamp.toIso8601String(),
        'syllable': syllable,
      };

  factory BabyDevelopment.fromMap(Map<String, dynamic> map) => BabyDevelopment(
        vocalizationQuality:
            (map['vocalizationQuality'] as num? ?? 0).toDouble(),
        visualAttention: (map['visualAttention'] as num? ?? 0).toDouble(),
        motorPrecision: (map['motorPrecision'] as num? ?? 0).toDouble(),
        timestamp: _parseTimestamp(map['timestamp']),
        syllable: map['syllable'] as String? ?? '',
      );

  static DateTime _parseTimestamp(dynamic value) {
    if (value is String) return DateTime.parse(value);
    // Firestore Timestamp handled externally in DataService before fromMap is called.
    return DateTime.now();
  }
}
