// import '../../utils/common_import.dart';

// class WordRoll extends StatefulWidget {
//   final String sound;

//   const WordRoll({super.key, required this.sound});

//   @override
//   State<WordRoll> createState() => _WordRollState();
// }

// class _WordRollState extends State<WordRoll>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   int _currentIndex = 0;

//   List<String> get _sentences => _getSentences(widget.sound);

//   List<String> _getSentences(String sound) {
//     final s = sound.toLowerCase();
//     final cap = sound[0].toUpperCase() + sound.substring(1).toLowerCase();

//     switch (s) {
//       case 'ba':
//         return [
//           "Let's start with the sound $cap.",
//           "Listen carefully... $cap....... $cap....... $cap",
//           "Can you say $cap? $s......$cap...... $cap",
//           "Great job! One more time.....$s.....$s......$cap",
//         ];
//       case 'ma':
//         return [
//           "Let's learn the sound $cap.",
//           "Listen closely... $cap....... $cap....... $cap",
//           "Try saying $cap? $s......$cap...... $cap",
//           "Wonderful! Again.....$s.....$s......$cap",
//         ];
//       case 'da':
//         return [
//           "Now let's try $cap.",
//           "Hear it... $cap....... $cap....... $cap",
//           "Your turn! $cap? $s......$cap...... $cap",
//           "Excellent! Once more.....$s.....$s......$cap",
//         ];
//       case 'ga':
//         return [
//           "Time for the sound $cap.",
//           "Listen... $cap....... $cap....... $cap",
//           "Say it! $cap? $s......$cap...... $cap",
//           "Amazing! Try again.....$s.....$s......$cap",
//         ];
//       case 'na':
//         return [
//           "Let's practice $cap.",
//           "Hear this... $cap....... $cap....... $cap",
//           "Can you do it? $cap? $s......$cap...... $cap",
//           "Great! One more.....$s.....$s......$cap",
//         ];
//       case 'wa':
//         return [
//           "Last one! The sound $cap.",
//           "Listen well... $cap....... $cap....... $cap",
//           "Now you try! $cap? $s......$cap...... $cap",
//           "Perfect! Final time.....$s.....$s......$cap",
//         ];
//       default:
//         return [
//           "Let's learn $cap.",
//           "Listen... $cap....... $cap",
//           "Say $cap!",
//           "Great job!",
//         ];
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _animation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//     _startRolling();
//   }

//   void _startRolling() async {
//     while (mounted) {
//       await Future.delayed(const Duration(seconds: 3));
//       if (!mounted) return;

//       await _controller.forward();
//       if (!mounted) return;

//       setState(() {
//         _currentIndex = (_currentIndex + 1) % _sentences.length;
//       });
//       _controller.reset();
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
//       child: ClipRRect(
//         child: AnimatedBuilder(
//           animation: _animation,
//           builder: (context, child) {
//             return Stack(
//               children: [
//                 _buildSentence(_sentences[_currentIndex], s, -_animation.value),
//                 _buildSentence(
//                   _sentences[(_currentIndex + 1) % _sentences.length],
//                   s,
//                   1 - _animation.value,
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSentence(String text, double s, double offset) {
//     return Positioned.fill(
//       child: Transform.translate(
//         offset: Offset(0, offset * s * 0.25),
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: s * 0.02),
//             child: Text(
//               text,
//               style: AppFonts.w700primaryText58.copyWith(fontSize: s * 0.06),
//               textAlign: TextAlign.center,
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
