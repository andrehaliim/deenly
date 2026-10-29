/// A text kept in both app languages, read from a pair of JSON keys with
/// the `_id` and `_en` suffixes.
class LocalizedText {
  final String indonesian;
  final String english;

  const LocalizedText({required this.indonesian, required this.english});

  static LocalizedText? maybeFromJson(Map<String, dynamic> json, String key) {
    final indonesian = json['${key}_id'];
    final english = json['${key}_en'];
    if (indonesian is! String || english is! String) return null;
    return LocalizedText(indonesian: indonesian, english: english);
  }

  String of(String languageCode) => languageCode == 'id' ? indonesian : english;
}

class ZakatGuideModel {
  final String sourceName;
  final String sourceUrl;
  final List<ZakatGuideSectionModel> sections;

  const ZakatGuideModel({
    required this.sourceName,
    required this.sourceUrl,
    required this.sections,
  });

  factory ZakatGuideModel.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>;
    return ZakatGuideModel(
      sourceName: source['name'] as String,
      sourceUrl: source['url'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map(
            (e) => ZakatGuideSectionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

/// Every part but the title is optional, so one layout fits a plain
/// paragraph, a verse, lists of conditions or any mix of them.
class ZakatGuideSectionModel {
  final String id;
  final LocalizedText title;
  final LocalizedText? body;
  final List<ZakatGuideVerseModel> verses;
  final List<ZakatGuideGroupModel> groups;

  const ZakatGuideSectionModel({
    required this.id,
    required this.title,
    required this.body,
    required this.verses,
    required this.groups,
  });

  factory ZakatGuideSectionModel.fromJson(Map<String, dynamic> json) {
    final title = LocalizedText.maybeFromJson(json, 'title');
    if (title == null) {
      throw FormatException('Zakat guide section without a title: $json');
    }
    return ZakatGuideSectionModel(
      id: json['id'] as String,
      title: title,
      body: LocalizedText.maybeFromJson(json, 'body'),
      verses: ((json['verses'] as List<dynamic>?) ?? const [])
          .map((e) => ZakatGuideVerseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      groups: ((json['groups'] as List<dynamic>?) ?? const [])
          .map((e) => ZakatGuideGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ZakatGuideVerseModel {
  final int surah;
  final int ayah;
  final LocalizedText surahName;
  final String textArab;
  final LocalizedText translation;

  const ZakatGuideVerseModel({
    required this.surah,
    required this.ayah,
    required this.surahName,
    required this.textArab,
    required this.translation,
  });

  factory ZakatGuideVerseModel.fromJson(Map<String, dynamic> json) {
    final surahName = LocalizedText.maybeFromJson(json, 'surah_name');
    final translation = LocalizedText.maybeFromJson(json, 'translation');
    if (surahName == null || translation == null) {
      throw FormatException('Incomplete zakat guide verse: $json');
    }
    return ZakatGuideVerseModel(
      surah: (json['surah'] as num).toInt(),
      ayah: (json['ayah'] as num).toInt(),
      surahName: surahName,
      textArab: json['ar'] as String,
      translation: translation,
    );
  }
}

class ZakatGuideGroupModel {
  final LocalizedText? title;
  final List<ZakatGuideItemModel> items;
  final LocalizedText? note;

  const ZakatGuideGroupModel({
    required this.title,
    required this.items,
    required this.note,
  });

  factory ZakatGuideGroupModel.fromJson(Map<String, dynamic> json) {
    return ZakatGuideGroupModel(
      title: LocalizedText.maybeFromJson(json, 'title'),
      items: (json['items'] as List<dynamic>)
          .map((e) => ZakatGuideItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      note: LocalizedText.maybeFromJson(json, 'note'),
    );
  }
}

class ZakatGuideItemModel {
  final LocalizedText title;
  final LocalizedText? description;

  const ZakatGuideItemModel({required this.title, required this.description});

  factory ZakatGuideItemModel.fromJson(Map<String, dynamic> json) {
    final title = LocalizedText.maybeFromJson(json, 'title');
    if (title == null) {
      throw FormatException('Zakat guide item without a title: $json');
    }
    return ZakatGuideItemModel(
      title: title,
      description: LocalizedText.maybeFromJson(json, 'desc'),
    );
  }
}
