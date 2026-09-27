import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: DigikalaApp()));
}

class DigikalaApp extends StatelessWidget {
  const DigikalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digikala',
      theme: ThemeData(
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دیجی‌کالا')),
      body: const Center(
        child: Text(
          'صفحه اصلی دیجی‌کالا',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
