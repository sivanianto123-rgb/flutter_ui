import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/services/ai_story_service.dart';
import '../shared/cartoon_progress_bar.dart';
import 'phonics_forest_background.dart';
import 'phonics_story_book_game.dart';

class PhonicsStoryScreen extends StatefulWidget {
  const PhonicsStoryScreen({super.key, required this.sound});
  final String sound;

  @override
  State<PhonicsStoryScreen> createState() => _PhonicsStoryScreenState();
}

class _PhonicsStoryScreenState extends State<PhonicsStoryScreen> {
  final _service = AiStoryService();
  late final Future<GeneratedStory> _storyFuture;
  final PhonicsStoryBookGame _bookGame = PhonicsStoryBookGame();
  Timer? _pageTimer;
  int _pageIndex = 0;
  int _storySessionId = 0;
  bool _storyInitialized = false;
  GeneratedStory? _cachedStory;
  List<String> _cachedPages = const [];

  void _goToCheckpoint(int checkpoint) {
    if (checkpoint >= 2) return;
    final pops = 2 - checkpoint;
    for (int i = 0; i < pops; i++) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _storyFuture = _service.generateForSound(widget.sound);
  }

  @override
  void dispose() {
    _pageTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutoPage(List<String> pages, int sessionId) {
    _pageTimer?.cancel();
    if (_pageIndex >= pages.length - 1) return;
    final text = pages[_pageIndex];
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final seconds = (4 + (words * 0.32)).clamp(6, 14).toDouble();
    _pageTimer = Timer(Duration(milliseconds: (seconds * 1000).round()), () {
      if (!mounted || sessionId != _storySessionId) return;
      if (_pageIndex < pages.length - 1) {
        _pageIndex += 1;
        _showCurrentPage();
      }
      _scheduleAutoPage(pages, sessionId);
    });
  }

  void _initAutoPagingFor(List<String> pages) {
    if (_storySessionId != 0) return;
    _storySessionId = DateTime.now().microsecondsSinceEpoch;
    _pageIndex = 0;
    _showCurrentPage();
    _scheduleAutoPage(pages, _storySessionId);
  }

  void _showCurrentPage() {
    if (_cachedStory == null || _cachedPages.isEmpty) return;
    final maxPage = _cachedPages.length - 1;
    final pageText = _cachedPages[_pageIndex.clamp(0, maxPage)];
    _bookGame.setPageBody(pageText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const PhonicsForestBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StoryProgressBar(
                          label: 'Activity 3 of 3',
                          value: 1.0,
                          currentCheckpoint: 2,
                          onCheckpointTap: _goToCheckpoint,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        icon: const Icon(Icons.home_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.30),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                const Text(
                  'Story Time',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    fontFamilyFallback: ['Comic Sans MS', 'Marker Felt', 'Chalkboard SE'],
                    shadows: [Shadow(color: Color(0xAA000000), blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<GeneratedStory>(
                      future: _storyFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Color(0xFFFFD54F)),
                                SizedBox(height: 10),
                                Text(
                                  'Generating AI story...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final story = snapshot.data!;
                        final pages = <String>[
                          ...story.paragraphs,
                        ];
                        if (!_storyInitialized) {
                          _storyInitialized = true;
                          _cachedStory = story;
                          _cachedPages = pages;
                          _initAutoPagingFor(pages);
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: GameWidget(game: _bookGame),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryProgressBar extends StatelessWidget {
  const _StoryProgressBar({
    required this.label,
    required this.value,
    required this.currentCheckpoint,
    required this.onCheckpointTap,
  });
  final String label;
  final double value;
  final int currentCheckpoint;
  final ValueChanged<int> onCheckpointTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => CartoonProgressBar(
        value: v,
        height: 28,
        checkpointCount: 3,
        currentCheckpoint: currentCheckpoint,
        onCheckpointTap: onCheckpointTap,
      ),
    );
  }
}
