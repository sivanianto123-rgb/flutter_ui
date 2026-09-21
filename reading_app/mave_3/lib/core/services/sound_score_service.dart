import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sound_node.dart';

class SoundScoreService {
  static const int    windowSize   = 5;
  static const String _hiveBoxName = 'sound_scores';

  Box get _box => Hive.box(_hiveBoxName);

  void record(String soundId, double accuracy) {
    final clipped = accuracy.clamp(0.0, 1.0);
    final scores  = _loadScores(soundId)..add(clipped);
    if (scores.length > windowSize) scores.removeAt(0);
    _box.put(soundId, scores.map((d) => d.toString()).toList());

    _syncToFirestore(soundId, clipped).catchError((Object e) {
      debugPrint('[SoundScore] Firestore sync failed: $e');
    });
  }

  double accuracy(String soundId) {
    final scores = _loadScores(soundId);
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  Map<String, double> allAccuracy() => {
        for (final node in SoundNode.curriculum) node.id: accuracy(node.id),
      };

  List<double> _loadScores(String soundId) {
    final raw = _box.get(soundId);
    if (raw == null) return [];
    return (raw as List).map((e) => double.tryParse(e.toString()) ?? 0.0).toList();
  }

  Future<void> _syncToFirestore(String soundId, double accuracy) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users').doc(uid).collection('sound_sessions')
        .add({'soundId': soundId, 'accuracy': accuracy, 'timestamp': FieldValue.serverTimestamp()});
  }
}
