import 'dart:core' as parse;
import 'dart:core';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mad/helpers/apiManager.dart';
import 'package:flutter_mad/helpers/logger.dart';
import 'package:flutter_mad/widgets/profile_widget.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:toastification/toastification.dart';

import '../main.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  String _aliasController = '';
  int _ageController = 16;
  final _apiManager = ApiManager();
  String profile_picture = 'assets/profile_pictures/pfp_0.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to BioBond! Please enter your alias and age.'),
            SizedBox(height: 20),
            ProfileWidget(
                alias: _aliasController,
                age: _ageController,
                profile_picture: profile_picture,
                onAliasChange: (alias) { _aliasController = alias; },
                onAgeChange: (age) { _ageController = age; },
                onPictureChange: (pfp) { profile_picture = pfp; }
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _apiManager.registerUser(alias: _aliasController, age: _ageController, profilePicture: path.basename(profile_picture));

                  toastification.show(
                    context: context,
                    title: Text('User created successfully'),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                } catch (error) {
                  toastification.show(
                    context: context,
                    type: ToastificationType.error,
                    title: Text(error.toString()),
                    autoCloseDuration: const Duration(seconds: 5),
                  );

                }

                Route route = MaterialPageRoute(builder: (context) => MainNavigationScreen());
                Navigator.pushReplacement(context, route);
              },
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}