import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/hive/child_profile.dart';
import 'core/services/audio_cache_service.dart';
import 'core/services/firebase_service.dart';
import 'app.dart';

/// Entry point for the Mave toddler learning app.
///
/// Boot sequence (order matters):
///   1. Flutter engine bindings
///   2. Orientation lock + immersive UI mode
///   3. Hive boxes (all opened before runApp so providers never encounter
///      a box-not-open error on their first read)
///   4. Firebase.initializeApp + Anonymous Sign-in via [FirebaseService]
///      — every Firestore write is attributed to a stable UID for the session
///   5. runApp inside ProviderScope
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Orientation & system chrome ───────────────────────────────────────────

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // ── Hive ──────────────────────────────────────────────────────────────────

  await Hive.initFlutter();
  Hive.registerAdapter(ChildProfileAdapter());

  // Stores a single ChildProfile — name + per-syllable level progress.
  await Hive.openBox<ChildProfile>('profiles');

  // Local fallback for milestone sessions when Firestore is unavailable.
  await Hive.openBox('milestone_sessions');

  // Groq TTS vault — zero-cost repeats.
  // Key   : SHA-256(cleaned text)
  // Value : raw MP3 bytes stored as List<int> (Hive 2.x compatible).
  // A vault hit means the Groq Speech API is NEVER called for that phrase
  // again — zero network, zero latency, works fully offline.
  await Hive.openBox<List<int>>('mave_audio_vault');

  // Per-sound rolling accuracy scores — drives combo node unlock logic.
  // Key   : sound ID ('ma', 'pa', 'ma_pa')
  // Value : List of recent accuracy scores (stored as List<String>).
  await Hive.openBox('sound_scores');

  // Per-activity rolling accuracy scores — drives LevelProvider unlock logic.
  // Key   : 'scores_v1'
  // Value : Map<String, List<double>> — activity ID → recent session values.
  await Hive.openBox('activity_scores');

  // ── Firebase ──────────────────────────────────────────────────────────────
  //
  // FirebaseService.initialize():
  //   1. Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
  //   2. FirebaseAuth.instance.signInAnonymously()
  //
  // After a successful call, FirebaseAuth.instance.currentUser is non-null
  // and every DataService.recordSession() call writes to
  //   users/{uid}/milestones/{auto-id}
  //
  // On failure (network down, missing google-services.json) the exception is
  // caught and logged; the app continues in Hive-only mode.

  await FirebaseService.initialize();

  // ── Audio file cache ──────────────────────────────────────────────────────
  //
  // Creates {appDocDir}/mave_audio_cache/ and primes the singleton so every
  // GeminiTtsService call can hit the file-system cache before touching Hive
  // or the network.

  await AudioCacheService.instance.init();

  // ── Launch ────────────────────────────────────────────────────────────────

  runApp(
    const ProviderScope(
      child: MaveApp(),
    ),
  );
}
