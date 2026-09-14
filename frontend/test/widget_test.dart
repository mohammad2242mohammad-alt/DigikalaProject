import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/main.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/models/user_model.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  Future<UserModel?> build() async => null;
}

void main() {
  testWidgets('Digikala app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_FakeAuthNotifier.new),
        ],
        child: const DigikalaApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ورود به حساب'), findsOneWidget);
  });
}
