import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProxy {
  Future<bool?> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
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

  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> getLocation() async {
    Position position = await Geolocator.getCurrentPosition();

    final prefs = await SharedPreferences.getInstance();

    prefs.setDouble('lat', position.latitude);
    prefs.setDouble('long', position.longitude);
    String locName = await getLocationName(position);
    prefs.setString('locationName', locName);
  }

  Future<String> getLocationName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      String city = place.subAdministrativeArea ?? '';
      String country = place.country ?? '';

      if (city.isEmpty && country.isEmpty) return 'Error';

      return '$city, $country';
    } catch (e) {
      return 'Error';
    }
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
