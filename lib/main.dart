import 'package:flutter/material.dart';
import 'package:flutter_mad/helpers/logger.dart';
import 'package:flutter_mad/screens/landing_screen.dart';
import 'package:flutter_mad/screens/map_screen.dart';
import 'package:flutter_mad/screens/register_screen.dart';
import 'package:flutter_mad/screens/main_screen.dart';
import 'package:flutter_mad/screens/profile_editor_screen.dart';
import 'package:flutter_mad/screens/ranking_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // ------------------------------- TO DELETE STORED DATA AND START FROM ZERO -------------------------------
  //final prefs = await SharedPreferences.getInstance();
  //await prefs.clear();
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
    MapScreen(),
    ProfileEditorScreen(),
    RankingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Color.fromARGB(255, 0, 0, 0),), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map, color: Color.fromARGB(255, 0, 0, 0),), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle, color: Color.fromARGB(255, 0, 0, 0),), label: 'Profile Editor'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard, color: Color.fromARGB(255, 0, 0, 0),), label: 'Ranking'),
        ],
        currentIndex: selectedIndex,
        onTap: (index) => setState(() {
          selectedIndex = index;
        }),
      ),
    );
  }
}
