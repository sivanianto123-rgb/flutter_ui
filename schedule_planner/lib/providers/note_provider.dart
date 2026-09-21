import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  static const _key = 'notes_data';

  List<NoteModel> get notes => _notes;

  List<NoteModel> forDate(DateTime date) => _notes
      .where((n) =>
          n.date.year == date.year &&
          n.date.month == date.month &&
          n.date.day == date.day)
      .toList();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _notes = list.map((e) => NoteModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_notes.map((e) => e.toJson()).toList()));
  }

  Future<void> add(NoteModel note) async {
    _notes.add(note);
    notifyListeners();
    await _save();
  }

  Future<void> update(NoteModel note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
      notifyListeners();
      await _save();
    }
  }

  Future<void> delete(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> toggleComplete(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notes[idx] = _notes[idx].copyWith(isCompleted: !_notes[idx].isCompleted);
      notifyListeners();
      await _save();
    }
  }
}
