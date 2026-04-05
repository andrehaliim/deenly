class MosqueModel {
  final String name;
  final double lat;
  final double lon;
  final double distance;
  String? address;

  MosqueModel({
    required this.name,
    required this.lat,
    required this.lon,
    required this.distance,
    this.address,
  });
}