import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _kProgressBox = 'progress';
const String _kCompletedLevelsKey = 'completedLevels';
const String _kTotalLevelsKey = 'totalLevels';

class HiveService {
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_kProgressBox);
    if (!_box.containsKey(_kTotalLevelsKey)) {
      await _box.put(_kTotalLevelsKey, 4); // 4 levels for "Ma" journey
    }
  }

  int get completedLevels => _box.get(_kCompletedLevelsKey, defaultValue: 0) as int;
  int get totalLevels => _box.get(_kTotalLevelsKey, defaultValue: 4) as int;

  double get progressPercent {
    final total = totalLevels;
    if (total == 0) return 0;
    return (completedLevels / total).clamp(0.0, 1.0);
  }

  Future<void> markLevelComplete(int levelIndex) async {
    final current = completedLevels;
    if (levelIndex >= current) {
      await _box.put(_kCompletedLevelsKey, levelIndex + 1);
    }
  }

  Future<void> resetProgress() async {
    await _box.put(_kCompletedLevelsKey, 0);
  }
}

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());
