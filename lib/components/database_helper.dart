import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hadith (
        id INTEGER PRIMARY KEY,
        englishNarrator TEXT,
        hadithEnglish TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE surah(
        id INTEGER PRIMARY KEY,
        name TEXT,
        englishname TEXT,
        arabicname TEXT,
        revelation TEXT,
        totalAyahs INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE surah_detail(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER,
        verse INTEGER,
        text TEXT,
        translation TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE prayer(
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
  }
}
