import 'dart:convert';
import 'dart:io';

import 'package:deenly/proxys/prayer_log_proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static const String tableSurah = 'surah';
  static const String tableSurahDetail = 'surah_detail';
  static const String tablePrayer = 'prayer';
  static const String tablePrayerAdjustment = 'prayer_adjustment';
  static const String tablePrayerLog = 'prayer_log';
  static const String tableHadith = 'hadith';
  static const String tableJuz = 'juz';
  static const String tableContinueReading = 'continue_reading';
  static const String tableDoaGroup = 'doa_group';
  static const String tableDoa = 'doa';
  static const String tableAsmaulHusna = 'asmaul_husna';
  static const String tableDzikirCategory = 'dzikir_category';
  static const String tableDzikir = 'dzikir';

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;
    final db = await _initDB('deenly.db');
    _database = db;
    return db;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 14,
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
        imsak TEXT,
        fajr TEXT,
        sunrise TEXT,
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

    await _createSurahDetailIndex(db);

    await _createPrayerAdjustmentTable(db);
    await _createPrayerLogTable(db);

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

    await db.execute('''
      CREATE TABLE $tableContinueReading(
        surah_id INTEGER PRIMARY KEY,
        ayah_number INTEGER,
        updatedAt TEXT
      )
    ''');

    await _createDoaTables(db);
    await _createAsmaulHusnaTable(db);
    await _createDzikirTables(db);
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

    if (oldVersion < 6) {
      await db.execute('DROP TABLE IF EXISTS $tableContinueReading');
      await db.execute('''
      CREATE TABLE $tableContinueReading(
        surah_id INTEGER PRIMARY KEY,
        ayah_number INTEGER,
        updatedAt TEXT
      )
    ''');
    }

    if (oldVersion < 7) {
      List<Map<String, dynamic>> existing = [];
      try {
        existing = await db.query(
          tableContinueReading,
          orderBy: 'updatedAt DESC',
        );
      } catch (_) {}

      await db.execute('DROP TABLE IF EXISTS $tableContinueReading');
      await db.execute('''
      CREATE TABLE $tableContinueReading(
        surah_id INTEGER PRIMARY KEY,
        ayah_number INTEGER,
        updatedAt TEXT
      )
    ''');

      final Map<int, Map<String, dynamic>> uniqueRows = {};
      for (final row in existing) {
        final surahId = row['surah_id'] as int?;
        if (surahId != null && !uniqueRows.containsKey(surahId)) {
          uniqueRows[surahId] = row;
        }
      }

      for (final row in uniqueRows.values) {
        await db.insert(tableContinueReading, {
          'surah_id': row['surah_id'],
          'ayah_number': row['ayah_number'],
          'updatedAt': row['updatedAt'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    if (oldVersion < 8) {
      await _createPrayerAdjustmentTable(db);
      await _migratePrayerAdjustmentsFromPrefs(db);
    }

    if (oldVersion < 9) {
      await _createSurahDetailIndex(db);
    }

    if (oldVersion < 10) {
      await _createDoaTables(db);
    }

    if (oldVersion < 11) {
      await _createAsmaulHusnaTable(db);
    }

    /// Existing rows stay empty until the next sync refetches them.
    if (oldVersion < 12) {
      await db.execute('ALTER TABLE $tablePrayer ADD COLUMN imsak TEXT');
      await db.execute('ALTER TABLE $tablePrayer ADD COLUMN sunrise TEXT');
    }

    if (oldVersion < 13) {
      await _createPrayerLogTable(db);
      await _migratePrayerLogFromPrefs(db);
    }

    if (oldVersion < 14) {
      await _createDzikirTables(db);
    }
  }

  /// One row per prayer marked as done; a missing row means not done.
  Future<void> _createPrayerLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tablePrayerLog(
        date TEXT NOT NULL,
        prayer TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        PRIMARY KEY (date, prayer)
      )
    ''');
  }

  /// The old tracker kept only today's checks in prefs and reset them every
  /// day, so only today's are worth keeping.
  Future<void> _migratePrayerLogFromPrefs(Database db) async {
    final prefs = await SharedPreferences.getInstance();
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final now = DateTime.now();
    final legacyToday = '${now.year}-${now.month}-${now.day}';

    if (prefs.getString('prayerProgressLastReset') == legacyToday) {
      final date = PrayerLogProxy.dateKey(now);
      for (final prayer in prayers) {
        if (prefs.getBool('${prayer.toLowerCase()}Progress') != true) continue;
        await db.insert(tablePrayerLog, {
          'date': date,
          'prayer': prayer,
          'updatedAt': now.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    await prefs.remove('prayerProgressLastReset');
    for (final prayer in prayers) {
      await prefs.remove('${prayer.toLowerCase()}Progress');
    }
  }

  /// Opening a surah filters by chapter and sorts by verse; without this
  /// index every open scans the whole table.
  Future<void> _createSurahDetailIndex(Database db) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_surah_detail_chapter_verse
      ON $tableSurahDetail(chapter_no, verse_no)
    ''');
  }

  /// Groups are a separate table so the category list can be read without
  /// scanning every doa, and keeps its own display order.
  Future<void> _createDoaTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableDoaGroup(
        id INTEGER PRIMARY KEY,
        name_indonesian TEXT NOT NULL,
        name_english TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableDoa(
        id INTEGER PRIMARY KEY,
        group_id INTEGER NOT NULL REFERENCES $tableDoaGroup(id),
        name_indonesian TEXT NOT NULL,
        name_english TEXT NOT NULL,
        text_arabic TEXT NOT NULL,
        text_latin TEXT,
        text_indonesian TEXT,
        text_english TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_doa_group_id
      ON $tableDoa(group_id)
    ''');
  }

  /// Same layout as the doa tables; the dzikir id is also the reading order
  /// within a category.
  Future<void> _createDzikirTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableDzikirCategory(
        id INTEGER PRIMARY KEY,
        name_indonesian TEXT NOT NULL,
        name_english TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableDzikir(
        id INTEGER PRIMARY KEY,
        category_id INTEGER NOT NULL REFERENCES $tableDzikirCategory(id),
        name_indonesian TEXT NOT NULL,
        name_english TEXT NOT NULL,
        text_arabic TEXT NOT NULL,
        text_latin TEXT,
        text_indonesian TEXT,
        text_english TEXT,
        count INTEGER NOT NULL,
        note_indonesian TEXT,
        note_english TEXT,
        virtue_indonesian TEXT,
        virtue_english TEXT,
        source TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_dzikir_category_id
      ON $tableDzikir(category_id)
    ''');
  }

  /// The id is the name's traditional order (1-99), so it also serves as
  /// the display order.
  Future<void> _createAsmaulHusnaTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableAsmaulHusna(
        id INTEGER PRIMARY KEY,
        text_arabic TEXT NOT NULL,
        text_latin TEXT NOT NULL,
        meaning_indonesian TEXT NOT NULL,
        meaning_english TEXT NOT NULL
      )
    ''');
  }

  /// Kept in the database so it is updated in the same transaction as the
  /// prayer times it was applied to.
  Future<void> _createPrayerAdjustmentTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tablePrayerAdjustment(
        prayer TEXT PRIMARY KEY,
        minutes INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _migratePrayerAdjustmentsFromPrefs(Database db) async {
    final prefs = await SharedPreferences.getInstance();
    const legacyKeys = {
      'Fajr': 'fajrAdjustment',
      'Dhuhr': 'dhuhrAdjustment',
      'Asr': 'asrAdjustment',
      'Maghrib': 'maghribAdjustment',
      'Isha': 'ishAdjustment',
    };

    for (final entry in legacyKeys.entries) {
      final minutes = prefs.getInt(entry.value);
      if (minutes == null) continue;
      await db.insert(tablePrayerAdjustment, {
        'prayer': entry.key,
        'minutes': minutes,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> exportDB() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/deenly.db';

    final file = File(path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final copyPath = '/storage/emulated/0/Download/deenly_$timestamp.db';
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

  Future<void> seedDoaIfNeeded() async {
    final alreadySeeded = await _isDoaSeeded();
    if (alreadySeeded) return;

    final db = await database;
    final doas = await _loadDoaJson();

    await db.transaction((txn) async {
      final batch = txn.batch();

      // The JSON has no group ids, so groups are numbered in the order they
      // first appear, which is also their display order.
      final Map<String, int> groupIds = {};
      for (final doa in doas) {
        final groupId = groupIds.putIfAbsent(doa['grup'], () {
          final id = groupIds.length + 1;
          batch.insert(tableDoaGroup, {
            'id': id,
            'name_indonesian': doa['grup'],
            'name_english': doa['grup_en'],
            'sort_order': id,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          return id;
        });

        batch.insert(tableDoa, {
          'id': doa['id'],
          'group_id': groupId,
          'name_indonesian': doa['nama'],
          'name_english': doa['nama_en'],
          'text_arabic': doa['ar'],
          'text_latin': doa['tr'],
          'text_indonesian': doa['idn'],
          'text_english': doa['en'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    });
  }

  Future<bool> _isDoaSeeded() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableDoa'),
    );
    return (result ?? 0) > 0;
  }

  Future<List<Map<String, dynamic>>> _loadDoaJson() async {
    final jsonString = await rootBundle.loadString('assets/jsons/doa.json');
    return compute(_parseDoaJson, jsonString);
  }

  static List<Map<String, dynamic>> _parseDoaJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> doas = data['data'];
    return doas.cast<Map<String, dynamic>>();
  }

  Future<void> seedAsmaulHusnaIfNeeded() async {
    final alreadySeeded = await _isAsmaulHusnaSeeded();
    if (alreadySeeded) return;

    final db = await database;
    final names = await _loadAsmaulHusnaJson();

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final name in names) {
        batch.insert(tableAsmaulHusna, {
          'id': name['urutan'],
          'text_arabic': name['arab'],
          'text_latin': name['latin'],
          'meaning_indonesian': name['indonesia'],
          'meaning_english': name['inggris'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  Future<bool> _isAsmaulHusnaSeeded() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableAsmaulHusna'),
    );
    return (result ?? 0) > 0;
  }

  Future<List<Map<String, dynamic>>> _loadAsmaulHusnaJson() async {
    final jsonString = await rootBundle.loadString(
      'assets/jsons/asmaulhusna.json',
    );
    return compute(_parseAsmaulHusnaJson, jsonString);
  }

  static List<Map<String, dynamic>> _parseAsmaulHusnaJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> names = data['data'];
    return names.cast<Map<String, dynamic>>();
  }

  Future<void> seedDzikirIfNeeded() async {
    final alreadySeeded = await _isDzikirSeeded();
    if (alreadySeeded) return;

    final db = await database;
    final dzikirs = await _loadDzikirJson();

    await db.transaction((txn) async {
      final batch = txn.batch();

      /// Like doa.json, categories are numbered in order of first
      /// appearance, which is also their display order.
      final Map<String, int> categoryIds = {};
      for (final dzikir in dzikirs) {
        final categoryId = categoryIds.putIfAbsent(dzikir['grup'], () {
          final id = categoryIds.length + 1;
          batch.insert(tableDzikirCategory, {
            'id': id,
            'name_indonesian': dzikir['grup'],
            'name_english': dzikir['grup_en'],
            'sort_order': id,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          return id;
        });

        batch.insert(tableDzikir, {
          'id': dzikir['id'],
          'category_id': categoryId,
          'name_indonesian': dzikir['nama'],
          'name_english': dzikir['nama_en'],
          'text_arabic': dzikir['ar'],
          'text_latin': dzikir['tr'],
          'text_indonesian': dzikir['idn'],
          'text_english': dzikir['en'],
          'count': dzikir['jumlah'],
          'note_indonesian': dzikir['catatan'],
          'note_english': dzikir['catatan_en'],
          'virtue_indonesian': dzikir['keutamaan'],
          'virtue_english': dzikir['keutamaan_en'],
          'source': dzikir['sumber'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    });
  }

  Future<bool> _isDzikirSeeded() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableDzikir'),
    );
    return (result ?? 0) > 0;
  }

  Future<List<Map<String, dynamic>>> _loadDzikirJson() async {
    final jsonString = await rootBundle.loadString('assets/jsons/dzikir.json');
    return compute(_parseDzikirJson, jsonString);
  }

  static List<Map<String, dynamic>> _parseDzikirJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> dzikirs = data['data'];
    return dzikirs.cast<Map<String, dynamic>>();
  }
}
