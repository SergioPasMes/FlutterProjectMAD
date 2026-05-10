import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userPos;
  LatLng? missionPos;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocationsFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: userPos ?? LatLng(40.40886242536441, -3.5250663094863905),
        // Focus
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(
          markers: [
            if (userPos != null)
              Marker(
                point: userPos!,
                width: 50,
                height: 50,
                child: const Icon(Icons.person_pin_circle, color: Colors.green, size: 40),
              ),
            if (missionPos != null)
              Marker(
                point: missionPos!,
                width: 50,
                height: 50,
                child: const Icon(Icons.star_rounded, color: Colors.yellow, size: 40),
              ),
          ],
        ),
      ],
    );
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'upm',
  );

  Future<void> _loadLocationsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    double? userLat = prefs.getDouble('currentLat');
    double? userLng = prefs.getDouble('currentLong');
    double? missLat = prefs.getDouble('missionLat');
    double? missLng = prefs.getDouble('missionLong');

    setState(() {
      if (userLat != null && userLng != null) {
        userPos = LatLng(userLat, userLng);
      }

      if (missLat != null && missLng != null) {
        missionPos = LatLng(missLat, missLng);
      }
      isLoading = false;
    });
  }
}
