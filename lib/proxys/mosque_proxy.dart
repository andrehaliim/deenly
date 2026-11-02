import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:deenly/components/app_http.dart';
import 'package:deenly/models/mosque_model.dart';
import 'package:deenly/proxys/location_proxy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MosqueProxy {
  static const String _baseUrl = 'https://photon.komoot.io/api/';
  static const int _radiusMeters = 2000;
  static const int _maxRetries = 3;

  /// Photon is a text search without a religion filter, so mosques are
  /// found by the words their names usually contain.
  static const List<String> _keywords = [
    'masjid',
    'musholla',
    'mushola',
    'mosque',
  ];

  Future<List<MosqueModel>> fetchMosques() async {
    final currentPosition = await LocationProxy().getLocation();
    final lat = currentPosition.latitude;
    final lon = currentPosition.longitude;

    final bbox = _getBoundingBox(lat, lon, _radiusMeters);

    final results = await Future.wait(
      _keywords.map((keyword) {
        final uri = Uri.parse(_baseUrl).replace(
          queryParameters: {
            'q': keyword,
            'lat': '$lat',
            'lon': '$lon',
            'limit': '50',
            'osm_tag': 'amenity:place_of_worship',
            'bbox':
                '${bbox.minLon},${bbox.minLat},${bbox.maxLon},${bbox.maxLat}',
          },
        );
        log('Photon uri: $uri');
        return _fetchWithRetry(uri);
      }),
    );

    final Map<String, MosqueModel> mosques = {};

    for (final features in results) {
      if (features == null) continue;

      for (var feature in features) {
        try {
          final properties = feature['properties'] as Map<String, dynamic>;
          final id = '${properties['osm_type']}${properties['osm_id']}';
          if (mosques.containsKey(id)) continue;

          final String? name = properties['name'];
          if (name == null || name.isEmpty) continue;
          if (name.toLowerCase() == 'mosque') continue;

          final coordinates = feature['geometry']['coordinates'] as List;
          final double mLon = (coordinates[0] as num).toDouble();
          final double mLat = (coordinates[1] as num).toDouble();
          final double distance = Geolocator.distanceBetween(
            lat,
            lon,
            mLat,
            mLon,
          );

          if (distance > _radiusMeters) continue;

          mosques[id] = MosqueModel(
            name: name,
            lat: mLat,
            lon: mLon,
            distance: distance,
            address: _parseAddress(properties),
          );
        } catch (e) {
          log('Skipping malformed place: $e');
          continue;
        }
      }
    }

    final sorted = mosques.values.toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
    return sorted.take(5).toList();
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

  String _parseAddress(Map<String, dynamic> properties) {
    final road = properties['street'] ?? '';
    final houseNumber = properties['housenumber'] ?? '';
    final district = properties['district'] ?? '';
    final city = properties['city'] ?? '';

    final streetPart = [
      road,
      houseNumber,
    ].where((s) => (s as String).isNotEmpty).join(' ');

    final localityPart =
        [district, city].where((s) => (s as String).isNotEmpty).firstOrNull ??
        '';

    return [streetPart, localityPart]
        .where((s) => s.isNotEmpty)
        .join(', ')
        .trim()
        .ifEmpty('Address unavailable');
  }

  Future<List<dynamic>?> _fetchWithRetry(Uri uri) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        log('Photon fetch attempt $attempt/$_maxRetries');

        final response = await http
            .get(uri, headers: {'User-Agent': AppHttp.userAgent})
            .timeout(const Duration(seconds: 10));

        log('Photon status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final body = json.decode(response.body) as Map<String, dynamic>;
          return body['features'] as List<dynamic>;
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
