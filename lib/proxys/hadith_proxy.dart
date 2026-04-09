import 'dart:convert';
import 'dart:math';
import 'package:deenly/components/database_helper.dart';
import 'package:deenly/models/hadith_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class HadithProxy {
  static const String _baseUrl = 'https://hadithapi.com/api/hadiths';
  static const String _apiKey =
      r"$2y$10$WePIziIDExAzRu7TEVpE4CwrLa4WlaH5ZfSexyeBR6GThSZIV6";

  Future<List<HadithModel>> getAllHadith() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM hadith");

    if (maps.isNotEmpty) {
      debugPrint('Hadith loaded from local database');
      return List.generate(maps.length, (i) {
        return HadithModel.fromJson(maps[i]);
      });
    } else {
      // Fetch from API if local DB is empty
      List<HadithModel> apiHadiths = await _fetchFromApi();
      for (var hadith in apiHadiths) {
        debugPrint('Inserting hadith');
        await db.insert('hadith', hadith.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      debugPrint('Hadith loaded from API');
      return apiHadiths;
    }
  }

  Future<List<HadithModel>> _fetchFromApi() async {
    final response = await http.get(
      Uri.parse("$_baseUrl/?apiKey=$_apiKey&paginate=30"),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final List data = decodedResponse['hadiths']['data'];

      return data.map((e) => HadithModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load daily hadith from API');
    }
  }

  Future<HadithModel> getDailyHadith() async {
    List<HadithModel> hadiths = await getAllHadith();
    if (hadiths.isNotEmpty) {
      final random = Random();
      final randomIndex = random.nextInt(hadiths.length);
      return hadiths[randomIndex];
    } else {
      throw Exception('No hadith available in local database or API');
    }
  }

  Future<void> clearHadith() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('hadith');
  }
}

