import '../../utils/common_imports/common_imports.dart';

class AccuracyBar extends StatelessWidget {
  final double accuracy;
  final bool isListening;

  AccuracyBar({Key? key, required this.accuracy, this.isListening = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var barHeight = screenHeight * 0.5;

    return Container(
      width: 70,
      margin: EdgeInsets.only(right: 16, top: 80, bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getColor().withAlpha(220),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: _getColor().withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              '${(accuracy * 100).toInt()}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: barHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFFCCA7DA), width: 4),
                  color: Colors.white.withAlpha(100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        width: double.infinity,
                        height: barHeight * accuracy,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [_getColor(), _getColor().withAlpha(180)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: barHeight * 0.8 - 2,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      Positioned(
                        bottom: barHeight * 0.8 - 12,
                        right: -25,
                        child: Text(
                          '80%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isListening)
                Positioned(
                  bottom: barHeight * accuracy,
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withAlpha(150),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accuracy >= 0.8
                  ? Color(0xFF389B39)
                  : (isListening
                        ? Colors.green.withAlpha(150)
                        : Colors.grey.withAlpha(100)),
              border: Border.all(
                color: accuracy >= 0.8 ? Color(0xFF7FD37E) : Color(0xFFCCA7DA),
                width: 3,
              ),
              boxShadow: isListening
                  ? [
                      BoxShadow(
                        color: Colors.green.withAlpha(100),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              accuracy >= 0.8 ? Icons.check : Icons.mic,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (accuracy >= 0.8) return Color(0xFF389B39);
    if (accuracy >= 0.5) return Color(0xFFE6A23C);
    if (accuracy >= 0.2) return Color(0xFFE6A23C).withAlpha(180);
    return Colors.grey;
  }
}
