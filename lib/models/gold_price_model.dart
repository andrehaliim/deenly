class GoldPriceModel {
  final double goldPerGram;
  final double silverPerGram;
  final String source;
  final DateTime updatedAt;

  const GoldPriceModel({
    required this.goldPerGram,
    required this.silverPerGram,
    required this.source,
    required this.updatedAt,
  });

  factory GoldPriceModel.fromDatabase(Map<String, dynamic> json) {
    return GoldPriceModel(
      goldPerGram: (json['gold_per_gram'] as num).toDouble(),
      silverPerGram: (json['silver_per_gram'] as num).toDouble(),
      source: json['source'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': 1,
      'gold_per_gram': goldPerGram,
      'silver_per_gram': silverPerGram,
      'source': source,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
