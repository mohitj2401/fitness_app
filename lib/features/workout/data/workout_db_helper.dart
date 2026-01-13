import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout_log_model.dart';
import 'dart:convert';

class WorkoutDatabaseHelper {
  static final WorkoutDatabaseHelper instance = WorkoutDatabaseHelper._init();
  static Database? _database;

  WorkoutDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workout_tracker.db');
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
    const boolType = 'INTEGER NOT NULL';

    // Workout Sessions Table
    await db.execute('''
CREATE TABLE workout_sessions (
  id $idType,
  startTime $textType,
  endTime $textType,
  durationSeconds $integerType,
  name $textType,
  note $textType
)
''');

    // Workout Sets Table
    // Stores individual sets for an exercise within a session
    await db.execute('''
CREATE TABLE workout_sets (
  id $idType,
  sessionId $textType,
  exerciseId $textType,
  exerciseName $textType,
  weight $textType,
  reps $integerType,
  isCompleted $boolType,
  timestamp $textType
)
''');
  }

  // --- Workout Session Operations ---

  Future<void> createWorkoutSession(WorkoutSession session) async {
    final db = await database;
    await db.insert('workout_sessions', session.toMap());

    // Also insert all sets
    for (final set in session.sets) {
      await db.insert('workout_sets', set.toMap());
    }
  }

  Future<WorkoutSession?> getWorkoutSession(String id) async {
    final db = await database;
    final maps = await db.query(
      'workout_sessions',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final sessionMap = maps.first;
      final sets = await getSetsForSession(id);
      return WorkoutSession.fromMap(sessionMap, sets);
    } else {
      return null;
    }
  }

  Future<List<WorkoutSession>> getAllWorkoutSessions() async {
    final db = await database;
    final orderBy = 'startTime DESC';
    final result = await db.query('workout_sessions', orderBy: orderBy);

    List<WorkoutSession> sessions = [];
    for (var map in result) {
      final sets = await getSetsForSession(map['id'] as String);
      sessions.add(WorkoutSession.fromMap(map, sets));
    }
    return sessions;
  }

  // --- Set Operations ---

  Future<List<WorkoutSet>> getSetsForSession(String sessionId) async {
    final db = await database;
    final result = await db.query(
      'workout_sets',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return result.map((json) => WorkoutSet.fromMap(json)).toList();
  }

  Future<void> saveSet(WorkoutSet set) async {
    final db = await database;
    await db.insert(
      'workout_sets',
      set.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSession(String id) async {
    final db = await database;
    await db.delete('workout_sessions', where: 'id = ?', whereArgs: [id]);
    await db.delete('workout_sets', where: 'sessionId = ?', whereArgs: [id]);
  }

  // --- Dashboard Stats Helpers ---

  Future<int> getWorkoutCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_sessions',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalDuration() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(durationSeconds) as total FROM workout_sessions',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<WorkoutSession?> getLastWorkout() async {
    final db = await database;
    final result = await db.query(
      'workout_sessions',
      orderBy: 'startTime DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      final sessionMap = result.first;
      final sets = await getSetsForSession(sessionMap['id'] as String);
      return WorkoutSession.fromMap(sessionMap, sets);
    }
    return null;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('workout_sessions');
    await db.delete('workout_sets');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
