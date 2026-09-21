# Mave — Flutter Phonics App

## Project Overview
Mave teaches phonics to babies and toddlers (ages 0–2) through sound-based
games, AI-generated stories, and a world-map progression system.
Mascot: Sprout (friendly plant creature, Rive animated).

## Tech Stack
- **Flutter** (Dart) — mobile (iOS + Android)
- **State management** — Riverpod (code gen with `@riverpod`)
- **Routing** — GoRouter
- **Game engine** — Flutter Flame (World Map, bubble animations)
- **Fonts** — Fredoka One (display), Nunito (body) via google_fonts
- **Animation** — Rive for Sprout mascot; AnimationController for UI
- **TTS / Voice** — Gemini API (TTS + story generation)
- **Audio playback** — just_audio
- **Mic input** — record package

## Project Structure
```
lib/
  core/
    theme/         ← MaveColors, MaveTextStyles
    router/        ← GoRouter config + route constants
    services/      ← TtsService, StoryService, SoundManager
    widgets/       ← MaveScaffold, MaveBubble, PhonicsLevelNode
  features/
    auth/          ← ParentLoginScreen, ChildProfileScreen
    world_map/     ← WorldMapScreen (Flame)
    phonics/       ← BubbleSelectScreen, ReadingZoneScreen,
                      SoundPopScreen, StoryScreen
    word_zone/     ← WordBuildScreen, WordBankProvider
    sentence_zone/ ← SentenceBuildScreen
assets/
  rive/            ← sprout.riv
  audio/           ← cached TTS files (gitignored)
  images/          ← world map backgrounds, cactus, path assets
```

## Commands
```bash
flutter run                    # dev run
flutter run --dart-define=GEMINI_API_KEY=xxx
flutter test                   # all tests
flutter test --coverage        # with coverage
flutter build apk --release    # Android build
flutter build ipa              # iOS build
dart run build_runner build    # regenerate Riverpod providers
```

## Conventions
- All screens extend `ConsumerWidget` (Riverpod)
- Screen files: `snake_case_screen.dart`
- Widget files: `snake_case_widget.dart`
- Providers: `snake_case_provider.dart` with `@riverpod` codegen
- Never hardcode colors — use `MaveColors.xxx`
- Never hardcode strings — future i18n ready (use `AppLocalizations`)
- Tap targets MUST be ≥ 44×44px (toddler safe)
- COPPA: no PII sent to any external API; only phoneme/story text

## Skills available
- `/mave-ui`         → design system reference
- `/flutter-screen`  → scaffold a new screen
- `/gemini-tts`      → TTS/STT integration patterns
- `/phonics-logic`   → game rules, mastery logic, state models
- `/ai-story`        → Gemini story generation prompts

## Subagents
- `flutter-reviewer` → code quality review before commits
