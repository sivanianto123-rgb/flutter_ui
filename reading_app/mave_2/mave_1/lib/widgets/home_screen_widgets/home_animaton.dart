import '../../../Utils/Common_imports/common_imports.dart';

class HomeAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.45,
      child: DotLottieLoader.fromAsset(
        'lib/assets/animations/tiger.lottie',
        frameBuilder: (context, dotlottie) {
          if (dotlottie != null) {
            return Lottie.memory(
              dotlottie.animations.values.single,
              fit: BoxFit.contain,
              repeat: true,
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
