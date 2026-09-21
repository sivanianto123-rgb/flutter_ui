import '../../utils/common_imports/common_imports.dart';

class HomeHeader extends StatefulWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onSoundTap;
  final bool isMuted;

  HomeHeader({
    Key? key,
    required this.onSettingsTap,
    required this.onSoundTap,
    required this.isMuted,
  }) : super(key: key);

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool _musicPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => _musicPressed = true),
            onTapUp: (_) {
              setState(() => _musicPressed = false);
              widget.onSoundTap();
            },
            onTapCancel: () => setState(() => _musicPressed = false),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 100),
              opacity: _musicPressed ? 0.6 : (widget.isMuted ? 0.4 : 1.0),
              child: Image.asset(
                'lib/assets/icons/music.png',
                width: 45,
                height: 45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
