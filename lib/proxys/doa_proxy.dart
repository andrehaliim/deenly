import 'package:deenly/components/database_helper.dart';
import 'package:deenly/models/doa_model.dart';

class DoaProxy {
  Future<List<DoaGroupModel>> getGroups() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.rawQuery('''
      SELECT g.id, g.name_indonesian, g.name_english, COUNT(d.id) AS doa_total
      FROM ${DatabaseHelper.tableDoaGroup} g
      LEFT JOIN ${DatabaseHelper.tableDoa} d ON d.group_id = g.id
      GROUP BY g.id
      ORDER BY g.sort_order
    ''');
    return maps.map(DoaGroupModel.fromDatabase).toList();
  }

  Future<List<DoaModel>> getDoasByGroup(int groupId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      DatabaseHelper.tableDoa,
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'id',
    );
    return maps.map(DoaModel.fromDatabase).toList();
  }
}
