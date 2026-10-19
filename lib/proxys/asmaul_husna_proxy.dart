import 'package:deenly/components/database_helper.dart';
import 'package:deenly/models/asmaul_husna_model.dart';

class AsmaulHusnaProxy {
  Future<List<AsmaulHusnaModel>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(DatabaseHelper.tableAsmaulHusna, orderBy: 'id');
    return maps.map(AsmaulHusnaModel.fromDatabase).toList();
  }
}
