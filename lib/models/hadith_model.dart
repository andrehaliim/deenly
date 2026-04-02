class HadithModel {
    int id;
    String englishNarrator;
    String hadithEnglish;

    HadithModel({
        required this.id,
        required this.englishNarrator,
        required this.hadithEnglish,
    });

    factory HadithModel.fromJson(Map<String, dynamic> json) => HadithModel(
        id: json["id"],
        englishNarrator: json["englishNarrator"],
        hadithEnglish: json["hadithEnglish"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "englishNarrator": englishNarrator,
        "hadithEnglish": hadithEnglish,
    };
}