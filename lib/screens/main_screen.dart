import 'package:flutter/material.dart';
import 'package:flutter_mad/helpers/missionManager.dart';
import 'package:toastification/toastification.dart'; // Asegúrate de que el nombre del archivo coincida

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MissionManager _missionManager = MissionManager();

  // Text for the coordinates, starts with a loading message
  String _locationText = "Getting mission...";

  @override
  void initState() {
    super.initState();
    _missionManager.onTargetUpdated = (lat, lng) {
      if (mounted) {
        setState(() {
          _locationText = "${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}";
        });
      }
    };

    _missionManager.onMissionCompleted = () {
      if (mounted) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mission Completed!')),
          );
        });
      }
    };

    _missionManager.startMissions().catchError((e) =>
        toastification.show(
          context: context,
          title: Text(e.toString()),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 5),
        )
    );
  }

  @override
  void dispose() {
    _missionManager.stopMissions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BioBond')),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text("Welcome to BioBond!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),
            Text(
              "Go to $_locationText",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}