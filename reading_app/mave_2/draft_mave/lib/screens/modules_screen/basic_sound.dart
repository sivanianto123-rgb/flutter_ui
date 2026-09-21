import 'package:mave/utils/common_import.dart';

import '../../widgets/module_template/module_template.dart';

class BasicSoundScreen extends StatefulWidget {
  final VoidCallback? onLevelComplete;

  const BasicSoundScreen({super.key, this.onLevelComplete});

  @override
  State<BasicSoundScreen> createState() => _BasicSoundScreenState();
}

class _BasicSoundScreenState extends State<BasicSoundScreen> {
  int _currentModuleIndex = 0;

  final List<Map<String, String>> _modules = [
    {
      'sound': 'Ba',
      'character': 'lib/assets/images/cha_1.png',
      'frame': 'lib/assets/images/ba_frame.png',
    },
    {
      'sound': 'Ma',
      'character': 'lib/assets/images/cha_1.png',
      'frame': 'lib/assets/images/ma_frame.png',
    },
    {
      'sound': 'Da',
      'character': 'lib/assets/images/cha_1.png',
      'frame': 'lib/assets/images/da_frame.png',
    },
    {
      'sound': 'Ga',
      'character': 'lib/assets/images/cha_1.png',
      'frame': 'lib/assets/images/ga_frame.png',
    },
    {
      'sound': 'Na',
      'character': 'lib/assets/images/cha_1.png',
      'frame': 'lib/assets/images/na_frame.png',
    },
    {
      'sound': 'Wa',
      'character': 'lib/assets/images/cha_1.png',
      'frame': 'lib/assets/images/wa_frame.png',
    },
  ];

  void _onModuleComplete() {
    if (_currentModuleIndex < _modules.length - 1) {
      setState(() {
        _currentModuleIndex++;
      });
    } else {
      widget.onLevelComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentModule = _modules[_currentModuleIndex];

    return ModuleTemplate(
      key: ValueKey(_currentModuleIndex),
      title: 'First sound',
      phonicSound: currentModule['sound']!,
      characterImage: currentModule['character']!,
      frameImage: currentModule['frame']!,
      onComplete: _onModuleComplete,
    );
  }
}
