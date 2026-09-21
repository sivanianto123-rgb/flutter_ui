// import '../../utils/common_import.dart';

// class ModuleHeader extends StatelessWidget {
//   final String title;

//   const ModuleHeader({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     final shortestSide = MediaQuery.of(context).size.shortestSide;

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: shortestSide * 0.04),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Navigator.of(context).pop(),
//                 child: Text(
//                   'x',
//                   style: AppFonts.w700primaryText58.copyWith(
//                     fontSize: shortestSide * 0.035,
//                   ),
//                 ),
//               ),
//               SizedBoxesHorizontal.sizedBox8,
//               Expanded(
//                 child: Container(
//                   height: 2,
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryText,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBoxesVertical.sizedBox4,
//           Text(
//             title,
//             style: AppFonts.w500primaryText16.copyWith(
//               fontSize: shortestSide * 0.025,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:mave/utils/common_import.dart';

class ModuleHeader extends StatelessWidget {
  final String title;
  final double progress;
  final VoidCallback? onClose;

  const ModuleHeader({
    super.key,
    required this.title,
    required this.progress,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    return Container(
      color: AppColors.secondaryAppColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(shortestSide * 0.03),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onClose,
                    child: Text(
                      'X',
                      style: AppFonts.boldPrimaryText.copyWith(
                        fontSize: shortestSide * 0.04,
                      ),
                    ),
                  ),
                  SizedBoxesHorizontal.sizedBox16,
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: AppColors.primaryText,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.progressBarFill,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBoxesVertical.sizedBox8,
              Text(
                title,
                style: AppFonts.w700primaryText58.copyWith(
                  fontSize: shortestSide * 0.04,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// icon bold - weight is not working 
// the container dimensions are wrong 
// page roughting back again which shouldnt happen 
//