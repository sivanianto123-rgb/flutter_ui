import '../../../utils/common_imports/common_imports.dart';
import '../module_template_widget/types_of_sounds.dart';

class SoundGrid extends StatelessWidget {
  final List<String> sounds;
  final List<bool> completedSounds;
  final Function(int) onSoundTap;

  SoundGrid({
    Key? key,
    required this.sounds,
    required this.completedSounds,
    required this.onSoundTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 25,
        runSpacing: 25,
        children: List.generate(sounds.length, (index) {
          return BulgedSoundCard(
            sound: sounds[index],
            isCompleted: completedSounds[index],
            onPressed: () => onSoundTap(index),
          );
        }),
      ),
    );
  }
}