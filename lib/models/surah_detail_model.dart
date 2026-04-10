class SurahDetailModel {
  int surahId;
  int verseNo;
  String text;
  String translation;

  SurahDetailModel({
    required this.surahId,
    required this.verseNo,
    required this.text,
    required this.translation,
  });

  factory SurahDetailModel.fromJsonApi(Map<String, dynamic> json) =>
      SurahDetailModel(
        surahId: json["chapter"],
        verseNo: json["verse"],
        text: json["text"],
        translation: json["text"],
      );

  factory SurahDetailModel.fromJsonLocal(Map<String, dynamic> json) =>
      SurahDetailModel(
        surahId: json["surah_id"],
        verseNo: json["verse"],
        text: json["text"],
        translation: json["translation"],
      );

  Map<String, dynamic> toJson(int id) => {
    "surah_id": id,
    "verse": verseNo,
    "text": text,
    "translation": translation,
  };
}
