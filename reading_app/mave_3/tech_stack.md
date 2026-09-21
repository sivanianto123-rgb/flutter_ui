# Mave App — Tech Stack & Architecture

## Overview

Mave is a Flutter-based phoneme learning app for toddlers. It guides children through syllable mastery (Ma → Pa → Ma+Pa) via 10 mini-games per sound node, backed by Gemini AI for TTS and activity generation, Firebase for data persistence, and a multi-tier audio cache for offline resilience.

---

## Core Framework

| Layer | Technology |
|---|---|
| UI Framework | Flutter (SDK ^3.10.1) |
| Language | Dart |
| State Management | Riverpod `^2.5.1` (StateNotifier + StreamProvider) |
| Local Persistence | Hive `^2.2.3` + hive_flutter |
| Audio Playback | just_audio `^0.9.37` |
| Animations | flutter_animate `^4.5.0` |
| Speech Input | speech_to_text `^7.0.0`, noise_meter `^5.1.0` |
| Networking | http `^1.2.1` |
| Hashing | crypto `^3.0.3` (SHA-256 cache keys) |

---

## Backend & Cloud Services

### Firebase
- **firebase_core** `^3.6.0` — initialization
- **firebase_auth** `^5.3.0` — anonymous sign-in (no account creation)
- **cloud_firestore** `^5.4.0` — milestone + sound session persistence

Data is dual-written: **Hive (synchronous, immediate)** + **Firestore (async, background)**. Firestore failures are non-blocking.

Firestore structure:
```
users/{uid}/milestones/{auto-id}       → vocalizationQuality, visualAttention, motorPrecision
users/{uid}/sound_sessions/{auto-id}   → per-sound rolling accuracy
```

### AI / LLM APIs

| Service | Model | Purpose |
|---|---|---|
| Google Gemini | `gemini-2.5-flash-preview-tts` | Primary TTS, voice "Puck" |
| Google Gemini | `gemini-1.5-flash` | Activity generation (title + story JSON) |
| Groq | `canopylabs/orpheus-v1-english` | TTS fallback on Gemini 429/403, voice "hannah" |

API keys are injected at compile time via `--dart-define=GEMINI_API_KEY=...` and `--dart-define=GROQ_API_KEY=...`.

---

## Audio Pipeline

```
AudioService.speak(text)
    │
    ├─ 1. Session in-memory cache  (fastest, lives for app session)
    ├─ 2. File cache on disk        ({appDocDir}/mave_audio_cache/{sha256}.wav)
    ├─ 3. Hive audio vault          (persists across restarts)
    ├─ 4. Gemini TTS API            (0.5–2s latency, WAV output)
    └─ 5. Groq TTS API              (fallback on Gemini failure, MP3 output)
              │
              ▼
        just_audio AudioPlayer → Device speaker
```

Key behaviors:
- **In-flight deduplication**: two callers asking for the same phrase share one API call
- **Phonetic sanitization** via `PhoneticHelper` — prevents letter-name errors (e.g. "ma" → "mmm-ah")
- **Offline mode**: a single Gemini 403 permanently disables API calls; app runs from cache only
- **Preloading**: `SoundModeScreen` preloads all phrases on init (staggered 300ms to avoid rate-limiting)

---

## App Features & Screens

### Home Screen
- Displays Phase 1 three-node curriculum: **Ma → Pa → Ma+Pa**
- Nodes unlock based on rolling accuracy thresholds
- Parent Insights overlay shows developmental metrics (vocalization, attention, motor precision)

### Onboarding Screen
- Child name entry, ChildProfile creation in Hive

### Sound Mode (Core Learning Flow)
10-level PageView per syllable:

| Level | Game | Mechanic |
|---|---|---|
| 0 | Introduction | Listen + try |
| 1 | Feed the Monster | Drag bubbles into creature mouth |
| 2 | Syllable Pop | Tap matching bubbles |
| 3 | Sound Tracing | Bee moves by microphone amplitude |
| 4 | Echo the Animal | Hear → repeat phoneme |
| 5 | Tap & Grow | Sustain sound to grow flower |
| 6 | Who's Behind the Door | Audio-visual matching |
| 7 | Phoneme Train | Select correct wagon |
| 8 | Dance Off | Rhythm tap game |
| 9 | Storybook Finale | Narrative wrap-up |

