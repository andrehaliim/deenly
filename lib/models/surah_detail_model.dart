class SurahDetailModel {
  int chapter;
  int verse;
  String text;
  String translation;

  SurahDetailModel({
    required this.chapter,
    required this.verse,
    required this.text,
    required this.translation,
  });

  factory SurahDetailModel.fromJsonApi(Map<String, dynamic> json) =>
      SurahDetailModel(
        chapter: json["chapter"],
        verse: json["verse"],
        text: json["text"],
        translation: json["text"],
    );
    
  factory SurahDetailModel.fromJsonLocal(Map<String, dynamic> json) =>
      SurahDetailModel(
        chapter: json["chapter"],
        verse: json["verse"],
        text: json["text"],
        translation: json["translation"],
    );

    Map<String, dynamic> toJson() => {
        "chapter": chapter,
        "verse": verse,
        "text": text,
        "translation": translation,
    };
}