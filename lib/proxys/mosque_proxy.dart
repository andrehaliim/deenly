import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:deenly/models/mosque_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MosqueProxy {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';
  static const int _radiusMeters = 2000;
  static const int _maxRetries = 3;
  static const String _userAgent = 'DeenlyApp/1.0';

  Future<List<MosqueModel>> fetchMosques() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat') ?? 0;
    final lon = prefs.getDouble('long') ?? 0;

    final bbox = _getBoundingBox(lat, lon, _radiusMeters);

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'amenity':
            'place_of_worship',
        'format': 'json',
        'limit': '20',
        'addressdetails': '1',
        'extratags': '1',
        'viewbox':
            '${bbox.minLon},${bbox.maxLat},${bbox.maxLon},${bbox.minLat}',
        'bounded': '1',
      },
    );

    log('Nominatim uri: $uri');

    final data = await _fetchWithRetry(uri);
    if (data == null) return [];

    List<MosqueModel> mosques = [];

    for (var place in data) {
      try {
        final extratags = place['extratags'] as Map<String, dynamic>? ?? {};
        final religion = extratags['religion'] as String?;
        if (religion != null && religion != 'muslim') continue;

        final String? name = place['name'];
        if (name == null || name.isEmpty) continue;
        if (name.toLowerCase() == 'mosque') continue;

        final double mLat = double.parse(place['lat']);
        final double mLon = double.parse(place['lon']);
        final double distance = Geolocator.distanceBetween(
          lat,
          lon,
          mLat,
          mLon,
        );

        if (distance > _radiusMeters) continue;

        final address = _parseAddress(place['address']);

        mosques.add(
          MosqueModel(
            name: name,
            lat: mLat,
            lon: mLon,
            distance: distance,
            address: address,
          ),
        );
      } catch (e) {
        log('Skipping malformed place: $e');
        continue;
      }
    }

    mosques.sort((a, b) => a.distance.compareTo(b.distance));
    return mosques.take(5).toList();
  }

  _BoundingBox _getBoundingBox(double lat, double lon, int radiusMeters) {
    const double metersPerDegLat = 111320.0;
    final double metersPerDegLon = 111320.0 * cos(lat * pi / 180);

    final double deltaLat = radiusMeters / metersPerDegLat;
    final double deltaLon = radiusMeters / metersPerDegLon;

    return _BoundingBox(
      minLat: lat - deltaLat,
      maxLat: lat + deltaLat,
      minLon: lon - deltaLon,
      maxLon: lon + deltaLon,
    );
  }

  String _parseAddress(Map<String, dynamic>? address) {
    if (address == null) return 'Address unavailable';

    final road =
        address['road'] ??
        address['pedestrian'] ??
        address['street'] ??
        address['path'] ??
        '';
    final houseNumber = address['house_number'] ?? '';
    final suburb = address['suburb'] ?? address['neighbourhood'] ?? '';
    final city = address['city'] ?? address['town'] ?? address['village'] ?? '';

    final streetPart = [
      houseNumber,
      road,
    ].where((s) => (s as String).isNotEmpty).join(' ');

    final localityPart =
        [suburb, city].where((s) => (s as String).isNotEmpty).firstOrNull ?? '';

    return [streetPart, localityPart]
        .where((s) => s.isNotEmpty)
        .join(', ')
        .trim()
        .ifEmpty('Address unavailable');
  }

  Future<List<dynamic>?> _fetchWithRetry(Uri uri) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        log('Nominatim fetch attempt $attempt/$_maxRetries');

        final response = await http
            .get(
              uri,
              headers: {'User-Agent': _userAgent, 'Accept-Language': 'en'},
            )
            .timeout(const Duration(seconds: 10));

        log('Nominatim status: ${response.statusCode}');

        if (response.statusCode == 200) {
          return json.decode(response.body) as List<dynamic>;
        }

        if (response.statusCode == 429) {
          log('Rate limited. Waiting before retry...');
          await Future.delayed(Duration(seconds: attempt * 3));
          continue;
        }

        log('Attempt $attempt failed: ${response.statusCode}');
      } catch (e) {
        log('Attempt $attempt threw: $e');
      }

      if (attempt < _maxRetries) {
        final delay = Duration(seconds: 1 << (attempt - 1));
        log('Retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
      }
    }

    log('All $_maxRetries attempts failed.');
    return null;
  }
}

class _BoundingBox {
  final double minLat, maxLat, minLon, maxLon;
  const _BoundingBox({
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
  });
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
