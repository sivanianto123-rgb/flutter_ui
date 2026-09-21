import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/milestone_model.dart';

/// Dual-storage service for developmental milestone data.
///
/// Write path:
///   1. Hive write (synchronous, immediate) — keeps the UI lag-free even
///      when offline or when Firestore is not yet configured.
///   2. Firestore write (background, fire-and-forget) — persists the record
///      to `users/{uid}/milestones/{auto-id}` for cross-device access.
///
/// Read path:
///   [streamMilestones] returns a live Firestore stream of the 20 most recent
///   sessions for the current user. When the user is not authenticated or
///   Firestore is unavailable the stream emits an empty list.
class DataService {
  static const String _hiveBox            = 'milestone_sessions';
  static const String _firestoreSubcollection = 'milestones';

  Box get _box => Hive.box(_hiveBox);

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Records a session milestone.
  ///
  /// Writes to Hive synchronously (never throws), then attempts a Firestore
  /// push in the background. Any Firestore failure is logged but swallowed
  /// so the caller is never blocked.
  Future<void> recordSession(BabyDevelopment data) async {
    // Immediate local write — always succeeds.
    try {
      await _box.add(data.toMap());
    } catch (e) {
      debugPrint('[DataService] Hive write failed: $e');
    }

    // Background Firestore sync — non-blocking.
    _syncToFirestore(data).catchError((Object e) {
      debugPrint('[DataService] Firestore sync failed: $e');
    });
  }

  Future<void> _syncToFirestore(BabyDevelopment data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Build the Firestore document — use a native Timestamp for server-side
    // ordering, which is more reliable than ISO-string lexicographic sorting.
    final doc = {
      'vocalizationQuality': data.vocalizationQuality,
      'visualAttention':     data.visualAttention,
      'motorPrecision':      data.motorPrecision,
      'timestamp':           Timestamp.fromDate(data.timestamp),
      'syllable':            data.syllable,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(_firestoreSubcollection)
        .add(doc);

    debugPrint('[DataService] Synced session for "${data.syllable}" to Firestore.');
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Live stream of the 20 most recent milestone documents from Firestore.
  ///
  /// Falls back to [Stream.value([])] when:
  ///   • Firebase Auth has no current user (not yet signed in)
  ///   • Any exception occurs creating the Firestore query
  Stream<List<BabyDevelopment>> streamMilestones() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Stream.value([]);

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(_firestoreSubcollection)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .map((snap) => snap.docs.map((doc) {
                // Convert Firestore Timestamp → ISO string before fromMap so
                // BabyDevelopment.fromMap stays independent of cloud_firestore.
                final raw = Map<String, dynamic>.from(doc.data());
                final ts  = raw['timestamp'];
                if (ts is Timestamp) {
                  raw['timestamp'] = ts.toDate().toIso8601String();
                }
                return BabyDevelopment.fromMap(raw);
              }).toList());
    } catch (e) {
      debugPrint('[DataService] Failed to create Firestore stream: $e');
      return Stream.value([]);
    }
  }

  /// Returns recent sessions stored locally in Hive (available offline).
  ///
  /// Useful as a fallback when Firestore is unreachable.
  List<BabyDevelopment> getLocalSessions({int limit = 20}) {
    final result = <BabyDevelopment>[];
    for (final value in _box.values) {
      if (value is! Map) continue;
      try {
        result.add(BabyDevelopment.fromMap(Map<String, dynamic>.from(value)));
      } catch (e) {
        debugPrint('[DataService] Skipping malformed local session: $e');
      }
    }
    return result.reversed.take(limit).toList();
  }
}
