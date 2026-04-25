import 'package:flutter/material.dart';
import 'package:flutter_mad/screens/profile_editor_screen.dart';
import 'package:flutter_mad/screens/ranking_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                child: Text('Welcome to the Homepage!! Go to Profile Editor'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileEditorScreen()),
                  );
                },
              ),
              FilledButton(
                child: Text('Go to Ranking Screen'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RankingScreen()),
                  );
                },
              ),
            ],
          )

      ),
    );
  }
}