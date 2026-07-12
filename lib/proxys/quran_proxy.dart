import 'dart:convert';

import 'package:deenly/components/database_helper.dart';
import 'package:deenly/models/surah_detail_model.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class QuranProxy {
  final baseUrl = 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';



  Future<List<SurahDetailModel>> getSurahDetails(int id) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT * FROM surah_detail WHERE surah_id = ?",
      [id],
    );

    if (maps.isNotEmpty) {
      debugPrint('Surah details loaded from local database');
      return List.generate(maps.length, (i) {
        return SurahDetailModel.fromJsonLocal(maps[i]);
      });
    } else {
      List<SurahDetailModel> apiSurahDetails = await _fetchSurahDetails(id);
      for (var surahDetail in apiSurahDetails) {
        debugPrint('Inserting surah detail');
        await db.insert(
          'surah_detail',
          surahDetail.toJson(id),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      debugPrint('Surah details loaded from API');
      return apiSurahDetails;
    }
  }

  Future<List<SurahDetailModel>> _fetchSurahDetails(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('selected_locale');
    final url1 = '$baseUrl/editions/ara-quranacademy/$id.json';
    final url2 = code == 'id'
        ? '$baseUrl/editions/ind-indonesianislam/$id.json'
        : '$baseUrl/editions/eng-ummmuhammad/$id.json';
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
        data.translation = json2['chapter'][data.verseNo - 1]['text'];
      }
      return surahDetailList;
    } else {
      throw Exception('Failed to load surah detail');
    }
  }

  Future<void> clearSurahDetails() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('surah_detail');
    debugPrint('Surah details table cleared');
  }
}
