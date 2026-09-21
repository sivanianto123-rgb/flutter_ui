import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_activity.dart';

// ── Activity status ───────────────────────────────────────────────────────────

enum ActivityStatus { locked, available, inProgress, mastered }

// ── Per-activity score record ─────────────────────────────────────────────────

class ActivityScore {
  const ActivityScore({
    this.sessions = const [],
  });

  /// Rolling window of the last [_maxSessions] accuracy values (0–1).
  final List<double> sessions;

  static const int _maxSessions = 5;

  double get accuracy =>
      sessions.isEmpty ? 0.0 : sessions.reduce((a, b) => a + b) / sessions.length;

  ActivityScore withSession(double value) {
    final updated = [...sessions, value];
    return ActivityScore(
      sessions: updated.length > _maxSessions
          ? updated.sublist(updated.length - _maxSessions)
          : updated,
    );
  }
}

// ── State ─────────────────────────────────────────────────────────────────────

class LevelState {
  const LevelState({required this.scores});

  /// Map from [GameActivity.id] → [ActivityScore].
  final Map<String, ActivityScore> scores;

  LevelState copyWith({Map<String, ActivityScore>? scores}) =>
      LevelState(scores: scores ?? this.scores);

  // ── Queries ────────────────────────────────────────────────────────────────

  double accuracyFor(String activityId) =>
      scores[activityId]?.accuracy ?? 0.0;

  ActivityStatus statusFor(GameActivity activity) {
    // Prerequisites must all be mastered.
    for (final prereqId in activity.prerequisites) {
      final prereq = GameActivity.byId(prereqId);
      if (prereq == null) continue;
      if (accuracyFor(prereqId) < prereq.unlockThreshold) {
        return ActivityStatus.locked;
      }
    }

    final acc = accuracyFor(activity.id);
    if (acc >= activity.unlockThreshold) return ActivityStatus.mastered;
    if (acc > 0.0) return ActivityStatus.inProgress;
    return ActivityStatus.available;
  }

  List<GameActivity> get availableActivities =>
      GameActivity.all.where((a) {
        final s = statusFor(a);
        return s == ActivityStatus.available || s == ActivityStatus.inProgress;
      }).toList();

  bool get comboUnlocked {
    // Combo unlocks when at least one Ma activity and one Pa activity are mastered.
    final maMastered = GameActivity.maActivities
        .any((a) => statusFor(a) == ActivityStatus.mastered);
    final paMastered = GameActivity.paActivities
        .any((a) => statusFor(a) == ActivityStatus.mastered);
    return maMastered && paMastered;
  }

  int get masteredCount =>
      GameActivity.all.where((a) => statusFor(a) == ActivityStatus.mastered).length;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class LevelNotifier extends StateNotifier<LevelState> {
  LevelNotifier() : super(const LevelState(scores: {})) {
    _loadFromHive();
  }

  static const String _boxName  = 'activity_scores';
  static const String _hiveKey  = 'scores_v1';

  Box get _box => Hive.box(_boxName);

  // ── Persistence ────────────────────────────────────────────────────────────

  void _loadFromHive() {
    final raw = _box.get(_hiveKey) as Map?;
    if (raw == null) return;

    final scores = <String, ActivityScore>{};
    raw.forEach((key, value) {
      if (value is List) {
        final sessions = value
            .whereType<num>()
            .map((n) => n.toDouble())
            .toList();
        scores[key as String] = ActivityScore(sessions: sessions);
      }
    });
    state = LevelState(scores: scores);
  }

  Future<void> _saveToHive() async {
    final raw = <String, List<double>>{};
    state.scores.forEach((id, score) {
      raw[id] = score.sessions;
    });
    await _box.put(_hiveKey, raw);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Records an accuracy result for [activityId].
  Future<void> record(String activityId, double accuracy) async {
    final existing = state.scores[activityId] ?? const ActivityScore();
    final updated  = existing.withSession(accuracy.clamp(0.0, 1.0));
    state = state.copyWith(
      scores: {...state.scores, activityId: updated},
    );
    await _saveToHive();
  }

  /// Resets progress for a single activity (dev helper).
  Future<void> reset(String activityId) async {
    final updated = Map<String, ActivityScore>.from(state.scores)
      ..remove(activityId);
    state = state.copyWith(scores: updated);
    await _saveToHive();
  }

  /// Resets all progress (dev helper).
  Future<void> resetAll() async {
    state = const LevelState(scores: {});
    await _saveToHive();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Requires `await Hive.openBox(LevelNotifier._boxName)` in main().
/// Exposed as `activity_scores` Hive box name via [kActivityScoresBox].
const String kActivityScoresBox = 'activity_scores';

final levelProvider =
    StateNotifierProvider<LevelNotifier, LevelState>((ref) {
  return LevelNotifier();
});

/// Convenience: accuracy for a single activity ID.
final activityAccuracyProvider =
    Provider.family<double, String>((ref, activityId) {
  return ref.watch(levelProvider).accuracyFor(activityId);
});

/// Convenience: status for a single activity.
final activityStatusProvider =
    Provider.family<ActivityStatus, GameActivity>((ref, activity) {
  return ref.watch(levelProvider).statusFor(activity);
});
