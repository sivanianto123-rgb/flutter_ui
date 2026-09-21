import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive full-screen (hides status/nav bars).
  // Orientation lock is intentionally omitted — iOS rejects programmatic
  // orientation changes when the windowing mode doesn't allow it.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const ProviderScope(child: MaveApp()));
}
