class SurahDetailModel {
  int chapterNo;
  int verseNo;
  String textAr;
  String textEn;
  String textId;

  SurahDetailModel({
    required this.chapterNo,
    required this.verseNo,
    required this.textAr,
    required this.textEn,
    required this.textId,
  });

  factory SurahDetailModel.fromJson(Map<String, dynamic> json) =>
      SurahDetailModel(
        chapterNo: json['chapterNo'],
        verseNo: json['verseNo'],
        textAr: json['textAr'],
        textEn: json['textEn'],
        textId: json['textId'],
      );

      factory SurahDetailModel.fromDatabase(Map<String, dynamic> json) =>
      SurahDetailModel(
        chapterNo: json['chapter_no'],
        verseNo: json['verse_no'],
        textAr: json['text_arabic'],
        textEn: json['text_english'],
        textId: json['text_indonesian'],
      );

  Map<String, dynamic> toJson(int id) => {
    'id': id,
    'chapterNo': chapterNo,
    'verseNo': verseNo,
    'textAr': textAr,
    'textEn': textEn,
    'textId': textId,
  };

  String text(String? code) => code == 'id' ? textId : textEn;
}
