import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/measurement_model.dart';

class MeasurementDatabaseHelper {
  static final MeasurementDatabaseHelper instance = MeasurementDatabaseHelper._init();
  static Database? _database;

  MeasurementDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('measurements.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        body_fat REAL NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
    
    // Seed initial data if empty
    await db.insert('measurements', {
      'weight': 70.0,
      'body_fat': 20.0,
      'timestamp': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    });
  }

  Future<int> addMeasurement(BodyMeasurement measurement) async {
    final db = await instance.database;
    return await db.insert('measurements', measurement.toMap());
  }

  Future<List<BodyMeasurement>> getMeasurements() async {
    final db = await instance.database;
    final result = await db.query('measurements', orderBy: 'timestamp DESC');
    return result.map((json) => BodyMeasurement.fromMap(json)).toList();
  }

  Future<BodyMeasurement?> getLatestMeasurement() async {
    final db = await instance.database;
    final result = await db.query('measurements', orderBy: 'timestamp DESC', limit: 1);
    if (result.isNotEmpty) {
      return BodyMeasurement.fromMap(result.first);
    }
    return null;
  }
}
