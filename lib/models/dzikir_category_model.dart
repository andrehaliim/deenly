class DzikirCategoryModel {
  int id;
  String nameIndo;
  String nameEng;
  int dzikirTotal;

  DzikirCategoryModel({
    required this.id,
    required this.nameIndo,
    required this.nameEng,
    required this.dzikirTotal,
  });

  factory DzikirCategoryModel.fromDatabase(Map<String, dynamic> json) {
    return DzikirCategoryModel(
      id: json["id"],
      nameIndo: json["name_indonesian"],
      nameEng: json["name_english"],
      dzikirTotal: json["dzikir_total"],
    );
  }

  String name(String? code) => code == 'id' ? nameIndo : nameEng;
}
