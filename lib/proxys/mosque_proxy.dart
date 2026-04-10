import 'dart:convert';
import 'dart:developer';

import 'package:deenly/models/mosque_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MosqueProxy {
  final String url = 'https://overpass-api.de/api';
  final int radius = 2000;

  Future<List<MosqueModel>> fetchMosques() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat') ?? 0;
    final lon = prefs.getDouble('lon') ?? 0;

    try {
      String query =
          '''
      [out:json][timeout:25];
      nwr["amenity"="place_of_worship"]["religion"="muslim"](around:$radius, $lat, $lon);
      out center;
    ''';

      var response = await http
          .post(Uri.parse('$url/interpreter'), body: {'data': query})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to load mosques: ${response.statusCode}');
      }

      var data = json.decode(response.body);
      List elements = data['elements'] ?? [];
      List<MosqueModel> fetchedMosques = [];

      for (var element in elements) {
        double mLat = element['lat'] ?? element['center']['lat'];
        double mLon = element['lon'] ?? element['center']['lon'];
        var tags = element['tags'] ?? {};

        double distance = Geolocator.distanceBetween(lat, lon, mLat, mLon);

        String? street = tags['addr:street'];
        String? houseNumber = tags['addr:housenumber'];
        String osmAddress = (street != null)
            ? "$houseNumber $street".trim()
            : "";

        String? name = tags['name'];
        if (name != null && name.isNotEmpty) {
          fetchedMosques.add(
            MosqueModel(
              name: name,
              lat: mLat,
              lon: mLon,
              distance: distance,
              address: osmAddress.isEmpty ? 'Address pending...' : osmAddress,
            ),
          );
        }
      }

      fetchedMosques.sort((a, b) => a.distance.compareTo(b.distance));
      int limit = fetchedMosques.length > 5 ? 5 : fetchedMosques.length;

      await Future.wait(
        List.generate(limit, (index) async {
          try {
            if (fetchedMosques[index].address == 'Address pending...') {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                fetchedMosques[index].lat,
                fetchedMosques[index].lon,
              ).timeout(const Duration(seconds: 3));

              if (placemarks.isNotEmpty) {
                Placemark place = placemarks.first;
                fetchedMosques[index].address =
                    "${place.street ?? ''}, ${place.locality ?? ''}".trim();
              }
            }
          } catch (e) {
            fetchedMosques[index].address = "Address unavailable";
          }
        }),
      );

      return fetchedMosques;
    } catch (e) {
      log("Error in fetchMosques: $e");
      return [];
    }
  }

  Future<void> checkStatus() async {
    var response = await http.get(Uri.parse('$url/status'));
    log(response.body);
  }
}
