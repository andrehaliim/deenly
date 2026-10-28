import 'package:deenly/components/database_helper.dart';
import 'package:deenly/models/dzikir_category_model.dart';
import 'package:deenly/models/dzikir_model.dart';

class DzikirProxy {
  Future<List<DzikirCategoryModel>> getCategories() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT c.id, c.name_indonesian, c.name_english,
        COUNT(d.id) AS dzikir_total
      FROM ${DatabaseHelper.tableDzikirCategory} c
      LEFT JOIN ${DatabaseHelper.tableDzikir} d ON d.category_id = c.id
      GROUP BY c.id
      ORDER BY c.sort_order
    ''');
    return maps.map(DzikirCategoryModel.fromDatabase).toList();
  }

  Future<List<DzikirModel>> getDzikirsByCategory(int categoryId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      DatabaseHelper.tableDzikir,
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'id',
    );
    return maps.map(DzikirModel.fromDatabase).toList();
  }
}
