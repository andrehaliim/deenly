import 'dart:convert';
import 'dart:developer';

import 'package:deenly/models/quran_model.dart';
import 'package:http/http.dart' as http;

class QuranProxy {
  Future<List<QuranModel>> getSurahList() async {
    final url = 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/info.json';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      List<QuranModel> surahList = [];
      for (var x in json['chapters']) {
        final versesCount = x['verses'].length;
        log(versesCount.toString());
        surahList.add(QuranModel.fromJson(x, versesCount));
      }
      return surahList;
    } else {
      throw Exception('Failed to load surah list');
    }
  }
}
