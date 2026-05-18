
import 'package:flutter/material.dart';
import 'package:flutter_mad/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAlias();
  }

  void _checkAlias() async {
    final prefs = await SharedPreferences.getInstance();
    /// If not registered, send the user to the register screen.
    if (prefs.containsKey('auth_token')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainNavigationScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    /// While reading data, we show loading indicator
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}