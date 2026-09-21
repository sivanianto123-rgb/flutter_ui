import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import '../utils/common_imports.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      setState(() {
        _opacity = 0.0;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.shortestSide;

    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _opacity,
        curve: Curves.easeInOut,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(gradient: AppColors.purpleGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: s * 0.6,
                  height: s * 0.6,
                  child: DotLottieLoader.fromAsset(
                    'lib/assets/animations/splash_animation.lottie',
                    frameBuilder: (ctx, dotLottie) {
                      if (dotLottie != null) {
                        return Lottie.memory(
                          dotLottie.animations.values.single,
                          fit: BoxFit.contain,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                SizedBox(height: s * 0.05),
                Text('MAVE', style: AppFonts.splashTitle),
                SizedBox(height: s * 0.02),
                Text('Start Your Journey', style: AppFonts.splashSubtitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
