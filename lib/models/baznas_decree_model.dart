/// A BAZNAS chairman's decree (SK Ketua BAZNAS), cited as the source of
/// yearly zakat values such as the nisab and the zakat fitrah amount.
class BaznasDecreeModel {
  final int number;
  final int year;

  const BaznasDecreeModel({required this.number, required this.year});

  factory BaznasDecreeModel.fromJson(Map<String, dynamic> json) {
    return BaznasDecreeModel(
      number: (json['number'] as num).toInt(),
      year: (json['year'] as num).toInt(),
    );
  }
}
