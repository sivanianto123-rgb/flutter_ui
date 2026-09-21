import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/entry_screen.dart';
import 'features/world_map/screens/world_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final kidName = prefs.getString('kidName');
  final parentEmail = prefs.getString('parentEmail');
  final hasEnteredDetails = kidName != null && parentEmail != null;

  runApp(ProviderScope(child: MaveApp(startAtHome: hasEnteredDetails)));
}

class MaveApp extends StatelessWidget {
  final bool startAtHome;
  const MaveApp({super.key, required this.startAtHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C4DFF)),
        useMaterial3: true,
      ),
      home: startAtHome ? const WorldMapScreen() : const EntryScreen(),
    );
  }
}
