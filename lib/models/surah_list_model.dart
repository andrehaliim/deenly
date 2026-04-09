import 'package:deenly/models/surah_detail_model.dart';

class SurahListModel {
  int chapter;
  String name;
  String englishname;
  String arabicname;
  String revelation;
  List<SurahDetailModel> verses;

  SurahListModel({
    required this.chapter,
    required this.name,
    required this.englishname,
    required this.arabicname,
    required this.revelation,
    required this.verses,
  });

  factory SurahListModel.fromJsonApi(
    Map<String, dynamic> json,
    List<SurahDetailModel> ayahs,
  ) => SurahListModel(
    chapter: json["chapter"],
    name: json["name"],
    englishname: json["englishname"],
    arabicname: json["arabicname"],
    revelation: json["revelation"],
    verses: ayahs,
  );

  factory SurahListModel.fromJsonLocal(Map<String, dynamic> json) {
    return SurahListModel(
      chapter: json["chapter"],
      name: json["name"],
      englishname: json["englishname"],
      arabicname: json["arabicname"],
      revelation: json["revelation"],
      verses: (json["verses"] as List)
          .map((e) => SurahDetailModel.fromJsonLocal(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "chapter": chapter,
    "name": name,
    "englishname": englishname,
    "arabicname": arabicname,
    "revelation": revelation,
    "verses": verses.map((e) => e.toJson()).toList(),
  };
}
