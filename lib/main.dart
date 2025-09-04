// ========================================
// lib/main.dart
// ========================================

import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const InstagramInsightsApp());
}

class InstagramInsightsApp extends StatelessWidget {
  const InstagramInsightsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Insights',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardThemeData(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
