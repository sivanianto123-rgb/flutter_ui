import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';

/// Real-time microphone amplitude detector backed by [NoiseMeter].
///
/// Used by the Sound Tracing game to detect when the toddler is vocalizing.
/// [dBLevel] reflects current mean decibels from the device microphone.
/// [isSpeaking] is true when [dBLevel] ≥ [dBThreshold] (~55 dB separates
/// ambient room noise from active toddler vocalization in a home setting).
///
/// Platform permissions required (set in native project before first run):
///   iOS    : NSMicrophoneUsageDescription in Info.plist
///   Android: android.permission.RECORD_AUDIO in AndroidManifest.xml
///
/// Lifecycle:
///   1. [start] — begins the noise stream subscription.
///   2. [stop]  — cancels subscription, resets dB level.
///   3. [dispose] — always calls [stop] (safe to call in widget dispose).
class MicrophoneController extends ChangeNotifier {
  final NoiseMeter _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _subscription;

  double _dBLevel   = 0.0;
  bool   _listening = false;

  /// Mean dB level above which we consider the child to be vocalizing.
  /// 55 dB ≈ conversational speech onset; ambient quiet room ≈ 30–45 dB.
  static const double dBThreshold = 55.0;

  double get dBLevel    => _dBLevel;
  bool   get isListening => _listening;

  /// True when current amplitude indicates active vocalization.
  bool get isSpeaking => _listening && _dBLevel >= dBThreshold;

  /// Normalized amplitude (0.0 = silent, 1.0 = loud) for progress bars.
  /// Maps the 30–90 dB practical range to 0.0–1.0.
  double get normalizedLevel =>
      ((_dBLevel - 30.0) / 60.0).clamp(0.0, 1.0);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Starts the noise meter stream.  Safe to call multiple times (idempotent).
  Future<void> start() async {
    if (_listening) return;

    try {
      _subscription = _noiseMeter.noise.listen(
        (NoiseReading reading) {
          final prev = _dBLevel;
          _dBLevel = reading.meanDecibel;
          if (_dBLevel != prev) notifyListeners();
        },
        onError: (Object e) {
          debugPrint('[Mic] NoiseMeter error: $e');
          _listening = false;
          _dBLevel   = 0.0;
          notifyListeners();
        },
        cancelOnError: true,
      );
      _listening = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[Mic] Failed to start NoiseMeter: $e');
    }
  }

  /// Stops the noise meter and resets amplitude.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _listening    = false;
    _dBLevel      = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
