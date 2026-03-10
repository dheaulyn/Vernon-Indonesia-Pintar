import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const YayasanApp());
}

class YayasanApp extends StatelessWidget {
  const YayasanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vernon Indonesia Pintar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFE53935),
      ),
      home: HomeScreen(),
    );
  }
}