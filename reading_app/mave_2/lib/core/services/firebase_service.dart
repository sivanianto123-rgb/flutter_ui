import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../../firebase_options.dart';

/// Centralises Firebase initialisation and anonymous authentication.
///
/// Call [FirebaseService.initialize] once in main() before runApp().
/// After a successful call, [FirebaseAuth.instance.currentUser] is guaranteed
/// to be non-null for the lifetime of the session.
class FirebaseService {
  FirebaseService._();

  /// Initialises the Firebase app using platform-specific options derived from
  /// the native config files (GoogleService-Info.plist on iOS) and immediately
  /// signs the user in anonymously so Firestore rules can key on uid.
  ///
  /// Any [FirebaseException] is caught, its full details logged, and execution
  /// continues — the app runs in Hive-only mode when Firebase is unavailable.
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await _signInAnonymously();

      debugPrint(
        '[FirebaseService] Ready. '
        'UID: ${FirebaseAuth.instance.currentUser?.uid}',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        '[FirebaseService] FirebaseException during init:\n'
        '  code    : ${e.code}\n'
        '  message : ${e.message}\n'
        '  plugin  : ${e.plugin}\n'
        '  stackTrace: ${e.stackTrace}',
      );
    } catch (e, stack) {
      debugPrint(
        '[FirebaseService] Unexpected error during init: $e\n$stack',
      );
    }
  }

  static Future<void> _signInAnonymously() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      debugPrint(
        '[FirebaseService] Already signed in: ${auth.currentUser!.uid}',
      );
      return;
    }

    try {
      final credential = await auth.signInAnonymously();
      debugPrint(
        '[FirebaseService] Anonymous sign-in succeeded. '
        'UID: ${credential.user?.uid}',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[FirebaseService] FirebaseAuthException during sign-in:\n'
        '  code    : ${e.code}\n'
        '  message : ${e.message}\n'
        '  Ensure "Anonymous" is enabled in Firebase Console → '
        'Authentication → Sign-in method.',
      );
    }
  }

  /// Returns the current user's UID, or null when Firebase is unavailable.
  static String? get uid => FirebaseAuth.instance.currentUser?.uid;

  /// True once Firebase has initialised and a user is signed in.
  static bool get isReady => FirebaseAuth.instance.currentUser != null;
}
