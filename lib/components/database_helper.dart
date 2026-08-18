import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String tableSurah = 'surah';
  static const String tableSurahDetail = 'surah_detail';
  static const String tablePrayer = 'prayer';
  static const String tableHadith = 'hadith';
  static const String tableJuz = 'juz';

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('deenly.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableSurah(
        id INTEGER PRIMARY KEY,
        name_english TEXT,
        name_indonesian TEXT,
        name_arabic TEXT,
        desc_english TEXT,
        desc_indonesian TEXT,
        surah_from INTEGER,
        ayah_total INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSurahDetail(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      chapter_no INTEGER,
      verse_no INTEGER,
      text_arabic TEXT,
      text_english TEXT,
      text_indonesian TEXT
    )
  ''');

    await db.execute('''
      CREATE TABLE $tablePrayer(
        id INTEGER PRIMARY KEY,
        fajr TEXT,
        dhuhr TEXT,
        asr TEXT,
        maghrib TEXT,
        isha TEXT,
        date TEXT,
        hijriDate TEXT,
        hijriMonth TEXT,
        hijriYear TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableHadith(
        id INTEGER PRIMARY KEY,
        englishNarrator TEXT,
        hadithEnglish TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableJuz(
        juz_number INTEGER,
        surah_id INTEGER,
        ayah_from INTEGER,
        ayah_to INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS $tableSurah');
      await db.execute('DROP TABLE IF EXISTS $tableSurahDetail');

      await db.execute('''
      CREATE TABLE $tableSurah(
        id INTEGER PRIMARY KEY,
        name_english TEXT,
        name_indonesian TEXT,
        name_arabic TEXT,
        desc_english TEXT,
        desc_indonesian TEXT,
        surah_from INTEGER,
        ayah_total INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSurahDetail(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      chapter_no INTEGER,
      verse_no INTEGER,
      text_arabic TEXT,
      text_english TEXT,
      text_indonesian TEXT
    )
  ''');
    }

    if (oldVersion < 5) {
      await db.execute('DROP TABLE IF EXISTS $tableJuz');
      await db.execute('''
      CREATE TABLE $tableJuz(
        juz_number INTEGER,
        surah_id INTEGER,
        ayah_from INTEGER,
        ayah_to INTEGER
      )
    ''');
    }
  }

  Future<void> exportDB() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/deenly.db';

    final file = File(path);
    final copyPath =
        '/storage/emulated/0/Download/deenly_${DateTime.now().millisecondsSinceEpoch}.db';
    await file.copy(copyPath);
    debugPrint('DB Exported, to pull run "adb pull $copyPath"');
  }

  Future<void> seedSurahIfNeeded() async {
    final alreadySeeded = await _isSurahSeeded();
    if (alreadySeeded) return;

    final db = await database;
    final chapters = await _loadSurahJson();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final chapter in chapters) {
        batch.insert(tableSurah, {
          'id': chapter['chapter'],
          'name_english': chapter['name_en'],
          'name_indonesian': chapter['name_id'],
          'name_arabic': chapter['name_ar'],
          'desc_english': chapter['desc_en'],
          'desc_indonesian': chapter['desc_id'],
          'surah_from': chapter['from'],
          'ayah_total': chapter['total'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    });
  }

  Future<bool> _isSurahSeeded() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM surah'),
    );
    return (result ?? 0) > 0;
  }

  Future<List<Map<String, dynamic>>> _loadSurahJson() async {
    final jsonString = await rootBundle.loadString('assets/jsons/surah.json');
    return compute(_parseSurahJson, jsonString);
  }

  static List<Map<String, dynamic>> _parseSurahJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> chapters = data['chapters'];
    return chapters.cast<Map<String, dynamic>>();
  }

  Future<void> seedJuzIfNeeded() async {
    final alreadySeeded = await _isJuzSeeded();
    if (alreadySeeded) return;

    final db = await database;
    final juzs = await _loadJuzJson();

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final juz in juzs) {
        for (final surah in juz['surahs']) {
          batch.insert(tableJuz, {
            'juz_number': juz['juz'],
            'surah_id': surah['chapter'],
            'ayah_from': surah['ayah_from'],
            'ayah_to': surah['ayah_to'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      await batch.commit(noResult: true);
    });
  }

  Future<bool> _isJuzSeeded() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM juz'),
    );
    return (result ?? 0) > 0;
  }

  Future<List<Map<String, dynamic>>> _loadJuzJson() async {
    final jsonString = await rootBundle.loadString('assets/jsons/juz.json');
    return compute(_parseJuzJson, jsonString);
  }

  static List<Map<String, dynamic>> _parseJuzJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> juzs = data['juz'];
    return juzs.cast<Map<String, dynamic>>();
  }
}
