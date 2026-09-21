import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/hive/child_profile.dart';
import 'core/services/audio_cache_service.dart';
import 'core/services/firebase_service.dart';
import 'app.dart';

/// Boot sequence (order matters):
///   1. Flutter engine bindings
///   2. Orientation lock + immersive UI mode
///   3. Hive init + all boxes opened
///   4. Firebase anonymous sign-in (graceful fallback on failure)
///   5. AudioCacheService file-cache init
///   6. runApp inside ProviderScope
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // ── Hive ──────────────────────────────────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(ChildProfileAdapter());

  await Hive.openBox<ChildProfile>('profiles');
  await Hive.openBox('milestone_sessions');
  await Hive.openBox<List<int>>('mave_audio_vault');
  await Hive.openBox('sound_scores');
  await Hive.openBox('activity_scores');

  // ── Firebase ──────────────────────────────────────────────────────────────
  await FirebaseService.initialize();

  // ── Audio file cache ──────────────────────────────────────────────────────
  await AudioCacheService.instance.init();

  // ── Launch ────────────────────────────────────────────────────────────────
  runApp(
    const ProviderScope(
      child: MaveApp(),
    ),
  );
}
