import 'dart:async';
import '../../../utils/common_imports/common_imports.dart';
import 'koala_container.dart';
import 'koala_title.dart';
import '../../back_button.dart';

class KoalaChallenge extends StatefulWidget {
  final String sound;
  final bool isCorrect;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const KoalaChallenge({
    Key? key,
    required this.sound,
    required this.isCorrect,
    required this.onComplete,
    required this.onBack,
  }) : super(key: key);

  @override
  State<KoalaChallenge> createState() => _KoalaChallengeState();
}

class _KoalaChallengeState extends State<KoalaChallenge> {
  double? _screenHeight;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenHeight = MediaQuery.sizeOf(context).height;
  }

  @override
  Widget build(BuildContext context) {
    final h = _screenHeight ?? MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [AppBackButton(onPressed: widget.onBack)]),
        ),
        SizedBox(height: h * 0.02),
        KoalaTitle(sound: widget.sound),
        SizedBox(height: h * 0.03),
        Expanded(
          child: Center(
            child: RepaintBoundary(
              child: KoalaContainer(isCorrect: widget.isCorrect),
            ),
          ),
        ),
        SizedBox(height: h * 0.08),
      ],
    );
  }
}
