import 'package:mave/screens/countdown_screen.dart';

import '../utils/common_import.dart';
import '../widgets/level card/level_card.dart';
import 'modules_screen/basic_sound.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasOpenedBefore = false;

  List<Map<String, dynamic>> levels = [
    {
      'label': 'Start Here!',
      'isFirst': true,
      'isUnlocked': true,
      'progress': 0.0,
    },
    {
      'label': 'First Sounds',
      'isFirst': false,
      'isUnlocked': false,
      'progress': 0.0,
    },
    {
      'label': 'Long Sounds',
      'isFirst': false,
      'isUnlocked': false,
      'progress': 0.0,
    },
    {
      'label': 'Combinations',
      'isFirst': false,
      'isUnlocked': false,
      'progress': 0.0,
    },
    {'label': 'Words', 'isFirst': false, 'isUnlocked': false, 'progress': 0.0},
    {
      'label': 'Sentences',
      'isFirst': false,
      'isUnlocked': false,
      'progress': 0.0,
    },
  ];

  void _openLevel(int index) {
    if (!levels[index]['isUnlocked']) return;

    if (!_hasOpenedBefore) {
      _hasOpenedBefore = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => CountdownScreen(
                destination: BasicSoundScreen(
                  onLevelComplete: () => _onLevelComplete(index),
                ),
              ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => BasicSoundScreen(
                onLevelComplete: () => _onLevelComplete(index),
              ),
        ),
      );
    }
  }

  void _onLevelComplete(int index) {
    if (mounted) {
      setState(() {
        levels[index]['progress'] = 1.0;
        if (index + 1 < levels.length) {
          levels[index + 1]['isUnlocked'] = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          color: Color(0xFFE0E3E5),
          image: DecorationImage(
            image: AssetImage('lib/assets/images/back.png'),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              children: [
                SizedBoxesVertical.sizedBox32,
                SizedBox(
                  width: size.width,
                  child: Text(
                    "Let's Learn with Mave",

                    style: AppFonts.w700primaryText58.copyWith(
                      fontSize: shortestSide * 0.07,
                      letterSpacing: 2.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBoxesVertical.sizedBox40,
                _buildLevelsSection(shortestSide),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelsSection(double shortestSide) {
    final starSize = shortestSide * 0.07;

    return SizedBox(
      height: shortestSide * 0.35,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: shortestSide * 0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(levels.length, (index) {
            final level = levels[index];
            final isLast = index == levels.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LevelCard(
                  label: level['label'],
                  imagePath:
                      level['isFirst']
                          ? 'lib/assets/images/cha_1.png'
                          : 'lib/assets/images/les.png',
                  isFirst: level['isFirst'],
                  isUnlocked: level['isUnlocked'],
                  progress: level['progress'],
                  onTap: () => _openLevel(index),
                ),
                if (!isLast)
                  _buildConnector(level['progress'] == 1.0, starSize),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildConnector(bool isPreviousComplete, double starSize) {
    return SizedBox(
      width: 120,
      height: starSize,
      child: Center(
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            color:
                isPreviousComplete
                    ? GradientColors.starGradient[0]
                    : AppColors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
