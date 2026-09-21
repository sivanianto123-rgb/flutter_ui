import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/milestone_model.dart';

class DataService {
  static const String _hiveBox = 'milestone_sessions';
  Box get _box => Hive.box(_hiveBox);

  Future<void> recordSession(BabyDevelopment data) async {
    try { await _box.add(data.toMap()); } catch (e) {
      debugPrint('[DataService] Hive write failed: $e');
    }
    _syncToFirestore(data).catchError((Object e) {
      debugPrint('[DataService] Firestore sync failed: $e');
    });
  }

  Future<void> _syncToFirestore(BabyDevelopment data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('milestones')
        .add({
      'vocalizationQuality': data.vocalizationQuality,
      'visualAttention':     data.visualAttention,
      'motorPrecision':      data.motorPrecision,
      'timestamp':           Timestamp.fromDate(data.timestamp),
      'syllable':            data.syllable,
    });
  }

  Stream<List<BabyDevelopment>> streamMilestones() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('milestones')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .map((snap) => snap.docs.map((doc) {
                final raw = Map<String, dynamic>.from(doc.data());
                final ts  = raw['timestamp'];
                if (ts is Timestamp) raw['timestamp'] = ts.toDate().toIso8601String();
                return BabyDevelopment.fromMap(raw);
              }).toList());
    } catch (e) {
      return Stream.value([]);
    }
  }
}
