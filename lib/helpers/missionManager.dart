import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:toastification/toastification.dart';

class MissionManager {
  StreamSubscription<Position>? _positionStreamSubscription;

  double? targetLatitude;
  double? targetLongitude;

  // Radius in meters to consider the mission completed
  final double completionRadius = 50.0;

  // Callback methods to tell the UI when the mission is completed and to update the target coordinates
  Function()? onMissionCompleted;
  Function(double lat, double lng)? onTargetUpdated;

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

    Position initialPosition = await Geolocator.getCurrentPosition();
    _generateNewTarget(initialPosition.latitude, initialPosition.longitude);

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Distance in meters before an update is triggered
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position currentPosition) {
        _checkDistance(currentPosition);
      },
    );
  }

  // Check if the user is within the completion radius of the mission
  void _checkDistance(Position currentPosition) {
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

      _generateNewTarget(currentPosition.latitude, currentPosition.longitude);
    }
  }

  // Generate new mission based on user's current location
  void _generateNewTarget(double currentLat, double currentLng) {
    final random = Random();

    double latOffset = (random.nextDouble() - 0.5) * 0.01;
    double lngOffset = (random.nextDouble() - 0.5) * 0.01;

    targetLatitude = currentLat + latOffset;
    targetLongitude = currentLng + lngOffset;

    if (onTargetUpdated != null) {
      onTargetUpdated!(targetLatitude!, targetLongitude!);
    }
  }

  // Stop listening to location updates when the user leaves the screen or when the app is closed
  void stopMissions() {
    _positionStreamSubscription?.cancel();
  }
}
