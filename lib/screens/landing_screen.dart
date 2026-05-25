import 'package:BioBond/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:BioBond/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Widget? _targetScreen;

  @override
  void initState() {
    super.initState();
    _checkAlias();
  }

  void _checkAlias() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('auth_token')) {
      setState(() {
        _targetScreen = MainNavigationScreen();
      });
    } else {
      setState(() {
        _targetScreen = RegisterScreen(
          onRegisterSuccess: () {
            _checkAlias();
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_targetScreen != null) {
      return _targetScreen!;
    }
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}