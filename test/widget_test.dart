import 'package:flutter_test/flutter_test.dart';

import 'package:cropmitra_ai/main.dart';

void main() {
  testWidgets('CropMitra app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const CropMitraApp());

    expect(find.text('CropMitra AI'), findsOneWidget);
  });
}
