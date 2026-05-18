import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mad/helpers/apiManager.dart';
import 'package:flutter_mad/helpers/logger.dart';
import 'package:logger/logger.dart';
import 'package:toastification/toastification.dart';

import '../main.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final _aliasController = TextEditingController();
  final _ageController = TextEditingController();
  final _apiManager = ApiManager();
  String _profilePicture = 'assets/profile_pictures/pfp_0.png';
  final List<String> avatars = [
    'assets/profile_pictures/pfp_0.png',
    'assets/profile_pictures/pfp_1.png',
    'assets/profile_pictures/pfp_2.png',
    'assets/profile_pictures/pfp_3.png',
    'assets/profile_pictures/pfp_4.png',
    'assets/profile_pictures/pfp_5.png',
    'assets/profile_pictures/pfp_6.png',
    'assets/profile_pictures/pfp_7.png',
    'assets/profile_pictures/pfp_8.png',
    'assets/profile_pictures/pfp_9.png',
    'assets/profile_pictures/pfp_10.png',
    'assets/profile_pictures/pfp_11.png',
  ];
  String? _aliasError;
  String? _ageError;

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
            TextField(
              controller: _aliasController,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              maxLength: 16,
              decoration: InputDecoration(
                labelText: 'Alias',
                border: OutlineInputBorder(),
                errorText: _aliasError
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _aliasError = null;
                  } else if (value.length < 3) {
                    _aliasError = 'El alias debe tener al menos 3 caracteres';
                  } else {
                    _aliasError = null;
                  }
                });
              },
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                errorText: _ageError,
              ),
              // Validación en tiempo real cada vez que el usuario teclea algo
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final age = int.tryParse(value);
                  if (age == null || age < 16 || age > 100) {
                    setState(() {
                      _ageError = 'Age must be between 16 and 100';
                    });
                  } else {
                    setState(() {
                      _ageError = null;
                    });
                  }
                } else {
                  setState(() {
                    _ageError = null;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final String? chosenImage = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Choose Profile Image'),
                    content: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: avatars.map((ruta) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context, ruta);
                          },
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(ruta, fit: BoxFit.cover),
                            ),
                          ),
                        );
                      }).toList(), /// Convert the map into a list of widgets for the Wrap
                    ),
                  ),
                );

                if (chosenImage != null) {
                  setState(() {
                    _profilePicture = chosenImage;
                  });
                }
              },
              child: SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(_profilePicture, fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _apiManager.registerUser(alias: _aliasController.text, age: int.parse(_ageController.text), profilePicture: _profilePicture);

                  toastification.show(
                    context: context,
                    title: Text('User created successfully'),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                } catch (error, stackTrace) {

                  print('================ ERROR COMPLETO ================\n$error');
                  print('================ DETALLES (STACK) ================\n$stackTrace');
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