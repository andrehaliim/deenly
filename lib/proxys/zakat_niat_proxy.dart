import 'dart:convert';

import 'package:deenly/models/zakat_niat_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class ZakatNiatProxy {
  static const String _assetPath = 'assets/jsons/zakat_niat.json';

  Future<ZakatNiatListModel> getNiats() async {
    final raw = await rootBundle.loadString(_assetPath);
    return ZakatNiatListModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
