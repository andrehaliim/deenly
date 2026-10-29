/// Where a piece of bundled zakat content was taken from, shown as a
/// link at the end of its page.
class ZakatSourceModel {
  final String name;
  final String url;

  const ZakatSourceModel({required this.name, required this.url});

  factory ZakatSourceModel.fromJson(Map<String, dynamic> json) {
    return ZakatSourceModel(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  static List<ZakatSourceModel> listFromJson(dynamic json) {
    return (json as List<dynamic>)
        .map((e) => ZakatSourceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
