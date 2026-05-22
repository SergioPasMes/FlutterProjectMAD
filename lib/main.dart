import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mad/screens/login_screen.dart';
import 'package:flutter_mad/screens/landing_screen.dart';
import 'package:flutter_mad/screens/map_screen.dart';
import 'package:flutter_mad/screens/main_screen.dart';
import 'package:flutter_mad/screens/profile_editor_screen.dart';
import 'package:flutter_mad/screens/ranking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data != null) {
              return LandingScreen(); // User is logged in
            }
            return LoginScreen(); // Usuario is not logged in
          }
          return CircularProgressIndicator();
        },
      ),
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
