import 'package:deenly/models/baznas_decree_model.dart';
import 'package:deenly/models/gold_price_model.dart';
import 'package:deenly/models/zakat_config_model.dart';
import 'package:deenly/models/zakat_result_model.dart';
import 'package:deenly/proxys/gold_price_proxy.dart';
import 'package:flutter/material.dart';

class ZakatProvider extends ChangeNotifier {
  static const double nisabGoldGrams = 85;
  static const double nisabSilverGrams = 595;
  static const double riceKgPerPerson = 2.5;
  static const double riceLitersPerPerson = 3.5;

  static const String _configSource = 'app_config';

  final GoldPriceProxy _proxy = GoldPriceProxy();

  GoldPriceModel? _price;
  ZakatConfigModel? _config;
  bool _isLoading = false;
  bool _isStale = false;
  bool _isDefaultPrice = false;

  GoldPriceModel? get price => _price;
  int get fitrahPerPerson => _config?.fitrahPerPerson ?? 0;
  bool get isLoading => _isLoading;

  /// True when today's price could not be fetched and an older cached
  /// price or the configured fallback price is shown instead.
  bool get isStale => _isStale;
  bool get isDefaultPrice => _isDefaultPrice;

  /// Yearly nisab (85 g of gold) as set by the BAZNAS chairman's decree,
  /// not derived from the live gold price.
  double? get nisab => _config?.nisabPerYear;
  BaznasDecreeModel? get nisabDecree => _config?.nisabDecree;
  BaznasDecreeModel? get fitrahDecree => _config?.fitrahDecree;

  /// Called by the provider tree whenever the app config changes.
  void updateConfig(ZakatConfigModel? config) {
    if (identical(config, _config)) return;
    _config = config;
    Future.microtask(notifyListeners);
  }

  /// Fetches at most once a day: a price cached today is reused unless
  /// [force] is set. Failures fall back to the last cached price, then to
  /// the fallback price in the app config.
  Future<void> load({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _price != null && !_isStale) return;

    _isLoading = true;
    notifyListeners();

    try {
      GoldPriceModel? cached;
      try {
        cached = await _proxy.getCachedPrice();
      } catch (e) {
        debugPrint('Reading cached gold price failed: $e');
      }

      if (!force && cached != null && _isToday(cached.updatedAt)) {
        _setPrice(cached);
        return;
      }

      try {
        final fresh = await _proxy.fetchPrice();
        await _proxy.savePrice(fresh);
        _setPrice(fresh);
      } catch (e) {
        debugPrint('Fetching gold price failed: $e');
        final config = _config;
        if (cached != null) {
          _setPrice(cached, isStale: true);
        } else if (config != null) {
          _setPrice(
            GoldPriceModel(
              goldPerGram: config.goldPricePerGram,
              silverPerGram: config.silverPricePerGram,
              source: _configSource,
              updatedAt: config.priceUpdatedAt,
            ),
            isStale: true,
            isDefault: true,
          );
        }
      }
    } catch (e, st) {
      debugPrint('Loading zakat data failed: $e\n$st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setPrice(
    GoldPriceModel price, {
    bool isStale = false,
    bool isDefault = false,
  }) {
    _price = price;
    _isStale = isStale;
    _isDefaultPrice = isDefault;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Income zakat follows BAZNAS: the yearly nisab of 85 g gold is split
  /// into a monthly one and compared with gross monthly income.
  ZakatResultModel? calculateIncome(double monthlyIncome) {
    final nisab = this.nisab;
    if (nisab == null || monthlyIncome <= 0) return null;
    return ZakatResultModel.evaluate(base: monthlyIncome, nisab: nisab / 12);
  }

  ZakatResultModel? calculateMaal({
    required double assets,
    required double debts,
    required bool haul,
  }) {
    final nisab = this.nisab;
    if (nisab == null || assets <= 0) return null;
    return ZakatResultModel.evaluate(
      base: assets - debts,
      nisab: nisab,
      haul: haul,
    );
  }

  /// [pricePerGram] comes from the user, prefilled with [price], since the
  /// local gold price they know may differ from the spot price.
  ZakatResultModel? calculateGold(
    double grams, {
    required double pricePerGram,
    required bool haul,
  }) {
    if (grams <= 0 || pricePerGram <= 0) return null;
    return ZakatResultModel.evaluate(
      base: grams * pricePerGram,
      nisab: nisabGoldGrams * pricePerGram,
      haul: haul,
    );
  }

  ZakatResultModel? calculateSilver(
    double grams, {
    required double pricePerGram,
    required bool haul,
  }) {
    if (grams <= 0 || pricePerGram <= 0) return null;
    return ZakatResultModel.evaluate(
      base: grams * pricePerGram,
      nisab: nisabSilverGrams * pricePerGram,
      haul: haul,
    );
  }
}
