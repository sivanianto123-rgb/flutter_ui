import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/providers/child_performance_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../consonant_zone/consonant_zone_screen.dart';
import '../phonics/phonics_wheel_screen.dart';
import '../sentence_zone/sentence_zone_screen.dart';
import '../settings/settings_sheet.dart';
import '../vowel_zone/vowel_zone_screen.dart';
import '../word_zone/word_zone_screen.dart';
import 'platformer_map_painter.dart';

// ─── Home Screen ──────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final name = profile?.name ?? 'Explorer';
    final settings = ref.watch(appSettingsProvider);
    final performance =
        ref.watch(childPerformanceProvider).value ?? const ChildPerformance();
    final unlockedLevelCount = performance.sentenceZoneUnlocked
        ? 5
        : performance.wordZoneUnlocked
            ? 4
            : performance.consonantZoneUnlocked
                ? 3
                : performance.vowelZoneUnlocked
                    ? 2
                    : 1;

    return Scaffold(
      body: Stack(
        children: [
          // ── Horizontal scrolling platformer map ────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final worldH = constraints.maxHeight;
              return SingleChildScrollView(
                controller: _scrollCtrl,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: kWorldWidth,
                  height: worldH,
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: PlatformerMapPainter(
                          worldH,
                          isDarkMode: settings.isDarkMode,
                          unlockedLevelCount: unlockedLevelCount,
                        ),
                        size: Size(kWorldWidth, worldH),
                      ),
                      // ── Island 0: Phonics Zone ──────────────────────────
                      _IslandTap(
                        left: 235,
                        top: worldH * 0.72 - 95,
                        width: 90,
                        height: 95,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PhonicsWheelScreen(),
                          ),
                        ),
                      ),
                      // ── Island 1: Vowel Zone ────────────────────────────
                      _IslandTap(
                        left: 560,
                        top: worldH * 0.61 - 95,
                        width: 110,
                        height: 95,
                        locked: !performance.vowelZoneUnlocked,
                        lockedMessage: 'Complete Phonics Zone to unlock Vowel Zone.',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VowelZoneScreen(),
                          ),
                        ),
                      ),
                      // ── Island 2: Consonant Zone ────────────────────────
                      _IslandTap(
                        left: 930,
                        top: worldH * 0.50 - 90,
                        width: 120,
                        height: 95,
                        locked: !performance.consonantZoneUnlocked,
                        lockedMessage: 'Complete Vowel Zone to unlock Consonant Zone.',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ConsonantZoneScreen(),
                          ),
                        ),
                      ),
                      // ── Island 3: Word Zone ─────────────────────────────
                      _IslandTap(
                        left: 1300,
                        top: worldH * 0.66 - 95,
                        width: 130,
                        height: 95,
                        locked: !performance.wordZoneUnlocked,
                        lockedMessage: 'Complete Consonant Zone to unlock Word Zone.',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const WordZoneScreen(),
                          ),
                        ),
                      ),
                      // ── Island 4: Sentence Zone ─────────────────────────
                      _IslandTap(
                        left: 1620,
                        top: worldH * 0.44 - 95,
                        width: 110,
                        height: 95,
                        locked: !performance.sentenceZoneUnlocked,
                        lockedMessage: 'Score well in Word Zone to unlock Sentences Zone.',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SentenceZoneScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── Top gradient scrim (header legibility) ─────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  // App logo pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'mave',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hi, $name!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0x88000000),
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Scroll to explore your path →',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                            shadows: const [
                              Shadow(
                                color: Color(0x66000000),
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile avatar
                  _AvatarBadge(
                    name: name,
                    progress: performance.overallProgress,
                    onTap: () =>
                        _showChildProfileSheet(context, name, performance),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => showAppSettingsSheet(context, ref),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      child: const Icon(
                        Icons.settings,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),
            ),
          ),

          // ── Bottom scroll hint ─────────────────────────────────────────────
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Center(child: _ScrollHint(controller: _scrollCtrl)),
          ),
        ],
      ),
    );
  }
}

// ─── Scroll hint arrow ────────────────────────────────────────────────────────

class _ScrollHint extends StatelessWidget {
  const _ScrollHint({required this.controller});
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (_, __) {
        final atEnd =
            controller.hasClients &&
            controller.offset >= controller.position.maxScrollExtent - 20;
        return Opacity(
          opacity: atEnd ? 0.0 : 1.0,
          child:
              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Scroll to explore',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 800.ms)
                  .then()
                  .fadeOut(duration: 800.ms),
        );
      },
    );
  }
}

// ─── Profile avatar badge ─────────────────────────────────────────────────────

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.name,
    required this.progress,
    required this.onTap,
  });
  final String name;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final progressText = '${(progress * 100).round()}%';
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5A7DFF), Color(0xFF8BC34A)],
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -4,
            bottom: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Text(
                progressText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4E342E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showChildProfileSheet(
  BuildContext context,
  String name,
  ChildPerformance perf,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF102B52),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final reading = (perf.readingSkill * 100).round();
      final sound = (perf.soundAccuracy * 100).round();
      final listening = (perf.listeningSkill * 100).round();
      final word = (perf.wordAccuracy * 100).round();
      final sentence = (perf.sentenceAccuracy * 100).round();
      final overall = (perf.overallProgress * 100).round();
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$name's Skills",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _SkillRow(label: 'Reading', value: reading),
              _SkillRow(label: 'Sound Match', value: sound),
              _SkillRow(label: 'Story Listening', value: listening),
              _SkillRow(label: 'Word Zone', value: word),
              _SkillRow(label: 'Sentence Zone', value: sentence),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Overall Progress: $overall%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label  $value%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD54F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Island tap area ─────────────────────────────────────────────────────────

class _IslandTap extends StatelessWidget {
  const _IslandTap({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.onTap,
    this.locked = false,
    this.lockedMessage,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final VoidCallback onTap;
  final bool locked;
  final String? lockedMessage;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: locked
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lockedMessage ?? 'Complete the previous zone first.'),
                  ),
                );
              }
            : onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
