/// A text kept in both app languages.
class LocalizedText {
  final String indonesian;
  final String english;

  const LocalizedText({required this.indonesian, required this.english});

  /// Reads a pair of JSON keys with the `_id` and `_en` suffixes.
  static LocalizedText? maybeFromJson(Map<String, dynamic> json, String key) {
    return maybeFromKeys(json, '${key}_id', '${key}_en');
  }

  /// For files like doa.json whose key pairs don't share a suffix pattern,
  /// e.g. `idn` and `en`.
  static LocalizedText? maybeFromKeys(
    Map<String, dynamic> json,
    String indonesianKey,
    String englishKey,
  ) {
    final indonesian = json[indonesianKey];
    final english = json[englishKey];
    if (indonesian is! String || english is! String) return null;
    return LocalizedText(indonesian: indonesian, english: english);
  }

  String of(String languageCode) => languageCode == 'id' ? indonesian : english;
}
