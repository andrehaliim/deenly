import 'dart:convert';
import 'package:deenly/models/hadith_model.dart';
import 'package:http/http.dart' as http;

class HadithProxy {
  static const String _baseUrl = 'https://hadithapi.com/api/hadiths';
  static const String _apiKey = "2y\$10\$WePIziIDExAzRu7TEVpE4CwrLa4WlaH5ZfSexyeBR6GThSZIV6";

  Future<List<HadithModel>> getAllHadith() async {
    final response = await http.get(Uri.parse("$_baseUrl/?apiKey=$_apiKey&paginate=30"));
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      return decodedResponse['hadiths']['data'].map((e) => HadithModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load daily hadith');
    }
  }
}