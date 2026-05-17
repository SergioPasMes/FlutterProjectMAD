import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class ApiManager {
  final String baseUrl = 'https://mad.gabrielg.es/api/v1/';

  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://madbiobond-default-rtdb.firebaseio.com/', // Cambiarla a la que sea al crearla
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
          throw Exception('La API no devolvió ningún token en la respuesta.');
        }

        // Guardamos el token en RealtimeDatabase y en SharedPreferences
        await _database.ref('users/$token').set({
          'token': token,
          'alias': alias,
          'age': age,
          'profile_picture': profilePicture,
          'updatedAt': ServerValue.timestamp,
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

      } else {
        throw Exception('Error de la API (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Devolvemos el error para capturarlo en la UI
      return Future.error('Fallo en el registro: $e');
    }
  }
}