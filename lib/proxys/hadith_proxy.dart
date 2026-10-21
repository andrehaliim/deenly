import 'dart:convert';
import 'dart:math';

import 'package:deenly/models/hadith_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HadithProxy {
  static const String _assetPath = 'assets/jsons/hadiths.json';

  List<HadithModel>? _cache;
  final Random _random = Random();
  Future<List<HadithModel>> load() async {
    final cached = _cache;
    if (cached != null) {
      debugPrint('[HadithProxy] Already loaded (${cached.length} hadiths).');
      return cached;
    }

    debugPrint('[HadithProxy] Loading hadiths from asset…');
    final hadiths = await _loadFromAsset();
    _cache = hadiths;
    debugPrint('[HadithProxy] ${hadiths.length} hadiths loaded.');
    return hadiths;
  }

  Future<HadithModel> getDailyHadith() async {
    final hadiths = await load();

    if (hadiths.isEmpty) {
      throw const HadithException('No hadiths found in asset file.');
    }

    return hadiths[_random.nextInt(hadiths.length)];
  }

  void clearCache() {
    _cache = null;
    debugPrint('[HadithProxy] In-memory cache cleared.');
  }

  Future<List<HadithModel>> _loadFromAsset() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final raw = await rootBundle.loadString(_assetPath);
      return await compute(_parse, raw);
    } catch (e) {
      throw HadithException('Failed to load asset "$_assetPath": $e');
    }
  }

  static List<HadithModel> _parse(String raw) {
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final data = (decoded['data'] as List).cast<Map<String, dynamic>>();
      return data.map(HadithModel.fromJson).toList();
    } catch (e) {
      throw HadithException('Failed to parse hadiths JSON: $e');
    }
  }
}

class HadithException implements Exception {
  const HadithException(this.message);

  final String message;

  @override
  String toString() => 'HadithException: $message';
}
