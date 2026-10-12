import 'package:sqflite/sqflite.dart';
import '../../domain/models/classification_result.dart';
import 'db_helper.dart';

/// Data Access Object for the classifications table.
class ClassificationDao {
  final DbHelper _dbHelper = DbHelper.instance;

  /// Insert a new classification and return the generated id.
  Future<int> insert(ClassificationResult result) async {
    final db = await _dbHelper.database;
    return db.insert(
      DbHelper.tableClassifications,
      result.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all classifications, newest first.
  Future<List<ClassificationResult>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DbHelper.tableClassifications,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => ClassificationResult.fromMap(m)).toList();
  }

  /// Get a single classification by id.
  Future<ClassificationResult?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DbHelper.tableClassifications,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ClassificationResult.fromMap(maps.first);
  }

  /// Delete a classification by id. Returns number of rows deleted.
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      DbHelper.tableClassifications,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all classifications. Returns number of rows deleted.
  Future<int> deleteAll() async {
    final db = await _dbHelper.database;
    return db.delete(DbHelper.tableClassifications);
  }

  /// Get count of classifications.
  Future<int> count() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM ${DbHelper.tableClassifications}');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
