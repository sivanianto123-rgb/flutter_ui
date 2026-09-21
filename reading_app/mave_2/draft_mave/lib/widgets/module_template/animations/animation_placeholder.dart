// // import '../../utils/common_import.dart';

// // class AnimationPlaceholder extends StatelessWidget {
// //   const AnimationPlaceholder({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final shortestSide = MediaQuery.of(context).size.shortestSide;

// //     return Container(
// //       width: shortestSide * 0.4,
// //       height: shortestSide * 0.3,
// //       decoration: BoxDecoration(
// //         color: AppColors.secondaryAppColor.withValues(alpha: 0.5),
// //         borderRadius: BorderRadius.circular(16),
// //       ),
// //       child: Center(
// //         child: Text(
// //           'Animation',
// //           style: AppFonts.w600primaryText36.copyWith(
// //             fontSize: shortestSide * 0.04,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:mave/utils/common_import.dart';

// class AnimationPlaceholder extends StatelessWidget {
//   const AnimationPlaceholder({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final shortestSide = MediaQuery.of(context).size.shortestSide;

//     return Container(
//       height: shortestSide * 0.15,
//       decoration: BoxDecoration(
//         color: AppColors.secondaryAppColor.withValues(alpha: 0.3),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.secondaryAppColor, width: 2),
//       ),
//       child: Center(
//         child: Text(
//           'Animation',
//           style: AppFonts.w500primaryText16.copyWith(
//             fontSize: shortestSide * 0.03,
//             color: AppColors.primaryText.withValues(alpha: 0.5),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';

import '../../../utils/common_import.dart';

class AnimationHolder extends StatelessWidget {
  final String? currentWord;

  const AnimationHolder({super.key, this.currentWord});

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.shortestSide;

    if (currentWord?.toLowerCase() != 'ball') {
      return const SizedBox();
    }

    return SizedBox(
      width: s * 0.5,
      height: s * 0.5,
      child: DotLottieLoader.fromAsset(
        'lib/assets/animations/ball.lottie',
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
    );
  }
}
