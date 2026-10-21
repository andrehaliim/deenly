import 'package:deenly/models/prayer_model.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:deenly/proxys/prayer_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerSyncHelper {
  static const String keyLatitude = 'lat';
  static const String keyLongitude = 'long';
  static const String keyLocationName = 'locationName';
  static const String keyTimezone = 'prayerTimezone';
  static const String keyApproximate = 'locationApproximate';

  final LocationProxy _locationProxy = LocationProxy();
  final PrayerProxy _prayerProxy = PrayerProxy();

  Future<void> sync({bool useGps = true}) async {
    final prefs = await SharedPreferences.getInstance();

    final position = useGps ? await _tryGetPosition() : null;
    if (position != null) {
      await _syncFromGps(prefs, position);
      return;
    }

    final today = await _prayerProxy.getTodayPrayer();
    final latitude = prefs.getDouble(keyLatitude);
    final longitude = prefs.getDouble(keyLongitude);
    final hasCoordinates = latitude != null && longitude != null;

    /// Only a saved location may refetch an outdated cache; the timezone
    /// fallback would replace it with an approximate one.
    if (today != null && (!_isOutdated(today) || !hasCoordinates)) return;

    if (latitude != null && longitude != null) {
      await _fetchAndSave(
        prefs,
        latitude: latitude,
        longitude: longitude,
        locationName: prefs.getString(keyLocationName),
        isApproximate: prefs.getBool(keyApproximate) ?? false,
      );
      return;
    }

    await _syncFromTimezone(prefs);
  }

  /// Cached before Imsak and Sunrise were stored.
  bool _isOutdated(PrayerModel prayer) => prayer.sunrise.isEmpty;

  Future<bool> hasSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyLatitude) != null &&
        prefs.getDouble(keyLongitude) != null;
  }

  Future<bool> setManualLocation(String cityName) async {
    final name = cityName.trim();
    if (name.isEmpty) return false;

    try {
      final coordinates = await _locationProxy.getCoordinatesFromName(name);
      if (coordinates == null) return false;

      final prefs = await SharedPreferences.getInstance();
      await _fetchAndSave(
        prefs,
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        locationName: name,
        isApproximate: false,
      );
      return true;
    } catch (e, st) {
      debugPrint('setManualLocation failed: $e\n$st');
      return false;
    }
  }

  Future<Position?> _tryGetPosition() async {
    try {
      return await _locationProxy.getLocation();
    } catch (e) {
      debugPrint('GPS location unavailable: $e');
      return null;
    }
  }

  Future<void> _syncFromGps(SharedPreferences prefs, Position position) async {
    final savedName = prefs.getString(keyLocationName) ?? '';
    final locationName = await _locationProxy.getLocationName(position);

    final locationChanged =
        savedName.isEmpty ||
        (locationName != null && locationName != savedName) ||
        (prefs.getBool(keyApproximate) ?? false);
    final timezoneChanged = prefs.getString(keyTimezone) != tz.local.name;
    final today = await _prayerProxy.getTodayPrayer();
    final todayMissing = today == null || _isOutdated(today);

    if (!locationChanged && !timezoneChanged && !todayMissing) return;

    await _fetchAndSave(
      prefs,
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: locationName ?? (savedName.isEmpty ? null : savedName),
      isApproximate: false,
    );
  }

  Future<void> _syncFromTimezone(SharedPreferences prefs) async {
    final parts = tz.local.name.split('/');
    if (parts.length < 2 || parts.first == 'Etc') {
      throw StateError('No city for timezone ${tz.local.name}');
    }

    final cityName = parts.last.replaceAll('_', ' ');
    final coordinates = await _locationProxy.getCoordinatesFromName(cityName);
    if (coordinates == null) {
      throw StateError('No coordinates for timezone city $cityName');
    }

    await _fetchAndSave(
      prefs,
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      locationName: cityName,
      isApproximate: true,
    );
  }

  Future<void> _fetchAndSave(
    SharedPreferences prefs, {
    required double latitude,
    required double longitude,
    required String? locationName,
    required bool isApproximate,
  }) async {
    await _prayerProxy.fetchYearlyPrayer(latitude, longitude);

    await Future.wait([
      prefs.setDouble(keyLatitude, latitude),
      prefs.setDouble(keyLongitude, longitude),
      prefs.setString(keyTimezone, tz.local.name),
      prefs.setBool(keyApproximate, isApproximate),
      if (locationName != null) prefs.setString(keyLocationName, locationName),
    ]);
  }
}
