import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';

const _defaultContinueUrl = String.fromEnvironment(
  'AUTH_CONTINUE_URL',
  defaultValue: 'https://mave-auth.web.app/login',
);

Uri _resolveContinueUri() {
  final raw = _defaultContinueUrl.trim();
  final normalized = raw.startsWith('http://') || raw.startsWith('https://')
      ? raw
      : 'https://$raw';
  final parsed = Uri.tryParse(normalized);
  if (parsed == null || parsed.host.isEmpty) {
    return Uri.parse('https://mave-auth.web.app/login');
  }
  return parsed;
}

final firebaseInitProvider = FutureProvider<FirebaseApp>((ref) async {
  return Firebase.initializeApp();
});

final authStateProvider = StreamProvider<User?>((ref) {
  ref.watch(firebaseInitProvider);
  return FirebaseAuth.instance.authStateChanges();
});

class ParentAuthController {
  const ParentAuthController();

  Future<void> sendOtpLink(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: _resolveContinueUri().toString(),
      handleCodeInApp: true,
      iOSBundleId: 'com.example.mave6',
      androidPackageName: 'com.example.mave_6',
      androidInstallApp: true,
      androidMinimumVersion: '21',
    );
    await FirebaseAuth.instance.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
    await PreferencesService.savePendingAuthEmail(email);
  }

  Future<bool> tryCompleteOtpFromLink(String link) async {
    if (!FirebaseAuth.instance.isSignInWithEmailLink(link)) return false;
    final pendingEmail = await PreferencesService.loadPendingAuthEmail();
    if (pendingEmail == null || pendingEmail.isEmpty) return false;
    await FirebaseAuth.instance.signInWithEmailLink(
      email: pendingEmail,
      emailLink: link,
    );
    await PreferencesService.clearPendingAuthEmail();
    return true;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

final parentAuthControllerProvider = Provider<ParentAuthController>(
  (ref) => const ParentAuthController(),
);
