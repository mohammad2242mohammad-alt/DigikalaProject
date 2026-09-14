import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/main.dart';
import 'package:frontend/providers/auth_provider.dart';

void main() {
  testWidgets('Digikala app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() async => null),
        ],
        child: const DigikalaApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ورود به حساب'), findsOneWidget);
  });
}
