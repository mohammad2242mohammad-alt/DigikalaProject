import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/auth/auth_page.dart';
import 'pages/home/home_page.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: DigikalaApp()));
}

class RightScrollbarBehavior extends MaterialScrollBehavior {
  const RightScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (details.direction == Axis.vertical) {
      // The scrollbar itself must use LTR so its physical side is RIGHT.
      // Keep the scrollable child outside this Directionality so Persian
      // content remains RTL and back arrows/layouts are not affected.
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scrollbar(
          scrollbarOrientation: ScrollbarOrientation.right,
          child: child,
        ),
      );
    }

    return super.buildScrollbar(context, child, details);
  }
}

class DigikalaApp extends StatelessWidget {
  const DigikalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digikala',
      scrollBehavior: const RightScrollbarBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const AuthPage(),
      data: (user) => user == null ? const AuthPage() : const HomePage(),
    );
  }
}
