import 'package:flutter/material.dart';
import 'package:flutter_mad/screens/main_screen.dart';
import 'package:flutter_mad/screens/profile_editor_screen.dart';
import 'package:flutter_mad/screens/ranking_screen.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
    _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  // This widget is the root of your application.
  int selectedIndex = 0;
  final List<Widget> screens = [
    MainScreen(),
    ProfileEditorScreen(),
    RankingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioBond',
      home: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile Editor'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Ranking'),
        ],
        currentIndex: selectedIndex,
        onTap: (index) => setState(() {
          selectedIndex = index;
        })
        )
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
    );
  }
}