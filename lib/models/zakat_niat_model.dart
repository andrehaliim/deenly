import 'package:deenly/models/localized_text_model.dart';
import 'package:deenly/models/zakat_source_model.dart';

/// A zakat intention or prayer, using the same keys as doa.json plus an
/// optional `catatan` note, e.g. where to say a name.
class ZakatNiatModel {
  final String id;
  final LocalizedText group;
  final LocalizedText name;
  final String textArab;
  final String textLatin;
  final LocalizedText translation;
  final LocalizedText? note;

  const ZakatNiatModel({
    required this.id,
    required this.group,
    required this.name,
    required this.textArab,
    required this.textLatin,
    required this.translation,
    required this.note,
  });

  factory ZakatNiatModel.fromJson(Map<String, dynamic> json) {
    final group = LocalizedText.maybeFromKeys(json, 'grup', 'grup_en');
    final name = LocalizedText.maybeFromKeys(json, 'nama', 'nama_en');
    final translation = LocalizedText.maybeFromKeys(json, 'idn', 'en');
    if (group == null || name == null || translation == null) {
      throw FormatException('Incomplete zakat niat: $json');
    }
    return ZakatNiatModel(
      id: json['id'] as String,
      group: group,
      name: name,
      textArab: json['ar'] as String,
      textLatin: json['tr'] as String,
      translation: translation,
      note: LocalizedText.maybeFromKeys(json, 'catatan', 'catatan_en'),
    );
  }
}

class ZakatNiatListModel {
  final List<ZakatSourceModel> sources;
  final List<ZakatNiatModel> items;

  const ZakatNiatListModel({required this.sources, required this.items});

  factory ZakatNiatListModel.fromJson(Map<String, dynamic> json) {
    return ZakatNiatListModel(
      sources: ZakatSourceModel.listFromJson(json['sources']),
      items: (json['data'] as List<dynamic>)
          .map((e) => ZakatNiatModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
