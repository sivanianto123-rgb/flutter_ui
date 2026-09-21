// import '../../utils/common_import.dart';
// import 'module_header.dart';
// import 'phonic_widgets/phonics_avatar.dart';
// import 'phonic_widgets/phonic_runner.dart';

// class ModuleTemplate extends StatefulWidget {
//   final String title;
//   final String phonicSound;
//   final String characterImage;
//   final String frameImage;
//   final double initialProgress;
//   final VoidCallback? onComplete;

//   const ModuleTemplate({
//     super.key,
//     required this.title,
//     required this.phonicSound,
//     required this.characterImage,
//     required this.frameImage,
//     this.initialProgress = 0.0,
//     this.onComplete,
//   });

//   @override
//   State<ModuleTemplate> createState() => _ModuleTemplateState();
// }

// class _ModuleTemplateState extends State<ModuleTemplate> {
//   late double _progress;

//   @override
//   void initState() {
//     super.initState();
//     _progress = widget.initialProgress;
//   }

//   void _onTap() {
//     if (_progress >= 1.0) return;

//     setState(() {
//       _progress += 0.2;
//       if (_progress >= 1.0) {
//         _progress = 1.0;
//         Future.delayed(const Duration(milliseconds: 500), () {
//           widget.onComplete?.call();
//         });
//       }
//     });
//   }

//   void _onClose() {
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final shortestSide = size.shortestSide;

//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Container(
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('lib/assets/images/back.png'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Positioned.fill(
//               child: Image.asset(widget.frameImage, fit: BoxFit.cover),
//             ),
//             SafeArea(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ModuleHeader(
//                     title: widget.title,
//                     progress: _progress,
//                     onClose: _onClose,
//                   ),
//                   SizedBoxesVertical.sizedBox16,
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: PhonicsAvatar(
//                       phonicSound: widget.phonicSound,
//                       characterImage: widget.characterImage,
//                       onTap: _onTap,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: PhonicRunner(sound: widget.phonicSound),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import '../../utils/common_import.dart';
import 'animations/animation_placeholder.dart';
import 'module_header.dart';
import 'phonic_widgets/phonic_runner.dart';
import 'phonic_widgets/phonics_avatar.dart';

class ModuleTemplate extends StatefulWidget {
  final String title;
  final String phonicSound;
  final String characterImage;
  final String frameImage;
  final double initialProgress;
  final VoidCallback? onComplete;

  const ModuleTemplate({
    super.key,
    required this.title,
    required this.phonicSound,
    required this.characterImage,
    required this.frameImage,
    this.initialProgress = 0.0,
    this.onComplete,
  });

  @override
  State<ModuleTemplate> createState() => _ModuleTemplateState();
}

class _ModuleTemplateState extends State<ModuleTemplate> {
  late double _progress;
  String? _currentWord;

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
  }

  void _onTap() {
    if (_progress >= 1.0) return;

    setState(() {
      _progress += 0.2;
      if (_progress >= 1.0) {
        _progress = 1.0;
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onComplete?.call();
        });
      }
    });
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  void _onWordFormed(String word) {
    setState(() {
      _currentWord = word;
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentWord = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/back.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Image.asset(widget.frameImage, fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModuleHeader(
                    title: widget.title,
                    progress: _progress,
                    onClose: _onClose,
                  ),
                  SizedBoxesVertical.sizedBox16,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PhonicsAvatar(
                          phonicSound: widget.phonicSound,
                          characterImage: widget.characterImage,
                          onTap: _onTap,
                        ),
                        SizedBoxesHorizontal.sizedBox16,
                        AnimationHolder(currentWord: _currentWord),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PhonicRunner(
                sound: widget.phonicSound,
                onWordFormed: _onWordFormed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
