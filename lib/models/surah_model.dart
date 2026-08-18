class SurahModel {
  int id;
  String nameEng;
  String nameIndo;
  String nameArab;
  String descEng;
  String descIndo;
  int surahFrom;
  int surahTotal;

  SurahModel({
    required this.id,
    required this.nameEng,
    required this.nameIndo,
    required this.nameArab,
    required this.descEng,
    required this.descIndo,
    required this.surahFrom,
    required this.surahTotal,
  });

  factory SurahModel.fromDatabase(Map<String, dynamic> json) {
    return SurahModel(
      id: json["id"],
      nameEng: json["name_english"],
      nameIndo: json["name_indonesian"],
      nameArab: json["name_arabic"],
      descEng: json["desc_english"],
      descIndo: json["desc_indonesian"],
      surahFrom: json["surah_from"],
      surahTotal: json["ayah_total"],
    );
  }

  String name(String? code) => code == 'id' ? nameIndo : nameEng;
  String desc(String? code) => code == 'id' ? descIndo : descEng;
}
