import '../../utils/common_imports/common_imports.dart';
import '../../widgets/back_button.dart';
import '../../widgets/module_template_widget/types_of_sounds.dart';
import 'sound_screen.dart';

class ModuleScreen extends StatefulWidget {
  final ModuleData moduleData;
  final List<bool> initialCompletedSounds;
  final Function(List<bool>) onProgressUpdate;

  ModuleScreen({
    Key? key,
    required this.moduleData,
    required this.initialCompletedSounds,
    required this.onProgressUpdate,
  }) : super(key: key);

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  late List<bool> _completedSounds;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _completedSounds = List.from(widget.initialCompletedSounds);
  }

  void _onSoundTap(int index) async {
    if (_isNavigating) return;
    _isNavigating = true;

    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SoundScreen(soundData: widget.moduleData.sounds[index]),
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    _isNavigating = false;

    if (result == true && mounted) {
      setState(() => _completedSounds[index] = true);
      widget.onProgressUpdate(_completedSounds);
    }
  }

  void _onBack() {
    if (_isNavigating) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'lib/assets/images/sound_bg.jpg',
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(children: [AppBackButton(onPressed: _onBack)]),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    widget.moduleData.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(100),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Expanded(
                    child: Center(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          widget.moduleData.sounds.length,
                          (i) {
                            return BulgedSoundCard(
                              sound: widget.moduleData.sounds[i].name,
                              isCompleted: _completedSounds[i],
                              onPressed: () => _onSoundTap(i),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
