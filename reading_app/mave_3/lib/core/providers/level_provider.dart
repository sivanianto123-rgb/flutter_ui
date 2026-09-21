import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_activity.dart';

enum ActivityStatus { locked, available, inProgress, mastered }

class ActivityScore {
  const ActivityScore({this.sessions = const []});

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

class LevelState {
  const LevelState({required this.scores});

  final Map<String, ActivityScore> scores;

  LevelState copyWith({Map<String, ActivityScore>? scores}) =>
      LevelState(scores: scores ?? this.scores);

  double accuracyFor(String activityId) => scores[activityId]?.accuracy ?? 0.0;

  ActivityStatus statusFor(GameActivity activity) {
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

  bool get comboUnlocked {
    final maMastered = GameActivity.maActivities
        .any((a) => statusFor(a) == ActivityStatus.mastered);
    final paMastered = GameActivity.paActivities
        .any((a) => statusFor(a) == ActivityStatus.mastered);
    return maMastered && paMastered;
  }

  int get masteredCount =>
      GameActivity.all.where((a) => statusFor(a) == ActivityStatus.mastered).length;
}

class LevelNotifier extends StateNotifier<LevelState> {
  LevelNotifier() : super(const LevelState(scores: {})) {
    _loadFromHive();
  }

  static const String _boxName = 'activity_scores';
  static const String _hiveKey = 'scores_v1';
  Box get _box => Hive.box(_boxName);

  void _loadFromHive() {
    final raw = _box.get(_hiveKey) as Map?;
    if (raw == null) return;
    final scores = <String, ActivityScore>{};
    raw.forEach((key, value) {
      if (value is List) {
        scores[key as String] = ActivityScore(
            sessions: value.whereType<num>().map((n) => n.toDouble()).toList());
      }
    });
    state = LevelState(scores: scores);
  }

  Future<void> _saveToHive() async {
    final raw = <String, List<double>>{};
    state.scores.forEach((id, score) { raw[id] = score.sessions; });
    await _box.put(_hiveKey, raw);
  }

  Future<void> record(String activityId, double accuracy) async {
    final existing = state.scores[activityId] ?? const ActivityScore();
    final updated  = existing.withSession(accuracy.clamp(0.0, 1.0));
    state = state.copyWith(scores: {...state.scores, activityId: updated});
    await _saveToHive();
  }

  Future<void> resetAll() async {
    state = const LevelState(scores: {});
    await _saveToHive();
  }
}

const String kActivityScoresBox = 'activity_scores';

final levelProvider =
    StateNotifierProvider<LevelNotifier, LevelState>((ref) => LevelNotifier());

final activityAccuracyProvider =
    Provider.family<double, String>((ref, activityId) =>
        ref.watch(levelProvider).accuracyFor(activityId));

final activityStatusProvider =
    Provider.family<ActivityStatus, GameActivity>((ref, activity) =>
        ref.watch(levelProvider).statusFor(activity));
