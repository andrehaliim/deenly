import 'dart:convert';
import 'dart:math';

import 'package:deenly/models/hadith_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
class HadithProxy {
  static const String _assetPath = 'assets/jsons/hadiths.json';

  List<HadithModel>? _cache;
  final Random _random = Random();
  Future<void> load() async {
    if (_cache != null) {
      debugPrint('[HadithProxy] Already loaded (${_cache!.length} hadiths).');
      return;
    }

    debugPrint('[HadithProxy] Loading hadiths from asset…');
    _cache = await _loadFromAsset();
    debugPrint('[HadithProxy] ${_cache!.length} hadiths loaded.');
  }
  Future<HadithModel> getDailyHadith() async {
    if (_cache == null) await load();

    if (_cache!.isEmpty) {
      throw const HadithException('No hadiths found in asset file.');
    }

    return _cache![_random.nextInt(_cache!.length)];
  }

  void clearCache() {
    _cache = null;
    debugPrint('[HadithProxy] In-memory cache cleared.');
  }

  Future<List<HadithModel>> _loadFromAsset() async {
    late String raw;

    try {
      raw = await rootBundle.loadString(_assetPath);
    } catch (e) {
      throw HadithException('Failed to load asset "$_assetPath": $e');
    }

    return _parse(raw);
  }

  List<HadithModel> _parse(String raw) {
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final data = (decoded['hadiths']['data'] as List).cast<Map<String, dynamic>>();
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