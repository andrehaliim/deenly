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

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: json["chapter"],
      nameEng: json["name_en"],
      nameIndo: json["name_id"],
      nameArab: json["name_ar"],
      descEng: json["desc_en"],
      descIndo: json["desc_id"],
      surahFrom: json["from"],
      surahTotal: json["total"],
    );
  }

  Map<String, dynamic> toJson() => {
    "chapter": id,
    "name_en": nameEng,
    "name_id": nameIndo,
    "name_ar": nameArab,
    "desc_en": descEng,
    "desc_id": descIndo,
    "from": surahFrom,
    "total": surahTotal,
  };

  String name(String? code) => code == 'id' ? nameIndo : nameEng;
  String desc(String? code) => code == 'id' ? descIndo : descEng;
}
