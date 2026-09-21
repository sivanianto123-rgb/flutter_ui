import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:noise_meter/noise_meter.dart';

/// Wraps [NoiseMeter] to expose a normalised 0–1 amplitude level and a
/// boolean [isSpeaking] flag.  Used by voice-driven game levels.
class MicrophoneController extends ChangeNotifier {
  final NoiseMeter _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _subscription;

  double _normalizedLevel = 0.0;
  bool   _isListening     = false;

  double get normalizedLevel => _normalizedLevel;
  bool   get isListening     => _isListening;
  bool   get isSpeaking      => _normalizedLevel > 0.25;

  Future<void> start() async {
    if (_isListening) return;
    try {
      _subscription = _noiseMeter.noise.listen(
        (reading) {
          final raw = reading.meanDecibel;
          // Typical quiet room ≈ -40 dB, loud speech ≈ -10 dB.
          // Map [-60, -10] → [0, 1].
          final clamped  = raw.clamp(-60.0, -10.0);
          final normalised = (clamped + 60.0) / 50.0;
          _normalizedLevel = normalised.clamp(0.0, 1.0);
          notifyListeners();
        },
        onError: (e) {
          debugPrint('[Mic] Stream error: $e');
          _isListening = false;
          notifyListeners();
        },
      );
      _isListening = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[Mic] Failed to start: $e');
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription   = null;
    _isListening    = false;
    _normalizedLevel = 0.0;
    notifyListeners();
  }

  /// Stops without calling [notifyListeners].
  /// Use this inside [State.dispose] to avoid modifying providers
  /// during Flutter's tree-finalization phase.
  void stopQuietly() {
    _subscription?.cancel();
    _subscription   = null;
    _isListening    = false;
    _normalizedLevel = 0.0;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
