import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import '../utils/common_imports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.5);
  int _currentIndex = 0;

  final List<Map<String, dynamic>> levels = [
    {'label': 'First Sounds', 'isUnlocked': true, 'progress': 0.4},
    {'label': 'Long Sounds', 'isUnlocked': false, 'progress': 0.0},
    {'label': 'Combinations', 'isUnlocked': false, 'progress': 0.0},
    {'label': 'Words', 'isUnlocked': false, 'progress': 0.0},
    {'label': 'Sentences', 'isUnlocked': false, 'progress': 0.0},
  ];

  void _onLevelTap(int index) {
    if (!levels[index]['isUnlocked']) return;
    debugPrint('Opening level: ${levels[index]['label']}');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.shortestSide;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DotLottieLoader.fromAsset(
              'lib/assets/animations/back.lottie',
              frameBuilder: (ctx, dotLottie) {
                if (dotLottie != null) {
                  return Lottie.memory(
                    dotLottie.animations.values.single,
                    fit: BoxFit.cover,
                    repeat: false,
                    animate: true,
                  );
                }
                return Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.purpleGradient,
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.08),

                SizedBox(
                  height: 280,
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: false,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double scale = 1.0;
                          if (_pageController.position.haveDimensions) {
                            double page = _pageController.page ?? 0;
                            scale = (1 - (page - index).abs() * 0.15).clamp(
                              0.85,
                              1.0,
                            );
                          }
                          return Align(
                            alignment: Alignment.center,
                            child: Transform.scale(
                              scale: scale,
                              child: _buildCard(index, s),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(levels.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? AppColors.buttonPrimary
                            : AppColors.textWhite.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const Spacer(),

                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.06),
                  child: Center(
                    child: Text(
                      "Let's Learn with Mave",
                      style: AppFonts.heading3.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.accentPurple,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index, double s) {
    final level = levels[index];
    final bool isUnlocked = level['isUnlocked'];
    final double progress = level['progress'];

    return GestureDetector(
      onTap: () => _onLevelTap(index),
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 16),
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.progressGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: isUnlocked
                            ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'lib/assets/images/cha_1.png',
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Icon(
                                Icons.lock,
                                size: 30,
                                color: Colors.grey.shade400,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      level['label'],
                      style: AppFonts.cardTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.buttonPrimary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text('start', style: AppFonts.button),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'locked',
                              style: AppFonts.bodySmall.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
