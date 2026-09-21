# Mave — Session Update Log
**Date:** 2026-04-07

---

## 1. Audio Stack — Replaced Local TTS & ElevenLabs with Gemini TTS

**Files changed:** `audio_service.dart`, `app_providers.dart`, `pubspec.yaml`

- Removed `local_tts_service.dart` and `elevenlabs_tts_service.dart` entirely.
- Removed `flutter_tts` from `pubspec.yaml`.
- `AudioService` now routes all speech exclusively through `GeminiTTSService`.
- Eliminated the `_isLocal()` routing logic and phoneme-lifting (`_resolve` / `_phonemeDescriptor`) — Gemini handles phoneme input directly via prompt escalation.

---

## 2. Gemini TTS — Two-Step Pipeline (Story Generation + Speech)

**File changed:** `gemini_tts_service.dart`

**Root problem:** Asking a single TTS model to both generate creative content and speak it produced drill-style output ("say it loud, say it slow").

**Fix — separated concerns into two API calls:**

| Step | Model | Purpose |
|------|-------|---------|
| 1 | `gemini-3.1-flash-lite-preview` (text) | Generates a 2-3 sentence toddler picture-book story embedding the phoneme in real words |
| 2 | `gemini-2.5-flash-preview-tts` (speech) | Speaks the generated story text |

**Prompt rules enforced on story generation:**
- Uses real words containing the target sound (e.g. for "ma": mama, mango, magic)
- Features a lovable character (mama bear, baby bird, bunny)
- Ends with one echo invitation: `"Can you say... ma?"`
- Closes with a praise phrase: `"You did it! Amazing job!"` etc.
- Explicitly bans: "say it loud", "say it slow", "make the sound", "repeat after me"

**TTS persona (system instruction on every request):**
> "You are Mave, a warm, upbeat nursery school teacher. Speak in a high-pitched, comforting, and melodic tone at approximately 1.15–1.2× normal speed."

**Text cleaning applied before every API call:**
- Strips `*bold*`, `_italic_`, `[stage directions]`, `(parentheticals)`, `## headers`, `` `backticks` ``

---

## 3. Gemini TTS — Output Quality Fixes

**File changed:** `gemini_tts_service.dart`

- **WAV wrapping:** Raw 16-bit PCM at 24 kHz returned by Gemini TTS is wrapped in a 44-byte RIFF header before storage/playback.
- **Repeated-char guard:** 3+ identical consecutive characters collapsed to 2 (e.g. `"mmm"` → `"mm"`) to prevent Gemini TTS content refusals (`finishReason: OTHER`).
- **Three-tier retry:** Primary prompt → simpler retry prompt → plain fallback (`"Say: ma"`) with exponential backoff (1 s → 2 s → 4 s).

---

## 4. Firebase Integration

**Files created:** `lib/firebase_options.dart`, `lib/core/services/firebase_service.dart`  
**Files changed:** `lib/main.dart`, `pubspec.yaml`, `ios/Runner/AppDelegate.swift`, `ios/Podfile`

### Packages added
```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.0
cloud_firestore: ^5.4.0
```

### `firebase_options.dart`
- Generated from `ios/Runner/GoogleService-Info.plist` (FlutterFire CLI output confirmed present).
- iOS-only configuration: project `mave-app-7787e`, bundle `com.mave.mave2`.

