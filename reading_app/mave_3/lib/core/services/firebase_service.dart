import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Uncomment after running `flutterfire configure`:
// import '../../firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    try {
      // If you have run `flutterfire configure`, replace the line below with:
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      await Firebase.initializeApp();
      await _signInAnonymously();
      debugPrint('[FirebaseService] Ready. UID: ${FirebaseAuth.instance.currentUser?.uid}');
    } catch (e) {
      debugPrint('[FirebaseService] Firebase unavailable — Hive-only mode: $e');
    }
  }

  static Future<void> _signInAnonymously() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return;
    try {
      await auth.signInAnonymously();
    } catch (e) {
      debugPrint('[FirebaseService] Anonymous sign-in failed: $e');
    }
  }

  static String? get uid => FirebaseAuth.instance.currentUser?.uid;
  static bool get isReady => FirebaseAuth.instance.currentUser != null;
}
