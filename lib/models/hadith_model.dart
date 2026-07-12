class HadithModel {
    int id;
    String englishNarrator;
    String hadithEnglish;
    String hadithIndonesian;

    HadithModel({
        required this.id,
        required this.englishNarrator,
        required this.hadithEnglish,
        required this.hadithIndonesian,
    });

    factory HadithModel.fromJson(Map<String, dynamic> json) => HadithModel(
        id: json["id"],
        englishNarrator: json["englishNarrator"],
        hadithEnglish: json["hadithEnglish"],
        hadithIndonesian: json["hadithIndonesian"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "englishNarrator": englishNarrator,
        "hadithEnglish": hadithEnglish,
        "hadithIndonesian": hadithIndonesian,
    };
}