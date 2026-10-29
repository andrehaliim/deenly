import 'dart:convert';

import 'package:deenly/components/app_http.dart';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/models/gold_price_model.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class GoldPriceProxy {
  static const String _metalUrl = 'https://api.gold-api.com/price';
  static const String _rateUrl =
      'https://api.frankfurter.dev/v1/latest?from=USD&to=IDR';

  static const String liveSource = 'gold-api.com';
  static const double gramsPerTroyOunce = 31.1035;
  static const Duration _timeout = Duration(seconds: 15);

  /// Metal prices come in USD per troy ounce, so both are converted to
  /// IDR per gram with the same exchange rate.
  Future<GoldPriceModel> fetchPrice() async {
    final results = await Future.wait([
      _fetchUsdPerOunce('XAU'),
      _fetchUsdPerOunce('XAG'),
      _fetchUsdToIdr(),
    ]);
    final rate = results[2];

    return GoldPriceModel(
      goldPerGram: results[0] * rate / gramsPerTroyOunce,
      silverPerGram: results[1] * rate / gramsPerTroyOunce,
      source: liveSource,
      updatedAt: DateTime.now(),
    );
  }

  Future<double> _fetchUsdPerOunce(String symbol) async {
    final json = await _getJson(Uri.parse('$_metalUrl/$symbol'));
    final price = json['price'];
    if (price is! num || price <= 0) {
      throw FormatException('Invalid $symbol price: $price');
    }
    return price.toDouble();
  }

  Future<double> _fetchUsdToIdr() async {
    final json = await _getJson(Uri.parse(_rateUrl));
    final rates = json['rates'];
    final rate = rates is Map ? rates['IDR'] : null;
    if (rate is! num || rate <= 0) {
      throw FormatException('Invalid USD to IDR rate: $rate');
    }
    return rate.toDouble();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http
        .get(uri, headers: {'User-Agent': AppHttp.userAgent})
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', uri);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<GoldPriceModel?> getCachedPrice() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(DatabaseHelper.tableGoldPrice, limit: 1);
    if (maps.isEmpty) return null;
    return GoldPriceModel.fromDatabase(maps.first);
  }

  Future<void> savePrice(GoldPriceModel price) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      DatabaseHelper.tableGoldPrice,
      price.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
