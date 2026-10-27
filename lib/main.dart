import 'package:baby_hero/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BabyHeroApp());
}

class BabyHeroApp extends StatelessWidget {
  const BabyHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baby Hero',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF54158B),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}