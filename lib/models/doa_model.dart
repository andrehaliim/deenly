class DoaGroupModel {
  int id;
  String nameIndo;
  String nameEng;
  int doaTotal;

  DoaGroupModel({
    required this.id,
    required this.nameIndo,
    required this.nameEng,
    required this.doaTotal,
  });

  factory DoaGroupModel.fromDatabase(Map<String, dynamic> json) {
    return DoaGroupModel(
      id: json["id"],
      nameIndo: json["name_indonesian"],
      nameEng: json["name_english"],
      doaTotal: json["doa_total"],
    );
  }

  String name(String? code) => code == 'id' ? nameIndo : nameEng;
}

class DoaModel {
  int id;
  int groupId;
  String nameIndo;
  String nameEng;
  String textArab;
  String textLatin;
  String textIndo;
  String textEng;

  DoaModel({
    required this.id,
    required this.groupId,
    required this.nameIndo,
    required this.nameEng,
    required this.textArab,
    required this.textLatin,
    required this.textIndo,
    required this.textEng,
  });

  factory DoaModel.fromDatabase(Map<String, dynamic> json) {
    return DoaModel(
      id: json["id"],
      groupId: json["group_id"],
      nameIndo: json["name_indonesian"],
      nameEng: json["name_english"],
      textArab: json["text_arabic"],
      textLatin: json["text_latin"] ?? '',
      textIndo: json["text_indonesian"] ?? '',
      textEng: json["text_english"] ?? '',
    );
  }

  String name(String? code) => code == 'id' ? nameIndo : nameEng;
  String translation(String? code) => code == 'id' ? textIndo : textEng;
}
