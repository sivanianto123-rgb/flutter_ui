import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/app_settings_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/services/app_music_controller.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class MaveApp extends ConsumerWidget {
  const MaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final settings = ref.watch(appSettingsProvider);
    final musicController = ref.read(appMusicControllerProvider);
    musicController.syncSettings(settings);

    return MaterialApp(
      title: 'Mave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B6B)),
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF90CAF9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: profileAsync.when(
        loading: () => const _Splash(),
        error: (_, __) => const OnboardingScreen(),
        data: (profile) => profile != null
            ? const HomeScreen()
            : const OnboardingScreen(),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFF6B9D),
      body: Center(
        child: Text(
          'mave',
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
