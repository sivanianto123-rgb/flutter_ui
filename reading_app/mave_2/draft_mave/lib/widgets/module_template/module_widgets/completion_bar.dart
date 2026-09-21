// import '../../utils/common_import.dart';

// class CompletionBar extends StatelessWidget {
//   final double progress;

//   const CompletionBar({super.key, required this.progress});

//   @override
//   Widget build(BuildContext context) {
//     final shortestSide = MediaQuery.of(context).size.shortestSide;
//     final barWidth = shortestSide * 0.4;
//     final barHeight = shortestSide * 0.06;

//     return Container(
//       width: barWidth,
//       height: barHeight,
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(barHeight / 2),
//       ),
//       child: Stack(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             width: barWidth * progress,
//             height: barHeight,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   GradientColors.starGradient[0],
//                   GradientColors.starGradient[0].withValues(alpha: 0.7),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(barHeight / 2),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:mave/utils/common_import.dart';

class CompletionBar extends StatelessWidget {
  final double progress;

  const CompletionBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 12,
        backgroundColor: AppColors.primaryText,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.progressBarFill),
      ),
    );
  }
}
