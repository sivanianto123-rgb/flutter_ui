import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/sound_node.dart';

/// Manages per-sound rolling accuracy scores.
///
/// Local storage (Hive):
///   Box name  : 'sound_scores'
///   Key       : sound ID ('ma', 'pa', 'ma_pa')
///   Value     : List of the last [windowSize] accuracy scores (stored as
///               List of strings so they survive Hive's dynamic typing)
///
/// Remote storage (Firestore):
///   Path      : users/{uid}/sound_sessions/{auto-id}
///   Written in the background after every [record] call.
///   A Firestore failure is logged but never rethrown — the app stays stable.
///
/// The combo node (Ma + Pa) unlocks when both 'ma' and 'pa' rolling averages
/// are ≥ 0.9, which [SoundNode.statusFor] checks against [allAccuracy].
class SoundScoreService {
  static const int    windowSize   = 5;
  static const String _hiveBoxName = 'sound_scores';

  Box get _box => Hive.box(_hiveBoxName);

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Records a game session result for [soundId].
  ///
  /// [accuracy] is clamped to 0.0–1.0 before storage.
  void record(String soundId, double accuracy) {
    final clipped = accuracy.clamp(0.0, 1.0);
    final scores  = _loadScores(soundId)..add(clipped);
    if (scores.length > windowSize) scores.removeAt(0);
    _box.put(soundId, scores.map((d) => d.toString()).toList());

    _syncToFirestore(soundId, clipped).catchError((Object e) {
      debugPrint('[SoundScore] Firestore sync failed: $e');
    });
  }

  /// Rolling average accuracy for [soundId] (0.0–1.0).
  double accuracy(String soundId) {
    final scores = _loadScores(soundId);
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Accuracy map for all curriculum nodes — used by [SoundNode.statusFor].
  Map<String, double> allAccuracy() => {
        for (final node in SoundNode.curriculum) node.id: accuracy(node.id),
      };

  // ── Hive ───────────────────────────────────────────────────────────────────

  List<double> _loadScores(String soundId) {
    final raw = _box.get(soundId);
    if (raw == null) return [];
    return (raw as List)
        .map((e) => double.tryParse(e.toString()) ?? 0.0)
        .toList();
  }

  // ── Firestore ──────────────────────────────────────────────────────────────

  Future<void> _syncToFirestore(String soundId, double accuracy) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sound_sessions')
        .add({
      'soundId':   soundId,
      'accuracy':  accuracy,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
