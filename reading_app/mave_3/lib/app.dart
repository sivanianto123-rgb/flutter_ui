import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/services/app_providers.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class MaveApp extends ConsumerWidget {
  const MaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(childProfileProvider);

    return MaterialApp(
      title: 'Mave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: profile != null ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
