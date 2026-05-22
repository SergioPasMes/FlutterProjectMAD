import 'package:flutter/material.dart';
import 'package:BioBond/helpers/apiManager.dart';
import 'package:BioBond/helpers/databaseManager.dart';
import 'package:BioBond/widgets/profile_widget.dart';
import 'package:path/path.dart' as path;

class ProfileEditorScreen extends StatefulWidget {
  @override
  _ProfileEditorScreenState createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  String _aliasController = '';
  int _ageController = 16;
  String profile_picture = 'assets/profile_pictures/pfp_0.png';

  ApiManager apiManager = ApiManager();
  DatabaseManager databaseManager = DatabaseManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final token = await apiManager.getToken();
      final aliasData = await databaseManager.getFromDatabase(token, 'alias');
      final ageData = await databaseManager.getFromDatabase(token, 'age');
      final pfpData = await databaseManager.getFromDatabase(token, 'profile_picture');
      final pfpValue = pfpData?.toString() ?? 'pfp_0.png';

      if (!mounted) return;

      setState(() {
        _aliasController = aliasData?.toString() ?? '';
        _ageController = int.tryParse(ageData?.toString() ?? '16') ?? 16;
        profile_picture = 'assets/profile_pictures/$pfpValue';

        _isLoading = false;
      });
    } catch (e) {
      print("Error cargando perfil: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Editor')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Edit your profile information.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ProfileWidget(
                alias: _aliasController,
                age: _ageController,
                profile_picture: profile_picture,
                onAliasChange: (alias) { _aliasController = alias; },
                onAgeChange: (age) { _ageController = age; },
                onPictureChange: (pfp) { profile_picture = pfp; }
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveData,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveData() async {
    final token = await apiManager.getToken();

    if (_ageController < 16 || _ageController > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age (16-100)')),
      );
      return;
    }

    Map<String, dynamic> updatedData = {
      'alias': _aliasController,
      'age': _ageController,
      'profile_picture': path.basename(profile_picture)
    };

    await databaseManager.putUser(token, updatedData);
    await apiManager.updateUser(updatedFields: updatedData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }
}