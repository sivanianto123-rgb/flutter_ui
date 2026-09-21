import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';

class ChildPerformance {
  const ChildPerformance({
    this.readingSessions = 0,
    this.bubbleCorrect = 0,
    this.bubbleTargetTotal = 0,
    this.storySessions = 0,
    this.phonicsSuccesses = 0,
    this.vowelZoneComplete = false,
    this.consonantZoneComplete = false,
    this.wordCorrect = 0,
    this.wordTotal = 0,
    this.sentenceCorrect = 0,
    this.sentenceTotal = 0,
  });

  final int readingSessions;
  final int bubbleCorrect;
  final int bubbleTargetTotal;
  final int storySessions;
  final int phonicsSuccesses;
  final bool vowelZoneComplete;
  final bool consonantZoneComplete;
  final int wordCorrect;
  final int wordTotal;
  final int sentenceCorrect;
  final int sentenceTotal;

  ChildPerformance copyWith({
    int? readingSessions,
    int? bubbleCorrect,
    int? bubbleTargetTotal,
    int? storySessions,
    int? phonicsSuccesses,
    bool? vowelZoneComplete,
    bool? consonantZoneComplete,
    int? wordCorrect,
    int? wordTotal,
    int? sentenceCorrect,
    int? sentenceTotal,
  }) {
    return ChildPerformance(
      readingSessions: readingSessions ?? this.readingSessions,
      bubbleCorrect: bubbleCorrect ?? this.bubbleCorrect,
      bubbleTargetTotal: bubbleTargetTotal ?? this.bubbleTargetTotal,
      storySessions: storySessions ?? this.storySessions,
      phonicsSuccesses: phonicsSuccesses ?? this.phonicsSuccesses,
      vowelZoneComplete: vowelZoneComplete ?? this.vowelZoneComplete,
      consonantZoneComplete: consonantZoneComplete ?? this.consonantZoneComplete,
      wordCorrect: wordCorrect ?? this.wordCorrect,
      wordTotal: wordTotal ?? this.wordTotal,
      sentenceCorrect: sentenceCorrect ?? this.sentenceCorrect,
      sentenceTotal: sentenceTotal ?? this.sentenceTotal,
    );
  }

  double get soundAccuracy {
    if (bubbleTargetTotal <= 0) return 0;
    return (bubbleCorrect / bubbleTargetTotal).clamp(0.0, 1.0);
  }

  double get readingSkill {
    return (readingSessions / 12).clamp(0.0, 1.0);
  }

  double get listeningSkill {
    return (storySessions / 10).clamp(0.0, 1.0);
  }

  double get overallProgress {
    final avg = (readingSkill +
            soundAccuracy +
            listeningSkill +
            wordAccuracy +
            sentenceAccuracy) /
        5;
    return avg.clamp(0.0, 1.0);
  }

  double get wordAccuracy {
    if (wordTotal <= 0) return 0;
    return (wordCorrect / wordTotal).clamp(0.0, 1.0);
  }

  double get sentenceAccuracy {
    if (sentenceTotal <= 0) return 0;
    return (sentenceCorrect / sentenceTotal).clamp(0.0, 1.0);
  }

  bool get vowelZoneUnlocked => phonicsSuccesses > 0;
  bool get consonantZoneUnlocked => vowelZoneComplete;
  bool get wordZoneUnlocked => consonantZoneComplete;
  bool get sentenceZoneUnlocked => wordAccuracy >= 0.7 && wordTotal >= 3;
}

