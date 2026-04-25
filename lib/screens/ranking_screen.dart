import 'package:flutter/material.dart';

class RankingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking Screen'),
      ),
      body: Center(
        child: FilledButton(
          child: Text('Welcome to the Ranking!! Back to the Homepage'),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
      ),
    );
  }
}