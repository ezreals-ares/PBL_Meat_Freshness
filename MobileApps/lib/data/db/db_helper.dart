import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton SQLite database helper.
class DbHelper {
  static const String _dbName = 'meatfresh.db';
  static const int _dbVersion = 3;
  static const String tableClassifications = 'classifications';
  static const String _idxCreatedAt = 'idx_classifications_created_at';

  DbHelper._();
  static final DbHelper instance = DbHelper._();

  Database? _db;
  Future<Database>? _dbFuture;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null && existing.isOpen) return existing;
    if (existing != null) {
      _db = null;
      _dbFuture = null;
    }
    final pending = _dbFuture ??= _initDb();
    try {
      _db = await pending;
      return _db!;
    } catch (_) {
      _dbFuture = null;
      rethrow;
    }
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableClassifications (
        id                    INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path            TEXT NOT NULL,
        meat_type             TEXT,
        result                TEXT NOT NULL,
        confidence            REAL NOT NULL,
        created_at            TEXT NOT NULL,
        model_used            TEXT,
        probabilities_json    TEXT,
        segmentation_fallback INTEGER
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS $_idxCreatedAt
      ON $tableClassifications(created_at DESC)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE $tableClassifications ADD COLUMN model_used TEXT');
      await db.execute(
          'ALTER TABLE $tableClassifications ADD COLUMN probabilities_json TEXT');
      await db.execute(
          'ALTER TABLE $tableClassifications ADD COLUMN segmentation_fallback INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE INDEX IF NOT EXISTS $_idxCreatedAt
        ON $tableClassifications(created_at DESC)
      ''');
    }
  }

  /// Close the database. Call on app dispose if needed.
  Future<void> close() async {
    final db = _db;
    _db = null;
    _dbFuture = null;
    if (db != null) {
      await db.close();
    }
  }
}
