import 'package:deenly/components/prayer_method_helper.dart';
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

  /// Chosen by the user; absent means automatic (from [keyCountry]).
  static const String keyMethod = 'prayerMethod';
  static const String keySchool = 'prayerSchool';

  /// Country of the last fetch, reused when it cannot be looked up.
  static const String keyCountry = 'prayerCountry';

  /// Method and school the cached prayer times were fetched with.
  static const String _keyAppliedMethod = 'prayerAppliedMethod';
  static const String _keyAppliedSchool = 'prayerAppliedSchool';

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
    if (today != null &&
        ((!_isOutdated(today) && !_calculationChanged(prefs)) ||
            !hasCoordinates)) {
      return;
    }

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

  /// True when the cache was fetched with another method or school, e.g.
  /// a change that could not be fetched offline, or a cache from before
  /// the method was selectable.
  bool _calculationChanged(SharedPreferences prefs) {
    final (:method, :school) = _calculationFor(
      prefs,
      prefs.getString(keyCountry),
    );
    return prefs.getInt(_keyAppliedMethod) != method ||
        prefs.getInt(_keyAppliedSchool) != school;
  }

  ({int method, int school}) _calculationFor(
    SharedPreferences prefs,
    String? countryCode,
  ) => (
    method:
        prefs.getInt(keyMethod) ?? PrayerMethodHelper.methodFor(countryCode),
    school:
        prefs.getInt(keySchool) ?? PrayerMethodHelper.schoolFor(countryCode),
  );

  /// Saves the chosen [method] and [school] (null for automatic) and
  /// refetches the prayer times with them. When the fetch fails the choice
  /// stays saved and the next [sync] applies it.
  Future<void> setCalculation({
    required int? method,
    required int? school,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      method == null
          ? prefs.remove(keyMethod)
          : prefs.setInt(keyMethod, method),
      school == null
          ? prefs.remove(keySchool)
          : prefs.setInt(keySchool, school),
    ]);

    final latitude = prefs.getDouble(keyLatitude);
    final longitude = prefs.getDouble(keyLongitude);
    if (latitude == null || longitude == null) return;

    await _fetchAndSave(
      prefs,
      latitude: latitude,
      longitude: longitude,
      locationName: prefs.getString(keyLocationName),
      isApproximate: prefs.getBool(keyApproximate) ?? false,
    );
  }

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

    if (!locationChanged &&
        !timezoneChanged &&
        !todayMissing &&
        !_calculationChanged(prefs)) {
      return;
    }

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
    final countryCode =
        await _locationProxy.getCountryCode(latitude, longitude) ??
        prefs.getString(keyCountry);
    final (:method, :school) = _calculationFor(prefs, countryCode);

    await _prayerProxy.fetchYearlyPrayer(
      latitude,
      longitude,
      method: method,
      school: school,
    );

    await Future.wait([
      prefs.setInt(_keyAppliedMethod, method),
      prefs.setInt(_keyAppliedSchool, school),
      if (countryCode != null) prefs.setString(keyCountry, countryCode),
      prefs.setDouble(keyLatitude, latitude),
      prefs.setDouble(keyLongitude, longitude),
      prefs.setString(keyTimezone, tz.local.name),
      prefs.setBool(keyApproximate, isApproximate),
      if (locationName != null) prefs.setString(keyLocationName, locationName),
    ]);
  }
}
