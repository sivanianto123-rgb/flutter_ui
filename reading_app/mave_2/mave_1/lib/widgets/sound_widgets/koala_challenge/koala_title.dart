import '../../../utils/common_imports/common_imports.dart';

const _kTitleDecoration = BoxDecoration(
  color: Color(0xDFD9D9D9),
  borderRadius: BorderRadius.all(Radius.circular(30)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFCCA7DA), width: 4)),
);

final TextStyle _kTitleStyle = GoogleFonts.outfit(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: const Color(0xFF4A4A4A),
);

class KoalaTitle extends StatelessWidget {
  final String sound;

  const KoalaTitle({Key? key, required this.sound}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: _kTitleDecoration,
      child: Text('Say "$sound"', style: _kTitleStyle),
    );
  }
}
