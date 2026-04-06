class SurahListModel {
  int chapter;
  String name;
  String englishname;
  String arabicname;
  String revelation;
  int verses;

  SurahListModel({
    required this.chapter,
    required this.name,
    required this.englishname,
    required this.arabicname,
    required this.revelation,
    required this.verses,
  });

  factory SurahListModel.fromJson(Map<String, dynamic> json, int versesCount) =>
      SurahListModel(
        chapter: json["chapter"],
        name: json["name"],
        englishname: json["englishname"],
        arabicname: json["arabicname"],
        revelation: json["revelation"],
        verses: versesCount,
      );

  Map<String, dynamic> toJson() => {
    "chapter": chapter,
    "name": name,
    "englishname": englishname,
    "arabicname": arabicname,
    "revelation": revelation,
    "verses": verses,
  };
}
