import 'dart:convert';

import 'package:deenly/components/database_helper.dart';
import 'package:deenly/models/continue_model.dart';
import 'package:deenly/models/juz_model.dart';
import 'package:deenly/models/surah_detail_model.dart';
import 'package:deenly/models/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class SurahProvider extends ChangeNotifier {
  final baseUrl = 'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';

  /// Full list from the database; [_surahList] is the filtered view shown
  /// by the search.
  List<SurahModel> _allSurahs = [];
  Map<int, SurahModel> _surahById = {};
  List<SurahModel> _surahList = [];
  final List<JuzModel> _surahJuzList = [];
  List<ContinueModel> _continueList = [];
  bool _isLoading = false;
  String? _code;
  List<SurahDetailModel>? _surahDetail;
  bool _isDetailLoading = false;

  bool get isLoading => _isLoading;
  List<SurahModel> get surahList => _surahList;
  List<JuzModel> get surahJuzList => _surahJuzList;
  List<ContinueModel> get continueList => _continueList;
  String? get code => _code;
  List<SurahDetailModel>? get surahDetail => _surahDetail;
  bool get isDetailLoading => _isDetailLoading;

  /// The surah data holds every language, so a language change only needs
  /// a rebuild, not a reload.
  void updateLanguage(String? code) {
    if (_code != code) {
      _code = code;
      Future.microtask(notifyListeners);
    }
  }

  /// Shows the loading state only on the first load, so later refreshes do
  /// not replace the list with a spinner.
  Future<void> getSurahList() async {
    final isFirstLoad = _allSurahs.isEmpty;
    if (isFirstLoad) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(DatabaseHelper.tableSurah);
      _allSurahs = result.map((e) => SurahModel.fromDatabase(e)).toList();
      _surahById = {for (final surah in _allSurahs) surah.id: surah};
      _surahList = _allSurahs;
    } catch (e) {
      debugPrint('Error loading surah list: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getJuzList() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('juz');
      final List<JuzModel> tempList = [];
      for (final data in result) {
        final surah = await getSurahById(data['surah_id'] as int);
        tempList.add(JuzModel.fromDatabase(data, surah));
      }
      _surahJuzList
        ..clear()
        ..addAll(tempList);
    } catch (e) {
      debugPrint('Error loading juz list: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<SurahModel> getSurahById(int id) async {
    final cached = _surahById[id];
    if (cached != null) return cached;

    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      DatabaseHelper.tableSurah,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) throw StateError('Surah $id not found');
    return SurahModel.fromDatabase(result.first);
  }

  Future<List<SurahDetailModel>> getSurahDetail(int chapterNo) async {
    final current = _surahDetail;
    if (current != null &&
        current.isNotEmpty &&
        current.first.chapterNo != chapterNo) {
      _surahDetail = null;
    }

    final cached = await _getFromDatabase(chapterNo);
    if (cached.isNotEmpty) {
      _surahDetail = cached;
      _isDetailLoading = false;
      notifyListeners();
      return cached;
    }

    _isDetailLoading = true;
    _surahDetail = null;
    notifyListeners();

    try {
      final result = await _fetchSurahDetail(chapterNo);
      await _saveToDatabase(result);
      _surahDetail = result;
      return result;
    } catch (e) {
      debugPrint('Error loading surah detail: $e');
      _surahDetail = null;
      rethrow;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<List<SurahDetailModel>> _fetchSurahDetail(int surahNumber) async {
    final urls = [
      '$baseUrl/editions/ara-quranacademy/$surahNumber.json',
      '$baseUrl/editions/eng-ummmuhammad/$surahNumber.json',
      '$baseUrl/editions/ind-indonesianislam/$surahNumber.json',
    ];

    final responses = await Future.wait(
      urls.map((url) => http.get(Uri.parse(url))),
    );

    for (final res in responses) {
      if (res.statusCode != 200) {
        throw Exception('Failed fetch: ${res.request?.url}');
      }
    }

    final arJson = jsonDecode(responses[0].body)['chapter'] as List;
    final enJson = jsonDecode(responses[1].body)['chapter'] as List;
    final idJson = jsonDecode(responses[2].body)['chapter'] as List;

    final result = <SurahDetailModel>[];
    for (var i = 0; i < arJson.length; i++) {
      result.add(
        SurahDetailModel(
          chapterNo: arJson[i]['chapter'],
          verseNo: arJson[i]['verse'],
          textAr: arJson[i]['text'],
          textEn: enJson[i]['text'],
          textId: idJson[i]['text'],
        ),
      );
    }

    return result;
  }

  Future<List<SurahDetailModel>> _getFromDatabase(int chapterNo) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      DatabaseHelper.tableSurahDetail,
      where: 'chapter_no = ?',
      whereArgs: [chapterNo],
      orderBy: 'verse_no ASC',
    );

    return rows.map((row) => SurahDetailModel.fromDatabase(row)).toList();
  }

  Future<void> _saveToDatabase(List<SurahDetailModel> ayahs) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final ayah in ayahs) {
        batch.insert(
          DatabaseHelper.tableSurahDetail,
          {
            'chapter_no': ayah.chapterNo,
            'verse_no': ayah.verseNo,
            'text_arabic': ayah.textAr,
            'text_english': ayah.textEn,
            'text_indonesian': ayah.textId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> getContinueList() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        DatabaseHelper.tableContinueReading,
        orderBy: 'updatedAt DESC',
        limit: 5,
      );

      final List<ContinueModel> tempList = [];
      for (var data in result) {
        final surah = await getSurahById(data['surah_id'] as int);
        tempList.add(ContinueModel.fromMap(data, surah));
      }

      _continueList = tempList;
    } catch (e) {
      debugPrint('Error loading continue list: $e');
    } finally {
      notifyListeners();
    }
  }

  void searchSurah(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _surahList = _allSurahs;
      notifyListeners();
      return;
    }

    final normalizedQuery = _normalize(trimmed);
    final numberQuery = int.tryParse(trimmed);

    _surahList = _allSurahs
        .where(
          (surah) =>
              _normalize(surah.nameIndo).contains(normalizedQuery) ||
              _normalize(surah.nameEng).contains(normalizedQuery) ||
              (numberQuery != null && surah.id == numberQuery),
        )
        .toList();
    notifyListeners();
  }

  static final RegExp _normalizePattern = RegExp(r"[-'\s]");

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(_normalizePattern, '');
  }
}
