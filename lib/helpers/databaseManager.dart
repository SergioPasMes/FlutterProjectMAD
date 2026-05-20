
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseManager {
  final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://madbiobond-default-rtdb.firebaseio.com/'
  );

  Future<void> postUser(String auth_token, Map<String, dynamic> data) async {
    await database.ref('users/$auth_token').set({
      'token': auth_token,
      'alias': data['alias'],
      'age': data['age'],
      'profile_picture': data['profile_picture'],
      'score': 0,
      'updatedAt': ServerValue.timestamp
    });
  }

  Future<void> putUser(String auth_token, Map<String, dynamic> updatedData) async {
    /// We use a copy of the original to avoid changing it and we also add the Timestamp
    final Map<String, dynamic> databaseChanges = Map.from(updatedData);
    databaseChanges['updatedAt'] = ServerValue.timestamp;

    await database.ref('users/$auth_token').update(databaseChanges);
  }

  /// Uses "dynamic" because can return String or int in our case
  Future<dynamic> getFromDatabase(String auth_token, String key) async {
    try {
      final DatabaseReference ref = database.ref('users/$auth_token/$key');
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        return snapshot.value;
      } else {
        return null;
      }
    } catch (e) {
      return Future.error('Failed reading from Firebase: $e');
    }
  }
}