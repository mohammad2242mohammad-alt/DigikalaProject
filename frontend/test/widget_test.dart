import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Digikala app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const DigikalaApp());

    expect(find.text('دیجی‌کالا'), findsOneWidget);
  });
}