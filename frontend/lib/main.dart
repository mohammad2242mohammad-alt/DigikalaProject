import 'package:flutter/material.dart';

import 'pages/home/home_page.dart';


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

        useMaterial3: true,

        fontFamily: 'Arial',

      ),


      home: const HomePage(),

    );

  }

}