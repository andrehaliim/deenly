import 'dart:convert';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/models/hadith_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class HadithProxy {
  static const String _baseUrl = 'https://hadithapi.com/api/hadiths';
  static const String _apiKey =
      r"$2y$10$WePIziIDExAzRu7TEVpE4CwrLa4WlaH5ZfSexyeBR6GThSZIV6";
      
  Future<void> fetchHadith() async {
    final db = await DatabaseHelper.instance.database;
    final isEmpty = await db.rawQuery("SELECT * FROM hadith");
    if (isEmpty.isNotEmpty) {
      debugPrint("Hadith data already exists in database");
      return;
    }
    final response = await http.get(
      Uri.parse("$_baseUrl/?apiKey=$_apiKey&paginate=100"),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
    final List data = decodedResponse['hadiths']['data'];

    final batch = db.batch();

    for (var item in data) {
      final hadith = HadithModel.fromJson(item);

      batch.insert(
        'hadith',
        hadith.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    debugPrint("Hadith data saved to database");
    await batch.commit(noResult: true);
    } else {
      throw Exception('Failed to load daily hadith from API');
    }
  }

  Future<HadithModel> getDailyHadith() async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM hadith ORDER BY RANDOM() LIMIT 1");

    if (maps.isNotEmpty) {
      return HadithModel.fromJson(maps.first);
    } else {
      throw Exception('No hadith available in local database or API');
    }
  }

  Future<void> clearHadith() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('hadith');
  }
}

