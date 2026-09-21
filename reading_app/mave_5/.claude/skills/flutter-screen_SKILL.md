---
name: flutter-screen
description: Scaffold a new Flutter screen for Mave. Use when creating any
  new screen, page, or route. Generates boilerplate with Riverpod, GoRouter,
  and Mave design system applied.
argument-hint: "[ScreenName] — e.g. PhonicsZoneScreen"
---

# Flutter Screen Scaffold — Mave

## File Location
```
lib/
  features/
    <zone_name>/
      screens/
        <screen_name_snake>.dart
      widgets/          ← screen-specific widgets here
      providers/        ← screen-specific Riverpod providers
```

## Scaffold Template
Generate a screen called `$ARGUMENTS` using this structure:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/mave_colors.dart';
import '../../../core/theme/mave_text_styles.dart';
import '../../../core/widgets/mave_scaffold.dart';

class $ARGUMENTS extends ConsumerWidget {
  const $ARGUMENTS({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaveScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // TODO: implement $ARGUMENTS content
          ],
        ),
      ),
    );
  }
}
```

## MaveScaffold conventions
- Always wrap screens in `MaveScaffold` (handles gradient bg + safe area)
- Use `ref.watch()` for reactive state, `ref.read()` for one-time actions
- Route name constant goes in `lib/core/router/routes.dart`
- Add route to `lib/core/router/app_router.dart`

## Animation Pattern (entry animations)
```dart
// Use AnimationController + SlideTransition for screen entry
// Bubbles: use AnimatedBuilder with sin wave offset
// Level nodes: use staggered FadeIn with 80ms delay per node
```

## State Pattern
```dart
// Simple screen state
@riverpod
class ScreenState extends _$ScreenState {
  @override
  ScreenModel build() => const ScreenModel();
  // ... methods
}
```
