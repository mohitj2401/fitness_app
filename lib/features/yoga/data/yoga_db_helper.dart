import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/yoga_session_model.dart';

class YogaDatabaseHelper {
  static final YogaDatabaseHelper instance = YogaDatabaseHelper._init();
  static Database? _database;

  YogaDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yoga_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE yoga_sessions (
  id $idType,
  title $textType,
  durationSeconds $integerType,
  timestamp $textType
)
''');
  }

  Future<void> createSession(YogaSessionModel session) async {
    final db = await database;
    await db.insert(
      'yoga_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<YogaSessionModel>> getAllSessions() async {
    final db = await database;
    final orderBy = 'timestamp DESC';
    final result = await db.query('yoga_sessions', orderBy: orderBy);

    return result.map((json) => YogaSessionModel.fromMap(json)).toList();
  }

  Future<int> getSessionCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM yoga_sessions'),
    );
    return count ?? 0;
  }

  Future<int> getTotalDuration() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(durationSeconds) as total FROM yoga_sessions',
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
