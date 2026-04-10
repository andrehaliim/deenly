class SurahModel {
  int id;
  String name;
  String englishname;
  String arabicname;
  String revelation;
  int totalAyahs;

  SurahModel({
    required this.id,
    required this.name,
    required this.englishname,
    required this.arabicname,
    required this.revelation,
    required this.totalAyahs,
  });

  factory SurahModel.fromJsonApi(Map<String, dynamic> json) => SurahModel(
    id: json["chapter"],
    name: json["name"],
    englishname: json["englishname"],
    arabicname: json["arabicname"],
    revelation: json["revelation"],
    totalAyahs: (json["verses"] as List?)?.length ?? 0,
  );

  factory SurahModel.fromJsonLocal(Map<String, dynamic> json) {
    return SurahModel(
      id: json["id"],
      name: json["name"],
      englishname: json["englishname"],
      arabicname: json["arabicname"],
      revelation: json["revelation"],
      totalAyahs: json["totalAyahs"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "englishname": englishname,
    "arabicname": arabicname,
    "revelation": revelation,
    "totalAyahs": totalAyahs,
  };
}
