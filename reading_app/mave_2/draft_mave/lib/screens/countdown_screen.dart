// import 'package:mave/utils/common_import.dart';

// class CountdownScreen extends StatefulWidget {
//   final Widget destination;

//   const CountdownScreen({super.key, required this.destination});

//   @override
//   State<CountdownScreen> createState() => _CountdownScreenState();
// }

// class _CountdownScreenState extends State<CountdownScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _countdownController;
//   late AnimationController _swooshController;
//   late Animation<double> _swooshAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _opacityAnimation;
//   int _count = 3;

//   @override
//   void initState() {
//     super.initState();

//     _countdownController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
//       CurvedAnimation(parent: _countdownController, curve: Curves.easeOutBack),
//     );

//     _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _countdownController,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
//       ),
//     );

//     _swooshController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     _swooshAnimation = Tween<double>(
//       begin: -1.3,
//       end: 1.3,
//     ).animate(CurvedAnimation(parent: _swooshController, curve: Curves.linear));

//     _swooshController.repeat();
//     _startCountdown();
//   }

//   void _startCountdown() async {
//     for (int i = 3; i >= 1; i--) {
//       if (!mounted) return;
//       setState(() => _count = i);
//       _countdownController.forward(from: 0);
//       await Future.delayed(const Duration(seconds: 1));
//     }

//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         PageRouteBuilder(
//           pageBuilder:
//               (context, animation, secondaryAnimation) => widget.destination,
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(opacity: animation, child: child);
//           },
//           transitionDuration: const Duration(milliseconds: 300),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _countdownController.dispose();
//     _swooshController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final shortestSide = size.shortestSide;

//     return Scaffold(
//       backgroundColor: AppColors.secondaryAppColor,
//       body: Stack(
//         children: [
//           Center(child: _buildSwoosh(size, shortestSide)),
//           Center(child: _buildCountdown(shortestSide)),
//         ],
//       ),
//     );
//   }

//   Widget _buildCountdown(double shortestSide) {
//     return AnimatedBuilder(
//       animation: _countdownController,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Opacity(
//             opacity: _opacityAnimation.value.clamp(0.0, 1.0),
//             child: Text(
//               '$_count',
//               style: AppFonts.w700white106.copyWith(
//                 fontSize: shortestSide * 0.25,
//                 shadows: [
//                   Shadow(
//                     color: AppColors.black.withValues(alpha: 0.2),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSwoosh(Size size, double shortestSide) {
//     return AnimatedBuilder(
//       animation: _swooshAnimation,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(_swooshAnimation.value * size.width, 0),
//           child: Container(
//             width: size.width * 1.0,
//             height: shortestSide * 0.22,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color(0xFF8FD9EA),
//                   const Color(0xFF5BB5C3),
//                   const Color(0xFF3A9FB0),
//                 ],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.circular(shortestSide * 0.11),
//             ),
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: _buildSpeedLines(size, shortestSide),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<Widget> _buildSpeedLines(Size size, double shortestSide) {
//     final barWidth = size.width * 1.0;
//     final barHeight = shortestSide * 0.22;

//     final positions = [
//       {'top': 0.18, 'left': 0.08},
//       {'top': 0.42, 'left': 0.05},
//       {'top': 0.68, 'left': 0.10},
//       {'top': 0.28, 'left': 0.20},
//       {'top': 0.55, 'left': 0.18},
//       {'top': 0.78, 'left': 0.22},
//       {'top': 0.15, 'left': 0.35},
//       {'top': 0.45, 'left': 0.32},
//       {'top': 0.72, 'left': 0.38},
//       {'top': 0.22, 'left': 0.52},
//       {'top': 0.50, 'left': 0.48},
//       {'top': 0.75, 'left': 0.55},
//       {'top': 0.18, 'left': 0.68},
//       {'top': 0.42, 'left': 0.65},
//       {'top': 0.65, 'left': 0.72},
//       {'top': 0.25, 'left': 0.85},
//       {'top': 0.52, 'left': 0.82},
//       {'top': 0.78, 'left': 0.88},
//     ];

//     return positions.map((pos) {
//       return Positioned(
//         top: barHeight * pos['top']!,
//         left: barWidth * pos['left']!,
//         child: Container(
//           width: shortestSide * 0.05,
//           height: shortestSide * 0.01,
//           decoration: BoxDecoration(
//             color: AppColors.white.withValues(alpha: 0.85),
//             borderRadius: BorderRadius.circular(shortestSide * 0.005),
//           ),
//         ),
//       );
//     }).toList();
//   }
// }
// import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:lottie/lottie.dart';

import '../utils/common_import.dart';

class CountdownScreen extends StatefulWidget {
  final Widget destination;

  const CountdownScreen({super.key, required this.destination});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  bool _showLetsStart = false;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      setState(() {
        _showLetsStart = true;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => widget.destination,
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    return Scaffold(
      backgroundColor: AppColors.secondaryAppColor,
      body: Center(
        child:
            _showLetsStart
                ? _buildLetsStart(shortestSide)
                : _buildLottie(shortestSide),
      ),
    );
  }

  Widget _buildLottie(double shortestSide) {
    return SizedBox(
      width: shortestSide * 0.7,
      height: shortestSide * 0.7,
      child: DotLottieLoader.fromAsset(
        'lib/assets/animations/countdown_animation.lottie',
        frameBuilder: (ctx, dotLottie) {
          if (dotLottie != null) {
            return Lottie.memory(
              dotLottie.animations.values.single,
              controller: _lottieController,
              onLoaded: (composition) {
                _lottieController
                  ..duration = composition.duration
                  ..forward();
              },
              fit: BoxFit.contain,
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLetsStart(double shortestSide) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: Text(
              "Let's start!",
              style: AppFonts.w700white106.copyWith(
                fontSize: shortestSide * 0.12,
                shadows: [
                  Shadow(
                    color: AppColors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
