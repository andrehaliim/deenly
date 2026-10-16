import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProxy {
  static const Duration _timeLimit = Duration(seconds: 15);

  Future<bool?> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    return true;
  }

  /// Checks the current status without showing the system dialog.
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(timeLimit: _timeLimit),
    );
    return position;
  }

  Future<String?> getLocationName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(_timeLimit);

      if (placemarks.isEmpty) return null;

      String city = placemarks.first.subLocality ?? '';

      if (city.isEmpty) return null;

      return city;
    } catch (e) {
      debugPrint('getLocationName failed: $e');
      return null;
    }
  }

  Future<({double latitude, double longitude})?> getCoordinatesFromName(
    String name,
  ) async {
    final locations = await locationFromAddress(name).timeout(_timeLimit);
    if (locations.isEmpty) return null;
    final location = locations.first;
    return (latitude: location.latitude, longitude: location.longitude);
  }

  Future<bool?> isLocationChanged(Position newPosition) async {
    final prefs = await SharedPreferences.getInstance();
    double? oldLat = prefs.getDouble('lat');
    double? oldLng = prefs.getDouble('long');

    if (oldLat == null || oldLng == null) {
      return null;
    }

    double distanceInMeters = Geolocator.distanceBetween(
      newPosition.latitude,
      newPosition.longitude,
      oldLat,
      oldLng,
    );
    return distanceInMeters > 10000;
  }
}
