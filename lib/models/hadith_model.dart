class HadithModel {
  int id;
  String book;
  int hadithNumber;
  String englishNarrator;
  String hadithEnglish;
  String hadithIndonesian;

  HadithModel({
    required this.id,
    required this.book,
    required this.hadithNumber,
    required this.englishNarrator,
    required this.hadithEnglish,
    required this.hadithIndonesian,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) => HadithModel(
    id: json["id"],
    book: json["book"],
    hadithNumber: json["hadithNumber"],
    englishNarrator: json["englishNarrator"],
    hadithEnglish: json["hadithEnglish"],
    hadithIndonesian: json["hadithIndonesian"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "book": book,
    "hadithNumber": hadithNumber,
    "englishNarrator": englishNarrator,
    "hadithEnglish": hadithEnglish,
    "hadithIndonesian": hadithIndonesian,
  };
}
