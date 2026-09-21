import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/providers/app_providers.dart';
import 'core/services/hive_service.dart';
import 'features/home/home_screen.dart';

// ---------------------------------------------------------------------------
// Set your Gemini API key via --dart-define at build time:
//   flutter run --dart-define=GEMINI_API_KEY=your_key_here
// Or replace the defaultValue below for quick testing.
// ---------------------------------------------------------------------------
const String _geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force the Darwin audio session into Playback/speaker category so the
  // macOS sandbox opens the hardware output stream before any sound is needed.
  if (!kIsWeb && (Platform.isMacOS || Platform.isIOS)) {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          route: AudioContextConfigRoute.speaker,
          focus: AudioContextConfigFocus.gain,
        ).build(),
      );
      debugPrint('[Audio] AudioContext set to Playback/speaker on Darwin');
    } catch (e) {
      debugPrint('[Audio] AudioContext init failed: $e');
    }
  }

  final hive = HiveService();
  await hive.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hive),
      ],
      child: const MaveApp(),
    ),
  );
}

class MaveApp extends ConsumerWidget {
  const MaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      // Design canvas: 1280 × 800 (landscape tablet)
      designSize: const Size(1280, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Mave',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFFFF6B9D),
            useMaterial3: true,
          ),
          home: child,
        );
      },
      child: const _AppInit(),
    );
  }
}

class _AppInit extends ConsumerStatefulWidget {
  const _AppInit();

  @override
  ConsumerState<_AppInit> createState() => _AppInitState();
}

class _AppInitState extends ConsumerState<_AppInit> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectGemini());
  }

  Future<void> _connectGemini() async {
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') return;
    // GeminiController handles init, connect, and NPC state wiring.
    await ref.read(geminiControllerProvider).connect(_geminiApiKey);
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
