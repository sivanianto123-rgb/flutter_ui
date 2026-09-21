import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/helpers/phonetic_helper.dart';
import '../../../core/services/app_providers.dart';

// ── Word data ─────────────────────────────────────────────────────────────────

class _Word {
  const _Word({
    required this.text,
    required this.emoji,
    required this.highlight, // the portion to colour (target phoneme position)
  });
  final String text;
  final String emoji;
  final String highlight; // substring to highlight in colour
}

// ── Screen ─────────────────────────────────────────────────────────────────────

/// Word Reading — the child reads aloud 2–3 letter words containing the
/// target phoneme.
///
/// Each word is displayed large with the target sound highlighted.
/// TTS reads the word first, then the mic listens for any vocalization.
/// Any sound → celebrate → next word.  4 words per session.
class WordReadingScreen extends ConsumerStatefulWidget {
  const WordReadingScreen({
    super.key,
    required this.syllable,
    required this.activityId,
    required this.onComplete,
    required this.onExit,
  });

  final String syllable;
  final String activityId;
  final VoidCallback onComplete;
  final VoidCallback onExit;

  @override
  ConsumerState<WordReadingScreen> createState() => _WordReadingScreenState();
}

class _WordReadingScreenState extends ConsumerState<WordReadingScreen>
    with SingleTickerProviderStateMixin {
  // ── Word lists ─────────────────────────────────────────────────────────────

  /// Words for 'ma' — the 'ma' phoneme is the highlight.
  static const _maWords = [
    _Word(text: 'MA',   emoji: '👄', highlight: 'MA'),
    _Word(text: 'MAP',  emoji: '🗺️', highlight: 'MA'),
    _Word(text: 'MAT',  emoji: '🧶', highlight: 'MA'),
    _Word(text: 'MAN',  emoji: '🧑', highlight: 'MA'),
    _Word(text: 'YAM',  emoji: '🍠', highlight: 'MA'),
    _Word(text: 'JAM',  emoji: '🍓', highlight: 'MA'),
  ];

  /// Words for 'pa' — the 'pa' phoneme is the highlight.
  static const _paWords = [
    _Word(text: 'PA',   emoji: '👐', highlight: 'PA'),
    _Word(text: 'PAN',  emoji: '🍳', highlight: 'PA'),
    _Word(text: 'PAT',  emoji: '✋', highlight: 'PA'),
    _Word(text: 'PAD',  emoji: '📒', highlight: 'PA'),
    _Word(text: 'TAP',  emoji: '🚰', highlight: 'PA'),
    _Word(text: 'CAP',  emoji: '🧢', highlight: 'PA'),
  ];

  static const int _wordsPerSession = 4;

  // ── State ──────────────────────────────────────────────────────────────────

  late final List<_Word> _words;
  int  _index        = 0;
  int  _readCount    = 0;     // successful vocalizations
  bool _listening    = false;
  bool _didRead      = false;  // child made a sound this word
  bool _complete     = false;
  bool _ttsPlaying   = false;

  Timer? _listenTimer;
  late final AnimationController _micPulseController;

  // Cached so dispose() can call stop() without using ref.
  late final MicrophoneController _mic;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _mic = ref.read(microphoneControllerProvider);

    _micPulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);

    // Pick 4 random words from the list.
    final pool = (widget.syllable == 'ma' ? _maWords : _paWords).toList()
      ..shuffle();
    _words = pool.take(_wordsPerSession).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) => _startWord());
  }

  @override
  void dispose() {
    _listenTimer?.cancel();
    _micPulseController.dispose();
    _mic.stop();
    super.dispose();
  }

  // ── Word flow ──────────────────────────────────────────────────────────────

  Future<void> _startWord() async {
    if (!mounted) return;
    setState(() {
      _listening = false;
      _didRead   = false;
      _ttsPlaying = true;
    });

    final word = _words[_index];
    final audio = ref.read(audioServiceProvider);

    // 1. Speak the word.
    try {
      await audio.speak(word.text);
      await audio.waitForCompletion(
          timeout: const Duration(seconds: 8));
    } catch (_) {}

    if (!mounted) return;
    setState(() => _ttsPlaying = false);

    // 2. Prompt child to repeat.
    try {
      await audio.speak('Now you say it! ${PhoneticHelper.toPhonetic(widget.syllable)}');
    } catch (_) {}

    if (!mounted) return;
    setState(() => _listening = true);

    // 3. Start mic and listen for vocalization.
    await _mic.start();

    // Auto-advance after 6 s if child doesn't speak.
    _listenTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted || _didRead) return;
      // Gently nudge and count as partial.
      _onRead(spoke: false);
    });

    // Poll for speaking.
    Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _complete || _didRead) { t.cancel(); return; }
      if (_mic.isSpeaking && _listening) {
        t.cancel();
        _onRead(spoke: true);
      }
    });
  }

  Future<void> _onRead({required bool spoke}) async {
    if (_didRead || !mounted) return;
    _listenTimer?.cancel();
    setState(() {
      _didRead   = true;
      _listening = false;
    });
    _mic.stop();

    final audio = ref.read(audioServiceProvider);

    if (spoke) {
      _readCount++;
      try {
        await audio.speak(PhoneticHelper.praiseFor(widget.syllable));
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    _index++;
    if (_index >= _wordsPerSession) {
      _finish();
    } else {
      _startWord();
    }
  }

  Future<void> _finish() async {
    setState(() => _complete = true);
    final accuracy = (_readCount / _wordsPerSession).clamp(0.0, 1.0);
    final levelNotifier = ref.read(levelProvider.notifier);
    final audio = ref.read(audioServiceProvider);

    await levelNotifier.record(widget.activityId, accuracy);
    if (!mounted) return;

    try {
      await audio.speak('You read all the words! Amazing reader!');
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onComplete();
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Manually replay TTS for the current word.
  Future<void> _replayWord() async {
    if (_ttsPlaying || _complete) return;
    final audio = ref.read(audioServiceProvider);
    try {
      setState(() => _ttsPlaying = true);
      await audio.speak(_words[_index].text);
      await audio.waitForCompletion(
          timeout: const Duration(seconds: 8));
    } catch (_) {} finally {
      if (mounted) setState(() => _ttsPlaying = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mic = ref.watch(microphoneControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FD),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              index: _index,
              total: _wordsPerSession,
              onBack: widget.onExit,
            ),

            const Spacer(),

            if (_complete) ...[
              const Text('🌟', style: TextStyle(fontSize: 90))
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 16),
              Text(
                'Amazing reader!',
                style: AppTextStyles.headlineLarge
                    .copyWith(color: AppColors.accentGreen),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // ── Word card ────────────────────────────────────────────────
              GestureDetector(
                onTap: _replayWord,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(
                      vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(50),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emoji
                      Text(
                        _words[_index].emoji,
                        style: const TextStyle(fontSize: 72),
                      )
                          .animate(key: ValueKey('emoji_$_index'))
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          ),

                      const SizedBox(height: 16),

                      // Word with phoneme highlighted
                      _HighlightedWord(
                        text:      _words[_index].text,
                        highlight: _words[_index].highlight,
                      ).animate(key: ValueKey('word_$_index')).fadeIn(duration: 300.ms),

                      const SizedBox(height: 12),

                      // Phonetic pronunciation hint
                      Text(
                        PhoneticHelper.toPhonetic(
                          _words[_index].text.toLowerCase()),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textMedium,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Tap to hear hint
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _ttsPlaying
                                ? Icons.volume_up_rounded
                                : Icons.touch_app_rounded,
                            size: 16,
                            color: AppColors.primary.withAlpha(160),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _ttsPlaying ? 'Listen...' : 'Tap to hear',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary.withAlpha(160),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Mic area ─────────────────────────────────────────────────
              if (_listening) ...[
                AnimatedBuilder(
                  animation: _micPulseController,
                  builder: (ctx, child) => Transform.scale(
                    scale: 1.0 + _micPulseController.value * 0.15,
                    child: child,
                  ),
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: mic.isSpeaking
                          ? AppColors.accentGreen.withAlpha(220)
                          : AppColors.primary.withAlpha(60),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: mic.isSpeaking
                            ? AppColors.accentGreen
                            : AppColors.primary,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      mic.isSpeaking
                          ? Icons.record_voice_over_rounded
                          : Icons.mic_rounded,
                      size: 44,
                      color: mic.isSpeaking
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  mic.isSpeaking ? 'Great! Keep going!' : 'Say the word!',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: mic.isSpeaking
                        ? AppColors.accentGreen
                        : AppColors.primary,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else if (_didRead) ...[
                const Icon(Icons.check_circle_rounded,
                    size: 72, color: AppColors.accentGreen)
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),
              ] else ...[
                Text(
                  _ttsPlaying ? 'Listen carefully...' : 'Get ready!',
                  style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textMedium),
                ),
              ],
            ],

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ── Highlighted word display ───────────────────────────────────────────────────

class _HighlightedWord extends StatelessWidget {
  const _HighlightedWord({required this.text, required this.highlight});
  final String text;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    // Build a RichText with the highlight portion in primary colour.
    final pattern = RegExp(RegExp.escape(highlight), caseSensitive: false);
    final spans   = <TextSpan>[];
    int cursor = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text:  text.substring(cursor, match.start),
          style: _baseStyle.copyWith(color: AppColors.textDark),
        ));
      }
      spans.add(TextSpan(
        text:  match.group(0),
        style: _baseStyle.copyWith(
          color:           AppColors.primary,
          shadows: [
            Shadow(
              color:      AppColors.primary.withAlpha(60),
              blurRadius: 12,
            ),
          ],
        ),
      ));
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(
        text:  text.substring(cursor),
        style: _baseStyle.copyWith(color: AppColors.textDark),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.center,
    );
  }

  static const _baseStyle = TextStyle(
    fontSize:   80,
    fontWeight: FontWeight.w900,
    letterSpacing: 8,
    height: 1.0,
  );
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.index, required this.total, required this.onBack});
  final int          index;
  final int          total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.textMedium),
                  const SizedBox(width: 4),
                  Text('Home',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text('Read with Me! 📖',
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${index + 1} / $total',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
