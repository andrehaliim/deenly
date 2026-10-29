import 'package:deenly/models/baznas_decree_model.dart';

/// Yearly zakat values set by BAZNAS, plus fallback metal prices for when
/// the live price cannot be fetched.
class ZakatConfigModel {
  final double nisabPerYear;
  final BaznasDecreeModel nisabDecree;
  final int fitrahPerPerson;
  final BaznasDecreeModel fitrahDecree;
  final double goldPricePerGram;
  final double silverPricePerGram;
  final DateTime priceUpdatedAt;

  const ZakatConfigModel({
    required this.nisabPerYear,
    required this.nisabDecree,
    required this.fitrahPerPerson,
    required this.fitrahDecree,
    required this.goldPricePerGram,
    required this.silverPricePerGram,
    required this.priceUpdatedAt,
  });

  factory ZakatConfigModel.fromJson(Map<String, dynamic> json) {
    return ZakatConfigModel(
      nisabPerYear: (json['nisab_per_year'] as num).toDouble(),
      nisabDecree: BaznasDecreeModel.fromJson(
        json['nisab_decree'] as Map<String, dynamic>,
      ),
      fitrahPerPerson: (json['fitrah_per_person'] as num).toInt(),
      fitrahDecree: BaznasDecreeModel.fromJson(
        json['fitrah_decree'] as Map<String, dynamic>,
      ),
      goldPricePerGram: (json['gold_price_per_gram'] as num).toDouble(),
      silverPricePerGram: (json['silver_price_per_gram'] as num).toDouble(),
      priceUpdatedAt: DateTime.parse(json['price_updated_at'] as String),
    );
  }
}
