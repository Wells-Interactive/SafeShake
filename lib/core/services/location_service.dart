import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String?> getEmergencyLocationLink() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) return null;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final coordinates = '${position.latitude},${position.longitude}';
      return 'https://maps.google.com/?q=$coordinates';
    } on TimeoutException {
      return null;
    }
  }

  Future<bool> _checkPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
