// import 'dart:math' as math;

// import '../../utils/common_import.dart';

// class GradientTextBackground extends StatelessWidget {
//   final String phonicSound;

//   const GradientTextBackground({super.key, required this.phonicSound});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final random = math.Random(phonicSound.hashCode);

//     return Stack(
//       children: List.generate(8, (index) {
//         final x = random.nextDouble() * size.width;
//         final y = random.nextDouble() * size.height * 0.7;
//         final rotation = (random.nextDouble() - 0.5) * 0.5;
//         final scale = 0.8 + random.nextDouble() * 0.4;

//         return Positioned(
//           left: x,
//           top: y,
//           child: Transform(
//             transform:
//                 Matrix4.identity()
//                   ..rotateZ(rotation)
//                   ..scale(scale),
//             child: ShaderMask(
//               shaderCallback:
//                   (bounds) => LinearGradient(
//                     colors: GradientColors.transformGradient,
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ).createShader(bounds),
//               child: Text(
//                 phonicSound,
//                 style: AppFonts.w700white106.copyWith(
//                   fontSize: size.shortestSide * 0.12,
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
