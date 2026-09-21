// import '../../../Utils/Common_imports/common_imports.dart';
// import 'sound_card.dart';

// class SoundCarousel extends StatefulWidget {
//   final List<String> sounds;
//   final Function(int) onSoundTap;

//   SoundCarousel({required this.sounds, required this.onSoundTap});

//   @override
//   State<SoundCarousel> createState() => _SoundCarouselState();
// }

// class _SoundCarouselState extends State<SoundCarousel> {
//   int _currentIndex = 0;
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(viewportFraction: 0.6);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _goUp() {
//     if (_currentIndex > 0) {
//       _pageController.previousPage(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _goDown() {
//     if (_currentIndex < widget.sounds.length - 1) {
//       _pageController.nextPage(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 400,
//       height: 420,
//       child: Column(
//         children: [
//           _buildArrowButton('lib/assets/icons/up.png', _goUp),
//           SizedBox(height: 10),
//           Expanded(child: _buildCarousel()),
//           SizedBox(height: 10),
//           _buildArrowButton('lib/assets/icons/down.png', _goDown),
//         ],
//       ),
//     );
//   }

//   Widget _buildArrowButton(String iconPath, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Image.asset(iconPath, width: 100, height: 55),
//     );
//   }

//   Widget _buildCarousel() {
//     return PageView.builder(
//       controller: _pageController,
//       scrollDirection: Axis.vertical,
//       itemCount: widget.sounds.length,
//       onPageChanged: (index) {
//         setState(() => _currentIndex = index);
//       },
//       itemBuilder: (context, index) {
//         return Center(
//           child: SoundCard(
//             sound: widget.sounds[index],
//             onTap: () => widget.onSoundTap(index),
//             isActive: index == _currentIndex,
//           ),
//         );
//       },
//     );
//   }
// }
