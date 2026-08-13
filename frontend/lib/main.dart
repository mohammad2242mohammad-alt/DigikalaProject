import 'package:flutter/material.dart';

void main() {
  runApp(const DigikalaApp());
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
      appBar: AppBar(
        title: const Text('دیجی‌کالا'),
      ),
      body: const Center(
        child: Text(
          'صفحه اصلی دیجی‌کالا',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}