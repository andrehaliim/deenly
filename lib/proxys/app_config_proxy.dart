import 'dart:convert';

import 'package:deenly/components/app_http.dart';
import 'package:deenly/models/app_config_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigProxy {
  static const String _remoteUrl =
      'https://andrehaliim.vercel.app/projects/deenly/config.json';
  static const String _assetPath = 'assets/jsons/app_config.json';
  static const String _cacheKey = 'appConfig';
  static const Duration _timeout = Duration(seconds: 5);

  /// The last remote config saved on this device, or the bundled one.
  Future<AppConfigModel> getLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        return _parse(cached);
      } catch (e) {
        debugPrint('Cached app config is invalid: $e');
      }
    }
    return _parse(await rootBundle.loadString(_assetPath));
  }

  /// Parsed before it is saved, so a broken remote file never replaces a
  /// working cache.
  Future<AppConfigModel> fetchRemote() async {
    final uri = Uri.parse(_remoteUrl);
    final response = await http
        .get(uri, headers: {'User-Agent': AppHttp.userAgent})
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', uri);
    }
    final config = _parse(response.body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, response.body);
    return config;
  }

  AppConfigModel _parse(String raw) {
    return AppConfigModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
