import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/date_provider.dart';
import 'providers/note_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/theme_provider.dart';
import 'styles/app_colors.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final noteProvider = NoteProvider();
  final scheduleProvider = ScheduleProvider();
  final themeProvider = ThemeProvider();
  await Future.wait([
    noteProvider.load(),
    scheduleProvider.load(),
    themeProvider.load(),
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DateProvider()),
        ChangeNotifierProvider(create: (_) => noteProvider),
        ChangeNotifierProvider(create: (_) => scheduleProvider),
        ChangeNotifierProvider(create: (_) => themeProvider),
      ],
      child: const SchedulePlannerApp(),
    ),
  );
}

class SchedulePlannerApp extends StatelessWidget {
  const SchedulePlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    return MaterialApp(
      title: 'Schedule Planner',
      debugShowCheckedModeBanner: false,
      theme: isDark ? _darkTheme : _lightTheme,
      home: const MainScreen(),
    );
  }
}

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.black,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.orange,
    surface: AppColors.cardBg,
  ),
);

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBg,
  colorScheme: const ColorScheme.light(
    primary: AppColors.orange,
    surface: AppColors.lightCard,
  ),
);
