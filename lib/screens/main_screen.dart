import 'package:flutter/material.dart';
import 'package:flutter_mad/logger.dart';
import 'package:flutter_mad/screens/profile_editor_screen.dart';
import 'package:flutter_mad/screens/ranking_screen.dart';
import 'package:toastification/toastification.dart';

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
                  AppLogger.i('Navigating to Profile Editor Screen through button');
                  toastification.show(
                    context: context,
                    title: Text('Profile Editor Patata'),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileEditorScreen()),
                  );
                },
              ),
              FilledButton(
                child: Text('Go to Ranking Screen'),
                onPressed: () {
                  AppLogger.i('Navigating to Ranking Screen through button');
                  toastification.show(
                    context: context,
                    title: Text('Ranking Patata'),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
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