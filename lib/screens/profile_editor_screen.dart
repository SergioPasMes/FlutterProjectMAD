import 'package:flutter/material.dart';
import 'package:flutter_mad/screens/main_screen.dart';

class ProfileEditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Editor'),
      ),
      body: Center(
        child: FilledButton(
          child: Text('You are in Profile Editor. Go back to MainScreen'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
      ),
    );
  }
}