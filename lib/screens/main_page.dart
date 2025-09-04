// ========================================
// lib/screens/main_screen.dart
// ========================================

import 'package:flutter/material.dart';
import 'overview_page.dart';
import 'followers_page.dart';
import 'engagement_page.dart';
import 'content_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OverviewPage(),
    const FollowersPage(),
    const EngagementPage(),
    const ContentPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Visão Geral',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Seguidores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Engajamento',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Conteúdo',
          ),
        ],
      ),
    );
  }
}