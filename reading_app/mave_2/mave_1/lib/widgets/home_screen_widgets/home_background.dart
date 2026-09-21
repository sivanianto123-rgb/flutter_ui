import '../../../Utils/Common_imports/common_imports.dart';

class HomeBackground extends StatelessWidget {
  final Widget child;

  HomeBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'lib/assets/images/home_back.jpg',
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
        child,
      ],
    );
  }
}
