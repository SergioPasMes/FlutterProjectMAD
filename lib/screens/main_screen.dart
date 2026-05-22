import 'package:flutter/material.dart';
import 'package:BioBond/helpers/apiManager.dart';
import 'package:BioBond/helpers/databaseManager.dart';
import 'package:BioBond/helpers/missionManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MissionManager _missionManager = MissionManager();
  final ApiManager apiManager = ApiManager();
  final DatabaseManager databaseManager = DatabaseManager();
  String? plantPicture;

  // Text for the coordinates, starts with a loading message
  String locationText = "Getting mission...";

  @override
  void initState() {
    super.initState();
    _loadInitialText();

    _checkAndShowPlantDialog();

    _missionManager.onTargetUpdated = (targetName) {
      if (mounted) {
        setState(() {
          locationText =
          "Go to $targetName";
        });
      }
    };

    _missionManager.onMissionCompleted = () async {
      final token = await apiManager.getToken();
      if (mounted) {
        final TextEditingController _reviewController = TextEditingController();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mission Completed!')),
        );
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Please, rate this mission for feedback'),
              content: TextField(
                controller: _reviewController,
                maxLength: 100,
                decoration: const InputDecoration(
                  hintText: "Your feedback...",
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    String review = _reviewController.text;
                    databaseManager.putUser(token, {'lastReview': review});

                    Navigator.pop(context);
                  },
                  child: const Text('Send'),
                ),
              ],
            )
        );
      }

      try {
        final scoreData = await databaseManager.getFromDatabase(token, 'score');
        final int oldScore = int.tryParse(scoreData?.toString() ?? '0') ?? 0;
        final Map<String, dynamic> updatedData = {'score': oldScore + 100};
        await apiManager.updateUser(updatedFields: updatedData);
        await databaseManager.putUser(token, updatedData);

      } catch (e) {
        print("Error while updating score: $e");
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
        final List<dynamic> plants = await apiManager.getData("plant");

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
                      /// Save current decision in SharedPreferences
                      await prefs.setString('lastPlantDate', DateTime.now().toIso8601String());
                      await prefs.setString('currentNecessity', plant['main_necessity']);
                      await prefs.setString('plantPicture', plant['picture']);
                      if (mounted) {
                        setState(() {
                          plantPicture = plant['picture'];
                        });
                      }
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
            SizedBox(height: 60),
            if (plantPicture != null)
              Image.network(
                plantPicture!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              )
          ],
        ),
      ),
    );
  }

  Future<void> _loadInitialText() async {
    final prefs = await SharedPreferences.getInstance();
    String? targetName = prefs.getString('missionName');
    String? savedPicture = prefs.getString('plantPicture');

    if (mounted) {
      setState(() {
        if (targetName != null) {
          locationText = "Go to $targetName";
        }
        plantPicture = savedPicture;
      });
    }
  }
}