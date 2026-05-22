import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class MissionManager {
  StreamSubscription<Position>? _positionStreamSubscription;

  double? targetLatitude;
  double? targetLongitude;
  String? targetName;

  // Radius in meters to consider the mission completed
  final double completionRadius = 50.0;

  // List of possible missions
  final Map<String, Map<double, double>> missions = {
    "Cerro del Tío Pío" : {40.39050 : -3.65340},
    "Templo de Debod" : {40.42400 : -3.71760},
    "Parque del Retiro" : {40.41830 : -3.68260},
    "Parque Juan Carlos I" : {40.46190 : -3.60800},
    "Sun Music" : {40.426279 : -3.674972},
    "Madrid Rio": {40.398033 : -3.710935},
    "Lago de la Casa de Campo" : {40.41840 : -3.73350},
    "Fuentes de Cibeles y Neptuno" : {40.41930 : -3.69300},
    "Complejo Deportivo Municipal Alhóndiga" : {40.31479 : -3.74459},
    "Lago Westfield Parquesur" : {40.3394 : -3.73335},
    "Puerta del Sol" : {40.41680 : -3.70380},
    "Plaza Mayor": {40.41550 : -3.70740},
    "Plaza de Callao" : {40.42010 : -3.70570},
    "Mercado de San Miguel" : {40.41540 : -3.70900},
    "Plaza de Chueca" : {40.42250 : -3.69750}
  };

  // Callback methods to tell the UI when the mission is completed and to update the target coordinates
  Function()? onMissionCompleted;
  Function(String targetName)? onTargetUpdated;

  Future<void> startMissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    final prefs = await SharedPreferences.getInstance();
    String? currentNeccesity = prefs.getString("currentNecessity");
    _generateNewTarget(currentNeccesity!);

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Distance in meters before an update is triggered
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position currentPosition) {
        _checkDistance(currentPosition, currentNeccesity);
      },
    );
  }

  // Check if the user is within the completion radius of the mission
  Future<void> _checkDistance(Position currentPosition, String plantNecessity) async {
    if (targetLatitude == null || targetLongitude == null) return;

    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLatitude!,
      targetLongitude!,
    );

    if (distance <= completionRadius) {
      if (onMissionCompleted != null) {
        onMissionCompleted!();
      }

      // When mission completes, we clear the stored mission coordinates
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('missionLat');
      await prefs.remove('missionLong');

      await _generateNewTarget(plantNecessity);
    }
  }

  // Generate new mission based on user's current location
  Future<void> _generateNewTarget(String plantNecessity) async {
    int sunMissions = 2;
    int waterMissions = 2;
    int friendsMissions = 2;
    Position initialPosition = await Geolocator.getCurrentPosition();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('currentLat', initialPosition.latitude);
    await prefs.setDouble('currentLong', initialPosition.longitude);

    // We only check one of them because if one is null, the other will be null too
    double? currentMissionLat = prefs.getDouble('missionLat');
    if(currentMissionLat == null) {
      final entries = missions.entries.toList();
      List<MapEntry<String, Map<double, double>>> possibleMissions = [];
      switch(plantNecessity) {
        case 'sun':
          sunMissions = 5;
          break;
        case 'water':
          waterMissions = 5;
          break;
        case 'friends':
          friendsMissions = 5;
          break;
        case 'other':
        default:
          sunMissions = 5;
          waterMissions = 5;
          friendsMissions = 5;
          break;
      }
      // We fill the possible missions we can get based on our current plant's necessity
      possibleMissions.addAll(List.generate(sunMissions, (i) => entries[i]));
      possibleMissions.addAll(List.generate(waterMissions, (i) => entries[5 + i]));
      possibleMissions.addAll(List.generate(friendsMissions, (i) => entries[10 + i]));

      // Then we take a random mission from the possible ones
      final random = Random();
      final chosenMission = possibleMissions[random.nextInt(possibleMissions.length)];
      targetName = chosenMission.key;
      targetLatitude = chosenMission.value.keys.first;
      targetLongitude = chosenMission.value.values.first;
      await prefs.setString('missionName', targetName!);
      await prefs.setDouble('missionLat', targetLatitude!);
      await prefs.setDouble('missionLong', targetLongitude!);
    }else {
      targetLatitude = currentMissionLat;
      targetLongitude = prefs.getDouble('missionLong');
      targetName = prefs.getString('missionName');
    }

    if (onTargetUpdated != null) {
      onTargetUpdated!(targetName!);
    }
  }

  // Stop listening to location updates when the user leaves the screen or when the app is closed
  void stopMissions() {
    _positionStreamSubscription?.cancel();
  }
}
