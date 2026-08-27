import 'package:deenly/models/surah_model.dart';

class ContinueModel {
  final SurahModel surah;
  final int ayahNumber;
  final DateTime updatedAt;

  ContinueModel({
    required this.surah,
    required this.ayahNumber,
    required this.updatedAt,
  });

  factory ContinueModel.fromMap(Map<String, dynamic> map, SurahModel surah) {
    return ContinueModel(
      surah: surah,
      ayahNumber: map['ayah_number'] as int,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
