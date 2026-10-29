import 'dart:convert';

import 'package:deenly/models/zakat_guide_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class ZakatGuideProxy {
  static const String _assetPath = 'assets/jsons/zakat_guide.json';

  Future<ZakatGuideModel> getGuide() async {
    final raw = await rootBundle.loadString(_assetPath);
    return ZakatGuideModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
