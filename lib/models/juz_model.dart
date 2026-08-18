import 'package:deenly/models/surah_model.dart';

class JuzModel {
  int juzNumber;
  SurahModel surahDetail;
  int surahFrom;
  int surahTo;

  JuzModel({
    required this.juzNumber,
    required this.surahDetail,
    required this.surahFrom,
    required this.surahTo,
  });

  factory JuzModel.fromDatabase(Map<String, dynamic> json, SurahModel model) {
    return JuzModel(
      juzNumber: json["juz_number"],
      surahDetail: model,
      surahFrom: json["ayah_from"],
      surahTo: json["ayah_to"],
    );
  }
}
