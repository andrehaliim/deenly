class DzikirModel {
  int id;
  int categoryId;
  String nameIndo;
  String nameEng;
  String textArab;
  String textLatin;
  String textIndo;
  String textEng;
  int count;
  String? noteIndo;
  String? noteEng;
  String? virtueIndo;
  String? virtueEng;
  String source;

  DzikirModel({
    required this.id,
    required this.categoryId,
    required this.nameIndo,
    required this.nameEng,
    required this.textArab,
    required this.textLatin,
    required this.textIndo,
    required this.textEng,
    required this.count,
    this.noteIndo,
    this.noteEng,
    this.virtueIndo,
    this.virtueEng,
    required this.source,
  });

  factory DzikirModel.fromDatabase(Map<String, dynamic> json) {
    return DzikirModel(
      id: json["id"],
      categoryId: json["category_id"],
      nameIndo: json["name_indonesian"],
      nameEng: json["name_english"],
      textArab: json["text_arabic"],
      textLatin: json["text_latin"] ?? '',
      textIndo: json["text_indonesian"] ?? '',
      textEng: json["text_english"] ?? '',
      count: json["count"],
      noteIndo: json["note_indonesian"],
      noteEng: json["note_english"],
      virtueIndo: json["virtue_indonesian"],
      virtueEng: json["virtue_english"],
      source: json["source"] ?? '',
    );
  }

  String name(String? code) => code == 'id' ? nameIndo : nameEng;
  String translation(String? code) => code == 'id' ? textIndo : textEng;
  String? note(String? code) => code == 'id' ? noteIndo : noteEng;
  String? virtue(String? code) => code == 'id' ? virtueIndo : virtueEng;
}
