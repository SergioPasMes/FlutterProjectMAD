import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import '../main.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final _aliasController = TextEditingController();
  final _ageController = TextEditingController();
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
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('alias', _aliasController.text);
                await prefs.setInt('age', int.parse(_ageController.text));

                toastification.show(
                  context: context,
                  title: Text('User created successfully'),
                  autoCloseDuration: const Duration(seconds: 5),
                );

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