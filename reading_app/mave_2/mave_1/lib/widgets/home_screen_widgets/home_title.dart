import '../../../Utils/Common_imports/common_imports.dart';

class HomeTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          'Lets learn with\n       Mave',
          style: AppFonts.homeScreenTextStroke(),
        ),
        Text('Lets learn with\n       Mave', style: AppFonts.homeScreenText()),
      ],
    );
  }
}
