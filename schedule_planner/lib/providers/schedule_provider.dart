import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_model.dart';

class ScheduleProvider extends ChangeNotifier {
  List<ScheduleModel> _schedules = [];
  static const _key = 'schedules_data';

  List<ScheduleModel> get schedules => _schedules;

  List<ScheduleModel> forDate(DateTime date) => _schedules
      .where((s) =>
          s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day)
      .toList()
    ..sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _schedules = list.map((e) => ScheduleModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_schedules.map((e) => e.toJson()).toList()));
  }

  Future<void> add(ScheduleModel s) async {
    _schedules.add(s);
    notifyListeners();
    await _save();
  }

  Future<void> update(ScheduleModel s) async {
    final idx = _schedules.indexWhere((e) => e.id == s.id);
    if (idx != -1) {
      _schedules[idx] = s;
      notifyListeners();
      await _save();
    }
  }

  Future<void> delete(String id) async {
    _schedules.removeWhere((s) => s.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> toggleComplete(String id) async {
    final idx = _schedules.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _schedules[idx] =
          _schedules[idx].copyWith(isCompleted: !_schedules[idx].isCompleted);
      notifyListeners();
      await _save();
    }
  }
}
