import '../utils/common_imports/common_imports.dart';

class AppBackButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AppBackButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<AppBackButton> createState() => _AppBackButtonState();
}

class _AppBackButtonState extends State<AppBackButton> {
  bool _isPressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('lib/assets/icons/back.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? 0.6 : 1.0,
        child: Image.asset(
          'lib/assets/icons/back.png',
          width: 50,
          height: 50,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
