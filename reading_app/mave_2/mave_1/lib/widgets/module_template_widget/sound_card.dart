// import '../../../Utils/Common_imports/common_imports.dart';

// class SoundCard extends StatefulWidget {
//   final String sound;
//   final VoidCallback onTap;
//   final bool isActive;

//   SoundCard({required this.sound, required this.onTap, this.isActive = true});

//   @override
//   State<SoundCard> createState() => _SoundCardState();
// }

// class _SoundCardState extends State<SoundCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _breathController;
//   late Animation<double> _breathAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _setupBreathAnimation();
//   }

//   void _setupBreathAnimation() {
//     _breathController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1500),
//     );
//     _breathAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
//       CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
//     );
//     if (widget.isActive) _breathController.repeat(reverse: true);
//   }

//   @override
//   void didUpdateWidget(SoundCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isActive && !_breathController.isAnimating) {
//       _breathController.repeat(reverse: true);
//     } else if (!widget.isActive && _breathController.isAnimating) {
//       _breathController.stop();
//       _breathController.reset();
//     }
//   }

//   @override
//   void dispose() {
//     _breathController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _breathAnimation,
//       builder: (context, child) {
//         double breathScale = widget.isActive ? _breathAnimation.value : 1.0;
//         return Transform.scale(scale: breathScale, child: child);
//       },
//       child: AnimatedScale(
//         scale: widget.isActive ? 1.0 : 0.8,
//         duration: Duration(milliseconds: 400),
//         curve: Curves.easeOutCubic,
//         child: AnimatedOpacity(
//           duration: Duration(milliseconds: 400),
//           opacity: widget.isActive ? 1.0 : 0.5,
//           child: _buildCard(),
//         ),
//       ),
//     );
//   }

//   Widget _buildCard() {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         width: 342,
//         height: 95,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(45),
//           border: Border.all(color: Color(0xFFCCA7DA), width: 9),
//           image: DecorationImage(
//             image: AssetImage('lib/assets/images/module_background.jpg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(child: Text(widget.sound, style: AppFonts.primaryText())),
//       ),
//     );
//   }
// }
