import 'package:flutter/material.dart';
import 'package:flutter_mad/helpers/apiManager.dart';

class RankingScreen extends StatelessWidget {
  final apiManager = ApiManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiManager.getData("ranking"),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          if (snapshot.hasData) {
            final data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (ctx, index) {
                final user = data[index];
                return ListTile(
                  leading: Image.asset('assets/profile_pictures/${user['profile_picture']}'),
                  title: Text(user['alias']),
                  trailing: Text(user['score'].toString()),
                );
              },
            );
          }

          return Center(child: Text("No data found"));
        },
      ),
    );
  }
}