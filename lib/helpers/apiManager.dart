import 'dart:convert';
import 'package:flutter_mad/helpers/databaseManager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class ApiManager {
  final String baseUrl = 'https://mad.gabrielg.es/api/v1/';
  final DatabaseManager databaseManager = DatabaseManager();

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
        final Map<String, dynamic> userData = {
          'alias': alias,
          'age': age,
          'profile_picture': profilePicture
        };
        final String? token = responseData['user_token'];

        if (token == null) {
          throw Exception('No token was delivered from the API.');
        }

        // Guardamos el token en RealtimeDatabase y en SharedPreferences
        await databaseManager.postUser(token, userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

      } else {
        throw Exception('${response.statusCode}: ${response.body}');
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

    final String token = await getToken();
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
        throw Exception('${response.statusCode}: ${response.body}');
      } else {
        await databaseManager.putUser(token, updatedFields);
      }

    } catch (e) {
      return Future.error('Failed when updating user with API: $e');
    }
  }

  Future<List<dynamic>> getPlants() async {
    final String token = await getToken();
    try {
      final response = await http.get(
      Uri.parse('${baseUrl}plant'),
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'User-Token': token
      },
    );
      if (response.statusCode != 200) {
        throw Exception('${response.statusCode}: ${response.body}');
      } else {
        final List<dynamic> responsePlants = jsonDecode(response.body);
        return responsePlants;
      }

    } catch (e) {
      return Future.error('Failed when obtaining plants from API: $e');
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    /// User will be already logged in if method is called so it won't be null
    final String? token = prefs.getString('auth_token');

    return token!;
  }
}