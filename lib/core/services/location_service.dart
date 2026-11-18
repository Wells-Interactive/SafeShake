import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const _cacheKey = 'last_known_location';
  static const _cacheTimeKey = 'last_known_location_time';
  static const _cacheMaxAgeMs = 24 * 60 * 60 * 1000;

  Future<String?> getEmergencyLocationLink() async {
    final cached = await _readCachedLocation();
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      return cached != null
          ? 'https://maps.google.com/?q=$cached'
          : null;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return cached != null
          ? 'https://maps.google.com/?q=$cached'
          : null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final coordinates = '${position.latitude},${position.longitude}';
      await _cacheLocation(coordinates, position.timestamp);
      return 'https://maps.google.com/?q=$coordinates';
    } on TimeoutException {
      return cached != null
          ? 'https://maps.google.com/?q=$cached'
          : null;
    } catch (_) {
      return cached != null
          ? 'https://maps.google.com/?q=$cached'
          : null;
    }
  }

  Future<String?> getLastKnownLocationLink() async {
    final cached = await _readCachedLocation();
    return cached != null ? 'https://maps.google.com/?q=$cached' : null;
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

  Future<bool> _checkPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<String?> _readCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAt = prefs.getInt(_cacheTimeKey) ?? 0;
      if (DateTime.now().millisecondsSinceEpoch - savedAt > _cacheMaxAgeMs) {
        return null;
      }
      return prefs.getString(_cacheKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheLocation(String coordinates, DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, coordinates);
      await prefs.setInt(_cacheTimeKey, timestamp.millisecondsSinceEpoch);
    } catch (_) {}
  }
}
