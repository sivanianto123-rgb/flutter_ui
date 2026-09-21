import 'dart:async';
import '../../utils/common_imports/common_imports.dart';
import '../../widgets/sound_widgets/animated_word.dart';
import '../../widgets/sound_widgets/sound_lottie.dart';
import '../../widgets/sound_widgets/koala_challenge/koala_challenge.dart';
import '../../widgets/back_button.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

const _kBubbleDecoration = BoxDecoration(
  color: Color(0xDFD9D9D9),
  borderRadius: BorderRadius.all(Radius.circular(50)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFCCA7DA), width: 6)),
);

// Lenient match alternatives for toddler/baby speech patterns.
// Keys are the canonical sound name; values are accepted approximations.
const _kAlternatives = <String, List<String>>{
  'mama': ['ma', 'mom', 'mum', 'mommy', 'mamma'],
  'papa': ['pa', 'pop', 'pap', 'poppy', 'daddy'],
  'dada': ['da', 'dad', 'daddy', 'dah'],
  'baba': ['ba', 'bob', 'bab', 'baby'],
  'ooo': ['o', 'oh', 'ooh', 'oo', 'who'],
  'eee': ['e', 'ee', 'eh', 'he', 'hee', 'yeah'],
  'aaaa': ['a', 'aa', 'ah', 'aah', 'ha'],
  'moo': ['mu', 'muu', 'mooo', 'mow'],
  'woof': ['wuf', 'wof', 'oof', 'ruff'],
  'coo': ['cu', 'co', 'coup'],
  'quack': ['quak', 'kwak', 'quac', 'kwack'],
  'hiss': ['his', 'hisss', 'iss'],
};

// How long the mic stays open each round.
const _kListenDuration = Duration(seconds: 5);

// Max play-and-listen rounds before auto-advancing to the challenge.
const _kMaxRounds = 3;

class SoundScreen extends StatefulWidget {
  final SoundData soundData;

  const SoundScreen({super.key, required this.soundData});

  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  int _currentSyllableIndex = 0;
  bool _isAnimating = false;
  bool _showKoalaChallenge = false;
  bool _isCorrect = false;
  bool _isDisposed = false;
  bool _isNavigating = false;
  int _roundCount = 0;

  Soundpool? _soundpool;
  int? _soundId;
  int? _streamId;

  final SpeechToText _stt = SpeechToText();
  bool _sttAvailable = false;
  bool _isListening = false;

  double? _cachedScreenHeight;

