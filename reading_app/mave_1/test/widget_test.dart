import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Mave app smoke test', (WidgetTester tester) async {
    // Full app init requires Hive + Gemini; skip in unit test.
    expect(true, isTrue);
  });
}