class ChildPerformanceNotifier extends AsyncNotifier<ChildPerformance> {
  @override
  Future<ChildPerformance> build() async {
    final perf = await PreferencesService.loadPerformance();
    return ChildPerformance(
      readingSessions: perf.readingSessions,
      bubbleCorrect: perf.bubbleCorrect,
      bubbleTargetTotal: perf.bubbleTargetTotal,
      storySessions: perf.storySessions,
      phonicsSuccesses: perf.phonicsSuccesses,
      vowelZoneComplete: perf.vowelZoneComplete,
      consonantZoneComplete: perf.consonantZoneComplete,
      wordCorrect: perf.wordCorrect,
      wordTotal: perf.wordTotal,
      sentenceCorrect: perf.sentenceCorrect,
      sentenceTotal: perf.sentenceTotal,
    );
  }

  Future<void> _persist(ChildPerformance value) async {
    await PreferencesService.savePerformance(
      readingSessions: value.readingSessions,
      bubbleCorrect: value.bubbleCorrect,
      bubbleTargetTotal: value.bubbleTargetTotal,
      storySessions: value.storySessions,
      phonicsSuccesses: value.phonicsSuccesses,
      vowelZoneComplete: value.vowelZoneComplete,
      consonantZoneComplete: value.consonantZoneComplete,
      wordCorrect: value.wordCorrect,
      wordTotal: value.wordTotal,
      sentenceCorrect: value.sentenceCorrect,
      sentenceTotal: value.sentenceTotal,
    );
  }

  Future<void> markReadingCompleted() async {
    final current = state.value ?? const ChildPerformance();
    final next = current.copyWith(readingSessions: current.readingSessions + 1);
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> recordBubbleResult({
    required int correctPops,
    required int totalTargetPops,
  }) async {
    final current = state.value ?? const ChildPerformance();
    final next = current.copyWith(
      bubbleCorrect: current.bubbleCorrect + correctPops,
      bubbleTargetTotal: current.bubbleTargetTotal + totalTargetPops,
    );
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> markStoryCompleted() async {
    final current = state.value ?? const ChildPerformance();
    final next = current.copyWith(storySessions: current.storySessions + 1);
    state = AsyncData(next);
    await _persist(next);
  }

  Future<bool> completePhonicsZone({
    required int bubbleCorrectPops,
    required int totalBubbleTargets,
  }) async {
    final current = state.value ?? const ChildPerformance();
    final bubbleScore = totalBubbleTargets <= 0
        ? 0.0
        : (bubbleCorrectPops / totalBubbleTargets).clamp(0.0, 1.0);
    final pass = bubbleScore >= 0.75;
    final next = current.copyWith(
      phonicsSuccesses: pass
          ? current.phonicsSuccesses + 1
          : current.phonicsSuccesses,
    );
    state = AsyncData(next);
    await _persist(next);
    return next.vowelZoneUnlocked;
  }

  Future<bool> completeVowelZone() async {
    final current = state.value ?? const ChildPerformance();
    final next = current.copyWith(vowelZoneComplete: true);
    state = AsyncData(next);
    await _persist(next);
    return next.consonantZoneUnlocked;
  }

  Future<bool> completeConsonantZone() async {
    final current = state.value ?? const ChildPerformance();
    final next = current.copyWith(consonantZoneComplete: true);
    state = AsyncData(next);
    await _persist(next);
    return next.wordZoneUnlocked;
  }

  Future<bool> recordWordZoneResult({
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final current = state.value ?? const ChildPerformance();
    final next = current.copyWith(
      wordCorrect: current.wordCorrect + correctAnswers,
      wordTotal: current.wordTotal + totalQuestions,
    );
    state = AsyncData(next);
    await _persist(next);
    return next.sentenceZoneUnlocked;
  }

  Future<void> recordSentenceZoneResult({
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    final current = state.value ?? const ChildPerformance();
    final next = current.copyWith(
      sentenceCorrect: current.sentenceCorrect + correctAnswers,
      sentenceTotal: current.sentenceTotal + totalQuestions,
    );
    state = AsyncData(next);
    await _persist(next);
  }
}

final childPerformanceProvider =
    AsyncNotifierProvider<ChildPerformanceNotifier, ChildPerformance>(
      () => ChildPerformanceNotifier(),
    );
