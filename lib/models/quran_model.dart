class QuranModel {
    int chapter;
    String name;
    String englishname;
    String arabicname;
    String revelation;
    int verses;

    QuranModel({
        required this.chapter,
        required this.name,
        required this.englishname,
        required this.arabicname,
        required this.revelation,
        required this.verses,
    });

    factory QuranModel.fromJson(Map<String, dynamic> json, int versesCount) => QuranModel(
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