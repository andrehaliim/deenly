import 'dart:convert';

import 'package:deenly/models/surah_detail_model.dart';
import 'package:deenly/models/surah_list_model.dart';
import 'package:http/http.dart' as http;

class QuranProxy {
  Future<List<SurahListModel>> getSurahList() async {
  final url = 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/info.json';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);

    final futures = (json['chapters'] as List).map((x) async {
      final surahDetailList = await getSurahDetail(x['chapter']);
      return SurahListModel.fromJsonApi(x, surahDetailList);
    });

    return await Future.wait(futures);
  } else {
    throw Exception('Failed to load surah list');
  }
}

  Future<List<SurahDetailModel>> getSurahDetail(int id) async {
    final url1 =
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/ara-quranacademy/$id.json';
    final url2 =
        'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1/editions/eng-ummmuhammad/$id.json';
    final response1 = await http.get(Uri.parse(url1));
    final response2 = await http.get(Uri.parse(url2));
    if (response1.statusCode == 200 && response2.statusCode == 200) {
      final json1 = jsonDecode(response1.body);
      final json2 = jsonDecode(response2.body);
      List<SurahDetailModel> surahDetailList = [];
      for (var x in json1['chapter']) {
        surahDetailList.add(SurahDetailModel.fromJsonApi(x));
      }
      for (var data in surahDetailList) {
        data.translation = json2['chapter'][data.verse - 1]['text'];
      }
      return surahDetailList;
    } else {
      throw Exception('Failed to load surah detail');
    }
  }
}