  // Total animation duration: 500 ms per syllable + 500 ms trailing pause.
  int get _audioDurationMs => widget.soundData.syllables.length * 500 + 500;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('lib/assets/images/sound_bg.jpg'), context);
    _cachedScreenHeight = MediaQuery.sizeOf(context).height;
  }

  // ─── Initialisation ──────────────────────────────────────────────────────

  Future<void> _initAll() async {
    // Load audio and initialise STT in parallel so startup is faster.
    await Future.wait([_initAudio(), _initStt()]);

    if (mounted && !_isDisposed) {
      await Future.delayed(const Duration(milliseconds: 300));
      _runLoop();
    }
  }

  Future<void> _initAudio() async {
    if (widget.soundData.audioPath.isEmpty) return;
    try {
      _soundpool = Soundpool.fromOptions(
        options: const SoundpoolOptions(streamType: StreamType.music),
      );
      final data = await rootBundle.load(widget.soundData.audioPath);
      _soundId = await _soundpool!.load(data);
    } catch (_) {}
  }

  Future<void> _initStt() async {
    try {
      _sttAvailable = await _stt.initialize(
        onError: (_) {},
        onStatus: (status) {
          if (!mounted || _isDisposed) return;
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );
    } catch (_) {
      _sttAvailable = false;
    }
  }

  // ─── Main loop ────────────────────────────────────────────────────────────

  // Each round:
  //   1. Play audio + animate syllables (audio session = playback only).
  //   2. Wait for audio to finish and for the audio session to settle.
  //   3. Open mic and listen for _kListenDuration (audio session = record only).
  //   4. If match → KoalaChallenge (happy koala).
  //   5. If no match and more rounds remain → repeat.
  //   6. If no match after _kMaxRounds → KoalaChallenge anyway (sad koala).
  //
  // Audio and mic are intentionally never active at the same time, which
  // prevents the AVAudioSession conflict that caused lag on iOS.
  Future<void> _runLoop() async {
    if (_isDisposed || _showKoalaChallenge) return;

    _roundCount++;

    // 1 & 2: Play audio and animate.  No mic is open during this phase.
    _playAudioAndAnimate();
    await Future.delayed(Duration(milliseconds: _audioDurationMs));
    if (_isDisposed || _showKoalaChallenge) return;

    // Short settling pause before switching audio session to record.
    await Future.delayed(const Duration(milliseconds: 200));
    if (_isDisposed || _showKoalaChallenge) return;

    // 3: Open mic.  No audio playback during this phase.
    await _listenForMatch();
    if (_isDisposed || _showKoalaChallenge) return;

    // 5: Auto-advance after enough failed rounds.
    if (_roundCount >= _kMaxRounds) {
      _goToKoalaChallenge(correct: false);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (!_isDisposed && !_showKoalaChallenge) _runLoop();
  }

  // ─── Speech recognition ──────────────────────────────────────────────────

  // Opens the mic for [_kListenDuration].  Calls _goToKoalaChallenge on match.
  // If STT is unavailable the method waits the same duration so loop timing
  // stays consistent.
  Future<void> _listenForMatch() async {
    if (_isDisposed) return;

    if (!_sttAvailable) {
      // No mic available: wait the same window so auto-advance timing is sane.
      await Future.delayed(_kListenDuration);
      return;
    }

    final completer = Completer<void>();

    _isListening = true;
    _stt.listen(
      onResult: (result) {
        if (_isDisposed || _showKoalaChallenge || completer.isCompleted) return;
        if (_isMatch(result.recognizedWords)) {
          // Match found: stop mic before touching UI state.
          _isListening = false;
          try {
            _stt.stop();
          } catch (_) {}
          if (!_isDisposed && !_showKoalaChallenge) {
            _goToKoalaChallenge(correct: true);
          }
          if (!completer.isCompleted) completer.complete();
        }
      },
      listenFor: _kListenDuration,
      // Stop after 3 s of silence so we don't hold the mic open needlessly.
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );

    // Wait for a match or the listen window to expire.
    await Future.any([
      completer.future,
      Future.delayed(_kListenDuration),
    ]);

    if (!completer.isCompleted) completer.complete();

    // Always clean up the mic before returning.
    if (_isListening) {
      _isListening = false;
      try {
        _stt.stop();
      } catch (_) {}
    }
  }

  void _stopListening() {
    if (!_isListening) return;
    _isListening = false;
    try {
      _stt.stop();
    } catch (_) {}
  }

  // Lenient matching: accept the canonical name, any listed alternative, or
  // any individual syllable.  Works well for toddler approximations.
  bool _isMatch(String recognized) {
    if (recognized.isEmpty) return false;
    final input = recognized.toLowerCase().trim();
    final target = widget.soundData.name.toLowerCase();

    if (input.contains(target)) return true;

    for (final alt in (_kAlternatives[target] ?? [])) {
      if (input.contains(alt)) return true;
    }

    for (final syl in widget.soundData.syllables) {
      if (input.contains(syl.toLowerCase())) return true;
    }

    return false;
  }

  // ─── Audio playback ───────────────────────────────────────────────────────

  void _playAudioAndAnimate() {
    if (_isDisposed) return;
    _safeSetState(() {
      _isAnimating = true;
      _currentSyllableIndex = 0;
    });
    _playAudio();
  }

  Future<void> _playAudio() async {
    if (_isDisposed || _soundpool == null || _soundId == null) return;
    try {
      _streamId = await _soundpool!.play(_soundId!);
    } catch (_) {}
  }

  // ─── UI callbacks ─────────────────────────────────────────────────────────

  void _onSyllableComplete() {
    if (_isDisposed) return;
    if (_currentSyllableIndex < widget.soundData.syllables.length - 1) {
      _safeSetState(() => _currentSyllableIndex++);
    } else {
      _safeSetState(() => _isAnimating = false);
    }
  }

  Future<void> _onScreenTap() async {
    if (_showKoalaChallenge || _isAnimating) return;
    _playAudioAndAnimate();
  }

  void _goToKoalaChallenge({required bool correct}) {
    if (_isDisposed || _showKoalaChallenge) return;
    _stopListening();
    _safeSetState(() {
      _showKoalaChallenge = true;
      _isCorrect = correct;
    });
  }

  void _onKoalaComplete() {
    // Always end with the happy koala before navigating back.
    _safeSetState(() => _isCorrect = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isDisposed && !_isNavigating) {
        _onBack(completed: true);
      }
    });
  }

  Future<void> _onBack({bool completed = false}) async {
    if (_isNavigating || _isDisposed) return;
    _isNavigating = true;
    _stopListening();
    try {
      if (_streamId != null && _streamId! > 0) {
        await _soundpool?.stop(_streamId!);
      }
    } catch (_) {}
    if (mounted) Navigator.pop(context, completed);
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) setState(fn);
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _isDisposed = true;
    _stopListening();
    _soundpool?.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_isNavigating) _onBack(completed: false);
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: _onScreenTap,
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const RepaintBoundary(child: _BackgroundImage()),
                SafeArea(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _showKoalaChallenge
                        ? KoalaChallenge(
                            key: const ValueKey('koala'),
                            sound: widget.soundData.name,
                            isCorrect: _isCorrect,
                            onComplete: _onKoalaComplete,
                            onBack: () => _onBack(completed: false),
                          )
                        : _buildWordAnimation(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordAnimation() {
    final screenHeight =
        _cachedScreenHeight ?? MediaQuery.sizeOf(context).height;

    return Column(
      key: const ValueKey('word'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AppBackButton(onPressed: () => _onBack(completed: false)),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Container(
          width: 400,
          height: 120,
          decoration: _kBubbleDecoration,
          child: Center(
            child: AnimatedWord(
              syllables: widget.soundData.syllables,
              currentIndex: _currentSyllableIndex,
              isAnimating: _isAnimating,
              onSyllableComplete: _onSyllableComplete,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: RepaintBoundary(
              child: SoundLottie(animationPath: widget.soundData.animationPath),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.05),
      ],
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/images/sound_bg.jpg',
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}
