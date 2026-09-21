import '../../utils/common_imports/common_imports.dart';

class BulgedSoundCard extends StatefulWidget {
  final String sound;
  final bool isCompleted;
  final VoidCallback onPressed;

  BulgedSoundCard({
    Key? key,
    required this.sound,
    required this.isCompleted,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<BulgedSoundCard> createState() => _BulgedSoundCardState();
}

class _BulgedSoundCardState extends State<BulgedSoundCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  AnimationController? _shapeController;
  Animation<double>? _shapeAnimation;

  @override
  void initState() {
    super.initState();
    _setupShapeAnimation();
  }

  void _setupShapeAnimation() {
    _shapeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _shapeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shapeController!, curve: Curves.easeInOut),
    );

    if (!widget.isCompleted) {
      _shapeController!.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BulgedSoundCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shapeController == null) return;

    if (widget.isCompleted && _shapeController!.isAnimating) {
      _shapeController!.stop();
    } else if (!widget.isCompleted && !_shapeController!.isAnimating) {
      _shapeController!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shapeController?.dispose();
    super.dispose();
  }

  BorderRadius _getAnimatedBorderRadius(double value) {
    double topLeft = 30 + (20 * value);
    double topRight = 50 - (20 * value);
    double bottomLeft = 50 - (20 * value);
    double bottomRight = 30 + (20 * value);

    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shapeController == null || _shapeAnimation == null) {
      return SizedBox(width: 120, height: 120);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _shapeAnimation!,
        builder: (context, child) {
          return AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: widget.isCompleted ? 0.4 : 1.0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 150),
              width: 120,
              height: 120,
              transform: Matrix4.identity()..scale(_isPressed ? 0.92 : 1.0),
              decoration: BoxDecoration(
                borderRadius: widget.isCompleted
                    ? BorderRadius.circular(40)
                    : _getAnimatedBorderRadius(_shapeAnimation!.value),
                border: Border.all(color: Color(0xFFCCA7DA), width: 5),
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(77),
                          offset: Offset(4, 4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white.withAlpha(204),
                          offset: Offset(-3, -3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: widget.isCompleted
                    ? BorderRadius.circular(35)
                    : _getAnimatedBorderRadius(_shapeAnimation!.value),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'lib/assets/images/module_background.jpg',
                      fit: BoxFit.cover,
                    ),
                    if (widget.isCompleted)
                      Container(color: Colors.green.withAlpha(128)),
                    Center(
                      child: widget.isCompleted
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 50,
                            )
                          : Text(
                              widget.sound,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withAlpha(128),
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
