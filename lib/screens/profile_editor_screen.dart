import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditorScreen extends StatefulWidget {
  @override
  _ProfileEditorScreenState createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  final _aliasController = TextEditingController();
  final _ageController = TextEditingController();
  String? _ageError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Rellenamos los TextField con los datos guardados
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _aliasController.text = prefs.getString('alias') ?? '';
      _ageController.text = prefs.getInt('age')?.toString() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Editor')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Edit your profile information.', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            TextField(
              controller: _aliasController,
              decoration: InputDecoration(
                labelText: 'Alias',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                errorText: _ageError,
              ),
              onChanged: (value) => _validateAge(value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _validateAge(String value) {
    if (value.isEmpty) {
      setState(() => _ageError = null);
      return;
    }
    final age = int.tryParse(value);
    if (age == null || age < 16 || age > 100) {
      setState(() => _ageError = 'Age must be between 16 and 100');
    } else {
      setState(() => _ageError = null);
    }
  }

  void _saveData() async {
    final age = int.tryParse(_ageController.text);

    if (age == null || age < 16 || age > 100) {
      setState(() => _ageError = 'Please enter a valid age (16-100)');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alias', _aliasController.text);
    await prefs.setInt('age', age);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
  }
}