class AsmaulHusnaModel {
  int id;
  String textArab;
  String textLatin;
  String meaningIndo;
  String meaningEng;

  AsmaulHusnaModel({
    required this.id,
    required this.textArab,
    required this.textLatin,
    required this.meaningIndo,
    required this.meaningEng,
  });

  factory AsmaulHusnaModel.fromDatabase(Map<String, dynamic> json) {
    return AsmaulHusnaModel(
      id: json["id"],
      textArab: json["text_arabic"],
      textLatin: json["text_latin"],
      meaningIndo: json["meaning_indonesian"],
      meaningEng: json["meaning_english"],
    );
  }

  String meaning(String? code) => code == 'id' ? meaningIndo : meaningEng;
}