### `firebase_service.dart`
- `FirebaseService.initialize()` calls `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
- Immediately signs in anonymously — `FirebaseAuth.instance.currentUser.uid` is available from that point forward.
- `FirebaseException` catch block logs `code`, `message`, `plugin`, and `stackTrace` for root-cause debugging.
- App runs in Hive-only mode if Firebase is unavailable (graceful degradation, no crash).

### iOS native setup
- `AppDelegate.swift`: added `import FirebaseCore` and `FirebaseApp.configure()` before `GeneratedPluginRegistrant.register`.
- `Podfile`: uncommented `platform :ios, '13.0'` (Firebase SDK 11.x minimum requirement).
- Ran `pod install` → Firebase SDK `11.15.0` installed for all three packages.

---

## 5. Developmental Milestone Tracking

**Files created:** `lib/core/models/milestone_model.dart`, `lib/core/services/data_service.dart`  
**Files changed:** `lib/core/services/app_providers.dart`, `lib/features/sound_mode/providers/sound_mode_provider.dart`, `lib/features/sound_mode/screens/level1_screen.dart`, `lib/features/sound_mode/screens/level3_screen.dart`

### `BabyDevelopment` model (`milestone_model.dart`)

| Field | Type | Source |
|-------|------|--------|
| `vocalizationQuality` | `double` 0–1 | STT phoneme overlap score vs target syllable |
| `visualAttention` | `double` 0–1 | Level 1 dwell time normalised over 120 s |
| `motorPrecision` | `double` 0–1 | Correct bubble taps / total taps on Level 3 |
| `timestamp` | `DateTime` | Session wall-clock time |
| `syllable` | `String` | Syllable being practised |

`overallMastery` = equal-weight average of the three quality pillars.

### `DataService` — dual-storage write path
1. **Hive write** (immediate, always succeeds) — lag-free UI.
2. **Firestore write** (background, fire-and-forget) — `users/{uid}/milestones/{auto-id}`.

Firestore uses native `Timestamp` (not ISO string) for server-side ordering.

### `SoundModeNotifier` additions
- `recordVocalization(String words)` — scores STT output, stores `_vocalizationQuality`, speaks praise (`"You're doing great!"` if ≥ 70%, else `"Great job!"`).
- `recordTap({required bool wasTarget})` — accumulates tap counts for motor precision.
- `markLevelComplete()` — captures Level 1 attention duration; flushes `BabyDevelopment` to `DataService` when Level 3 completes.
- `_saveSession()` — assembles and persists the full session record.

### Screen changes
- **`level1_screen.dart`**: captures `result.recognizedWords` → passes to `recordVocalization()`; removed duplicate `speak('Great job!')` (praise now always from notifier).
- **`level3_screen.dart`**: every bubble tap calls `recordTap(wasTarget: bubble.isTarget)`.

---

## 6. Home Screen — Mastery Progress Ring

**File changed:** `lib/features/home/home_screen.dart`

- Added `milestonesStreamProvider` (`StreamProvider<List<BabyDevelopment>>`) — live Firestore listener, 20 most recent sessions.
- Replaced the star badge with `_ProfileProgressRing`: a circular avatar (child's initial) wrapped in a `CustomPainter` arc.
- Arc fills clockwise from 12 o'clock; fill level = average `overallMastery` of last 5 sessions.
- Star count displayed beneath the ring.
- Gracefully shows empty ring while loading or when Firebase is unavailable.

---

## 7. Audio Byte Cache — `mave_audio_vault`

**Files changed:** `gemini_tts_service.dart`, `audio_service.dart`, `main.dart`

- `Hive.openBox<List<int>>('mave_audio_vault')` opened in `main.dart`.
- Cache key: SHA-256 of cleaned input text.
- **Hit path:** bytes returned immediately from Hive — zero API calls, zero network latency.
- **Miss path:** synthesise → `vault.put(key, bytes.toList())` → return bytes.
- Vault survives app restarts; previously synthesised phrases are never re-fetched.

### `AudioService` — in-memory bytes playback
- `_preloadedBytes: Map<String, Uint8List>` replaces the old `_preloadedPaths: Map<String, String>`.
- `_MemoryAudioSource extends StreamAudioSource` feeds WAV bytes directly into `just_audio` — no temp file written, no disk latency in the playback hot path.
- Content type: `audio/wav` (matches Gemini TTS PCM → WAV output).

---

## 8. Cloud TTS 403 — Reverted to Gemini TTS

**File changed:** `gemini_tts_service.dart`

**What happened:** An attempt to use Google Cloud TTS (`texttospeech.googleapis.com`) with `en-US-Journey-F` voice returned HTTP 403 — the `GEMINI_API_KEY` (Google AI Studio key) does not include Cloud TTS access.

**Resolution:** Speech synthesis reverted to `gemini-2.5-flash-preview-tts`. All other improvements retained:
- Hive vault cache unchanged.
- `_MemoryAudioSource` playback unchanged (content type corrected to `audio/wav`).
- Story generation unchanged.
- PCM → WAV wrapping restored.

---

## Files Created Today

| File | Purpose |
|------|---------|
| `lib/firebase_options.dart` | Platform Firebase config (iOS) |
| `lib/core/services/firebase_service.dart` | Firebase init + anonymous auth |
| `lib/core/services/data_service.dart` | Dual Hive + Firestore milestone sync |
| `lib/core/models/milestone_model.dart` | `BabyDevelopment` schema |

## Files Deleted Today

| File | Reason |
|------|--------|
| `lib/core/services/local_tts_service.dart` | Replaced by Gemini TTS |
| `lib/core/services/elevenlabs_tts_service.dart` | Replaced by Gemini TTS |

## Files Modified Today

`pubspec.yaml` · `lib/main.dart` · `lib/env/env.dart` · `lib/core/services/app_providers.dart` · `lib/core/services/audio_service.dart` · `lib/core/services/gemini_tts_service.dart` · `lib/features/home/home_screen.dart` · `lib/features/sound_mode/providers/sound_mode_provider.dart` · `lib/features/sound_mode/screens/level1_screen.dart` · `lib/features/sound_mode/screens/level3_screen.dart` · `ios/Runner/AppDelegate.swift` · `ios/Podfile`
