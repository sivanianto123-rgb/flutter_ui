// import '../../utils/common_import.dart';

// class WordDisplay extends StatefulWidget {
//   final String sound;
//   final String? ending;

//   const WordDisplay({super.key, required this.sound, this.ending});

//   @override
//   State<WordDisplay> createState() => _WordDisplayState();
// }

// class _WordDisplayState extends State<WordDisplay>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _opacityAnimation;
//   String? _displayEnding;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.5,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

//     _opacityAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
//   }

//   @override
//   void didUpdateWidget(WordDisplay oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.ending != null && widget.ending != oldWidget.ending) {
//       _displayEnding = widget.ending;
//       _controller.forward(from: 0);

//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           _controller.reverse();
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final s = MediaQuery.of(context).size.shortestSide;

//     return SizedBox(
//       width: s * 0.55,
//       height: s * 0.25,
//       child: Center(
//         child: AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             if (_displayEnding == null) {
//               return Text(
//                 widget.sound,
//                 style: GoogleFonts.fredoka(
//                   fontSize: 106,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.moduleCircleStroke,
//                 ),
//               );
//             }

//             return Transform.scale(
//               scale: _scaleAnimation.value,
//               child: Opacity(
//                 opacity: _opacityAnimation.value.clamp(0.0, 1.0),
//                 child: RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: widget.sound,
//                         style: GoogleFonts.fredoka(
//                           fontSize: 106,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.moduleCircleStroke,
//                         ),
//                       ),
//                       TextSpan(
//                         text: _displayEnding,
//                         style: GoogleFonts.fredoka(
//                           fontSize: 106,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.primaryText,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
