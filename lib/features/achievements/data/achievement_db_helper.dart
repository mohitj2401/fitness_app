import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/achievement_model.dart';

class AchievementDatabaseHelper {
  static final AchievementDatabaseHelper instance =
      AchievementDatabaseHelper._init();
  static Database? _database;

  AchievementDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('achievements.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        iconName TEXT NOT NULL,
        category TEXT NOT NULL,
        isUnlocked INTEGER NOT NULL,
        unlockedAt TEXT
      )
    ''');

    // Seed initial achievements
    await _seedAchievements(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _seedAchievements(db);
    }
  }

  Future<void> _seedAchievements(Database db) async {
    final initialAchievements = [
      AchievementModel(
        id: 'first_workout',
        title: 'First Step',
        description: 'Complete your first gym workout',
        iconName: 'fitness_center',
        category: 'gym',
      ),
      AchievementModel(
        id: 'zen_master',
        title: 'Zen Master',
        description: 'Complete your first yoga session',
        iconName: 'self_improvement',
        category: 'yoga',
      ),
      AchievementModel(
        id: 'triple_threat',
        title: 'Consistent',
        description: 'Complete 3 sessions in total',
        iconName: 'bolt',
        category: 'consistency',
      ),
      AchievementModel(
        id: 'mindful_100',
        title: 'Mindfulness',
        description: 'Reach 100 total yoga minutes',
        iconName: 'timer',
        category: 'yoga',
      ),
      AchievementModel(
        id: 'gym_10',
        title: 'Power Lifter',
        description: 'Complete 10 gym workouts',
        iconName: 'military_tech',
        category: 'gym',
      ),
      AchievementModel(
        id: 'century_club',
        title: 'Century Club',
        description: 'Reach 100 total sessions',
        iconName: 'military_tech',
        category: 'total',
      ),
      AchievementModel(
        id: 'calorie_crusher',
        title: 'Calorie Crusher',
        description: 'Burn 1000 total calories',
        iconName: 'local_fire_department',
        category: 'total',
      ),
      AchievementModel(
        id: 'yoga_pro',
        title: 'Yoga Pro',
        description: 'Complete 10 yoga sessions',
        iconName: 'self_improvement',
        category: 'yoga',
      ),
      AchievementModel(
        id: 'marathon',
        title: 'Marathon',
        description: 'Complete a 45+ min session',
        iconName: 'timer',
        category: 'intensity',
      ),
      AchievementModel(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Workout before 8:00 AM',
        iconName: 'wb_sunny',
        category: 'timing',
      ),
      AchievementModel(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Workout after 9:00 PM',
        iconName: 'bedtime',
        category: 'timing',
      ),
    ];

    for (var achievement in initialAchievements) {
      await db.insert(
        'achievements',
        achievement.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<AchievementModel>> getAllAchievements() async {
    final db = await database;
    final result = await db.query('achievements');
    return result.map((json) => AchievementModel.fromMap(json)).toList();
  }

  Future<void> unlockAchievement(String id) async {
    final db = await database;
    await db.update(
      'achievements',
      {'isUnlocked': 1, 'unlockedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getUnlockedCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM achievements WHERE isUnlocked = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<AchievementModel?> getAchievementById(String id) async {
    final db = await database;
    final result = await db.query(
      'achievements',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return AchievementModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> resetAchievements() async {
    final db = await database;
    await db.update('achievements', {'isUnlocked': 0, 'unlockedAt': null});
  }
}
