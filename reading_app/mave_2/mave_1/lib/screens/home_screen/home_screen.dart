import '../../utils/common_imports/common_imports.dart';
import '../../widgets/module_template_widget/corusel_widget.dart';
import '../../assets/data/modules_data.dart';
import '../../widgets/home_screen_widgets/home_background.dart';
import '../../widgets/home_screen_widgets/home_header.dart';
import '../../widgets/home_screen_widgets/home_title.dart';
import '../../widgets/home_screen_widgets/home_animaton.dart';
import '../alpha_blocks/alpha_blocks_screen.dart';
import '../module_screen/module_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMuted = false;
  bool _isNavigating = false;

  List<bool> _firstSoundsCompleted = [];
  List<bool> _animalSoundsCompleted = [];
  List<bool> _combinationsCompleted = [];
  List<bool> _wordsCompleted = [];

  @override
  void initState() {
    super.initState();
    _initCompletedLists();
  }

  void _initCompletedLists() {
    _firstSoundsCompleted = List.filled(
      ModulesData.firstSounds.sounds.length,
      false,
    );
    _animalSoundsCompleted = List.filled(
      ModulesData.animalSounds.sounds.length,
      false,
    );
    _combinationsCompleted = List.filled(
      ModulesData.combinations.sounds.length,
      false,
    );
    _wordsCompleted = List.filled(ModulesData.words.sounds.length, false);
  }

  double _calculateProgress(List<bool> completed) {
    if (completed.isEmpty) return 0.0;
    int count = completed.where((c) => c).length;
    return count / completed.length;
  }

  List<Map<String, dynamic>> get _modules => [
    {
      'title': 'First Sounds',
      'progress': _calculateProgress(_firstSoundsCompleted),
    },
    {'title': 'Alphablocks', 'progress': 0.0},
    {
      'title': 'Animal Sounds',
      'progress': _calculateProgress(_animalSoundsCompleted),
    },
    {
      'title': 'Combinations',
      'progress': _calculateProgress(_combinationsCompleted),
    },
    {'title': 'Words', 'progress': _calculateProgress(_wordsCompleted)},
  ];

  void _onModuleTap(int index) {
    if (_isNavigating) return;
    _isNavigating = true;

    Widget? screen;

    switch (index) {
      case 0:
        screen = ModuleScreen(
          moduleData: ModulesData.firstSounds,
          initialCompletedSounds: _firstSoundsCompleted,
          onProgressUpdate: (list) =>
              setState(() => _firstSoundsCompleted = list),
        );
        break;
      case 1:
        screen = AlphablocksGame();
        break;
      case 2:
        if (ModulesData.animalSounds.sounds.isEmpty) {
          _isNavigating = false;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Coming soon!')));
          return;
        }
        screen = ModuleScreen(
          moduleData: ModulesData.animalSounds,
          initialCompletedSounds: _animalSoundsCompleted,
          onProgressUpdate: (list) =>
              setState(() => _animalSoundsCompleted = list),
        );
        break;
      case 3:
      case 4:
        _isNavigating = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Coming soon!')));
        return;
      default:
        _isNavigating = false;
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) => screen!,
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) => _isNavigating = false);
  }

  void _onSettingsTap() {}

  void _onSoundTap() {
    setState(() => _isMuted = !_isMuted);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: HomeBackground(
          child: SafeArea(
            child: Stack(
              children: [
                HomeHeader(
                  onSettingsTap: _onSettingsTap,
                  onSoundTap: _onSoundTap,
                  isMuted: _isMuted,
                ),
                Positioned(
                  left: 20,
                  top: screenHeight * 0.35,
                  child: HomeTitle(),
                ),
                Positioned(
                  left: screenWidth * 0.25,
                  bottom: 0,
                  child: HomeAnimation(),
                ),
                Positioned(
                  right: 20,
                  top: screenHeight * 0.1,
                  bottom: screenHeight * 0.1,
                  child: CarouselWidget(
                    modules: _modules,
                    onModuleTap: _onModuleTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
