import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class ApiManager {
  final String baseUrl = 'https://mad.gabrielg.es/api/v1/';

  final FirebaseDatabase database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://madbiobond-default-rtdb.firebaseio.com/'
  );

  Future<void> registerUser({required String alias, required int age, required String profilePicture,}) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'alias': alias,
          'age': age,
          'profile_picture': profilePicture,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? token = responseData['token'];

        if (token == null) {
          throw Exception('No token was delivered from the API.');
        }

        // Guardamos el token en RealtimeDatabase y en SharedPreferences
        await database.ref('users/$token').set({
          'token': token,
          'alias': alias,
          'age': age,
          'profile_picture': profilePicture,
          'updatedAt': ServerValue.timestamp,
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

      } else {
        throw Exception('Error in the API (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Devolvemos el error para capturarlo en la UI
      return Future.error('Fail while registering: $e');
    }
  }

  Future<void> updateUser({required Map<String, dynamic> updatedFields}) async {
    if (updatedFields.isEmpty) {
      return;
    }

    final String token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'User-Token': token
        },
        body: jsonEncode(updatedFields), ///Maps can be converted into JSON automatically
      );

      if (response.statusCode != 200) {
        throw Exception('Error en API (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      return Future.error('Fallo al actualizar en API: $e');
    }
  }

  Future<void> updateInDatabase({required Map<String, dynamic> updatedFields}) async {
    if (updatedFields.isEmpty) return;

    final String token = await _getToken();

    /// We use a copy of the original to avoid changing it and we also add the Timestamp
    final Map<String, dynamic> databaseChanges = Map.from(updatedFields);
    databaseChanges['updatedAt'] = ServerValue.timestamp;

    await database.ref('users/$token').update(databaseChanges);
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    /// User will be already logged in if method is called so it won't be null
    final String? token = prefs.getString('auth_token');

    return token!;
  }
}