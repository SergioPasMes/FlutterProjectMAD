import 'package:flutter/material.dart';
import 'package:flutter_mad/logger.dart';
import 'package:flutter_mad/screens/landing_screen.dart';
import 'package:flutter_mad/screens/register_screen.dart';
import 'package:flutter_mad/screens/main_screen.dart';
import 'package:flutter_mad/screens/profile_editor_screen.dart';
import 'package:flutter_mad/screens/ranking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // ------------------------------- PARA BORRAR DATOS GUARDADOS Y EMPEZAR DE CERO -------------------------------
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioBond',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: LandingScreen(),
    );
  }
}

// Widget con el menú inferior
class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;
  final List<Widget> screens = [
    MainScreen(),
    ProfileEditorScreen(),
    RankingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile Editor'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Ranking'),
        ],
        currentIndex: selectedIndex,
        onTap: (index) => setState(() {
          selectedIndex = index;
        }),
      ),
    );
  }
}
