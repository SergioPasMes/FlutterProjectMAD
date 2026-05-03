
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
    // Si ya tiene alias, vamos a la app principal. Si no, a la de registro.
    if (prefs.containsKey('alias') && prefs.containsKey('age')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainNavigationScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras lee los datos, mostramos un círculo de carga
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}