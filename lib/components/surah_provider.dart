import 'dart:convert';

import 'package:deenly/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SurahProvider extends ChangeNotifier {
  List<SurahModel> _surahList = [];
  bool _isLoading = false;
  String? _code;

  bool get isLoading => _isLoading;
  List<SurahModel> get surahList => _surahList;

  void updateLanguage(String? code) {
    if (_code != code) {
      _code = code;
      Future.microtask(() => getSurahList());
    }
  }

  Future<void> getSurahList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final asset = _code == 'id'
          ? 'assets/jsons/surah_id.json'
          : 'assets/jsons/surah.json';

      final jsonStr = await rootBundle.loadString(asset);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final data = decoded['chapters'] as List<dynamic>;
      _surahList = data.map((e) => SurahModel.fromJsonApi(e)).toList();
    } catch (e, st) {
      debugPrint('Error loading surah list: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
