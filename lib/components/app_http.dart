/// Shared settings for requests to third-party APIs.
class AppHttp {
  /// Identifies the app to APIs that block the default `Dart/x.y` agent
  /// (gold-api.com) or require a contact (Nominatim).
  static const String userAgent =
      'DeenlyApp/1.0 (+https://andrehaliim.vercel.app/projects/deenly)';
}
