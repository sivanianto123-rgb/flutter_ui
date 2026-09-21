import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/module_data.dart';
import '../../widgets/back_button.dart';
import '../../widgets/sound_widgets/sound_lottie.dart';

const _kBubbleDecoration = BoxDecoration(
  color: Color(0xDFD9D9D9),
  borderRadius: BorderRadius.all(Radius.circular(50)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFCCA7DA), width: 6)),
);

final TextStyle _activeStyle = GoogleFonts.outfit(
  fontSize: 54,
  fontWeight: FontWeight.bold,
  color: const Color(0xFFE53935),
);
final TextStyle _inactiveStyle = GoogleFonts.outfit(
  fontSize: 48,
  fontWeight: FontWeight.bold,
  color: const Color(0xFF4A4A4A),
);

class SoundContent extends StatelessWidget {
  final SoundData soundData;
  final int syllableIndex;
  final VoidCallback onBack;

  const SoundContent({
    Key? key,
    required this.soundData,
    required this.syllableIndex,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [AppBackButton(onPressed: onBack)]),
        ),
        SizedBox(height: h * 0.02),
        Container(
          width: 400,
          height: 120,
          decoration: _kBubbleDecoration,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < soundData.syllables.length; i++)
                  Text(
                    soundData.syllables[i],
                    style: i == syllableIndex ? _activeStyle : _inactiveStyle,
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: RepaintBoundary(
              child: SoundLottie(animationPath: soundData.animationPath),
            ),
          ),
        ),
        SizedBox(height: h * 0.05),
      ],
    );
  }
}