### Game Modules (lib/features/game_modules/)
Each game lives in its own subdirectory with its own widget tree and scoring logic:
`feed_the_monster/`, `tap_and_grow/`, `sound_tracing/`, `echo_animal/`, `phoneme_train/`, `whos_behind_door/`, `dance_off/`, `word_reading/`

### Dynamic Activity (lib/features/dynamic_activity/)
Placeholder shell for future AI-generated activity injection.

---

## State Management

All providers are defined in `lib/core/services/app_providers.dart`:

| Provider | Type | Purpose |
|---|---|---|
| `audioServiceProvider` | Provider | Dual-TTS wrapper |
| `geminiTtsServiceProvider` | Provider | Gemini TTS instance |
| `groqTtsServiceProvider` | Provider | Groq TTS instance |
| `soundAccuracyProvider` | StateNotifierProvider | Rolling accuracy per sound node |
| `levelProvider` | StateNotifierProvider | Per-activity mastery scores |
| `activityAccuracyProvider` | StateNotifierProvider | Activity unlock state |
| `childProfileProvider` | StateNotifierProvider | Child name + syllable progress |
| `microphoneControllerProvider` | ChangeNotifierProvider | Real-time dB level (0–1 normalized) |
| `milestonesStreamProvider` | StreamProvider | Firestore milestone sync |
| `profileBoxProvider` | Provider | Hive box access |
| `dataServiceProvider` | Provider | Milestone/session recording |

---

## Data Models

| Model | Location | Description |
|---|---|---|
| `ChildProfile` | `core/hive/child_profile.dart` | Hive entity: name + per-syllable level progress |
| `SoundNode` | `core/models/sound_node.dart` | Phase 1 curriculum node (status computed from accuracy map) |
| `GameActivity` | `core/models/game_activity.dart` | 20+ game descriptors with unlock prerequisites |
| `ActivitySpec` | `core/models/activity_spec.dart` | AI-generated activity (title, storyText, uiType); JSON whitelisted |
| `MilestoneModel` | `core/models/milestone_model.dart` | BabyDevelopment: 3 developmental pillars |

---

## Hive Boxes

| Box Name | Contents |
|---|---|
| `profiles` | ChildProfile (name + syllable level progress) |
| `milestone_sessions` | Local fallback for Firestore milestones |
| `sound_scores` | Per-sound rolling accuracy (5-window) |
| `activity_scores` | Per-activity mastery (5-window) |
| `mave_audio_vault` | TTS bytes cache (SHA-256 → List\<int\>) |

---

## Accuracy Scoring

Three developmental pillars tracked per session:

| Pillar | Measurement |
|---|---|
| Vocalization Quality | STT confidence + phoneme overlap |
| Visual Attention | Seconds engaged on Level 1 (capped at 120s → normalized 0–1) |
| Motor Precision | Correct taps / total taps |

Rolling 5-window average stored in Hive and synced to Firestore.

---

## Boot Sequence (main.dart)

1. `WidgetsFlutterBinding.ensureInitialized()`
2. Orientation lock + immersive UI mode
3. Hive init — open all 5 boxes
4. Firebase init + anonymous sign-in (graceful fallback if config missing)
5. `AudioCacheService.instance.init()` — create file cache directory
6. `ProviderScope` → `MaveApp()`

---

## File Structure Summary

```
lib/
├── main.dart
├── core/
│   ├── constants/        # Colors, text styles
│   ├── controllers/      # MicrophoneController
│   ├── helpers/          # PhoneticHelper
│   ├── hive/             # Hive entity classes + generated adapters
│   ├── models/           # SoundNode, GameActivity, ActivitySpec, MilestoneModel
│   ├── providers/        # Additional Riverpod providers
│   └── services/         # All services (TTS, audio, Firebase, data, scoring)
├── features/
│   ├── onboarding/       # Profile creation screen
│   ├── home/             # Learning timeline + parent insights
│   ├── sound_mode/       # Core 10-level session flow
│   ├── game_modules/     # Individual game implementations
│   └── dynamic_activity/ # Future AI-generated activities
└── env/                  # Environment/config helpers
```

---

## Supported Platforms

Built for iOS, Android, macOS, and Windows (Flutter multi-platform). Primary target is mobile (iOS/Android) for toddler use.
