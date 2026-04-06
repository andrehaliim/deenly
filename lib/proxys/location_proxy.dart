import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationProxy {
  Future<Position> requestLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return getDefaultPosition();
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return getDefaultPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return getDefaultPosition();
      }
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return getDefaultPosition();
    }
  }

  Position getDefaultPosition() {
    return Position(
      latitude: -6.2088,
      longitude: 106.8456,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  Future<String> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      String city = place.subAdministrativeArea ?? '';
      String country = place.country ?? '';

      if (city.isEmpty && country.isEmpty) return 'Jakarta, Indonesia';

      return '$city, $country';
    } catch (e) {
      return 'Jakarta, Indonesia';
    }
  }
}
