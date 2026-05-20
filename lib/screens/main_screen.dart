import 'package:flutter/material.dart';
import 'package:flutter_mad/helpers/apiManager.dart';
import 'package:flutter_mad/helpers/missionManager.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart'; // Asegúrate de que el nombre del archivo coincida

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MissionManager _missionManager = MissionManager();
  final ApiManager apiManager = ApiManager();

  // Text for the coordinates, starts with a loading message
  String locationText = "Getting mission...";

  @override
  void initState() {
    super.initState();
    _loadInitialText();

    _checkAndShowPlantDialog();

    _missionManager.onTargetUpdated = (lat, lng) {
      if (mounted) {
        setState(() {
          locationText =
          "Go to ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}";
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

  Future<void> _checkAndShowPlantDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastSelectionStr = prefs.getString('lastPlantDate');

    bool shouldShowDialog = false;

    if (lastSelectionStr == null) {
      /// Hasn't selected plant yet
      shouldShowDialog = true;
    } else {
      /// Already selected plant, check if 2 weeks have passed
      final DateTime lastDate = DateTime.parse(lastSelectionStr);
      final Duration difference = DateTime.now().difference(lastDate);

      if (difference.inDays >= 14) {
        shouldShowDialog = true;
      }
    }

    if (shouldShowDialog) {
      try {
        final List<dynamic> plants = await apiManager.getPlants();

        if (!mounted) return;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Choose your plant", textAlign: TextAlign.center),
              content: Wrap(
                spacing: 15,
                alignment: WrapAlignment.center,
                children: plants.map((plant) {
                  return GestureDetector(
                    onTap: () async {
                      /// Save current date in SharedPreferences
                      await prefs.setString('lastPlantDate', DateTime.now().toIso8601String());
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          child: Image.network(
                              plant['picture'],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(plant['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      } catch (e) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: Text(e.toString()),
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    }
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
            Text("Welcome to BioBond!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),
            Text(
              locationText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadInitialText() async {
    final prefs = await SharedPreferences.getInstance();
    double? missLat = prefs.getDouble('missionLat');
    double? missLng = prefs.getDouble('missionLong');

    if (missLat != null && missLng != null) {
      if (mounted) {
        setState(() {
          locationText =
          "Go to ${missLat.toStringAsFixed(5)}, ${missLng.toStringAsFixed(5)}";
        });
      }
    }
  }
}