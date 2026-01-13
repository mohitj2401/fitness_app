import '../data/achievement_db_helper.dart';
import '../../workout/data/workout_db_helper.dart';
import '../../yoga/data/yoga_db_helper.dart';
import '../models/achievement_model.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  /// Checks for new achievements and returns a list of those newly unlocked.
  Future<List<AchievementModel>> checkAndUnlockAchievements() async {
    final dbHelper = AchievementDatabaseHelper.instance;
    final allAchievements = await dbHelper.getAllAchievements();
    final newlyUnlocked = <AchievementModel>[];

    // Get statistics
    final gymCount = await WorkoutDatabaseHelper.instance.getWorkoutCount();
    final yogaCount = await YogaDatabaseHelper.instance.getSessionCount();
    final yogaMinutes =
        (await YogaDatabaseHelper.instance.getTotalDuration()) ~/ 60;
    final totalSessions = gymCount + yogaCount;

    for (var achievement in allAchievements) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_workout':
          if (gymCount >= 1) shouldUnlock = true;
          break;
        case 'zen_master':
          if (yogaCount >= 1) shouldUnlock = true;
          break;
        case 'triple_threat':
          if (totalSessions >= 3) shouldUnlock = true;
          break;
        case 'mindful_100':
          if (yogaMinutes >= 100) shouldUnlock = true;
          break;
        case 'gym_10':
          if (gymCount >= 10) shouldUnlock = true;
          break;
        case 'century_club':
          if (totalSessions >= 100) shouldUnlock = true;
          break;
        case 'calorie_crusher':
          final totalCalories =
              (yogaMinutes + gymCount * 30) * 5; // Rough estimate
          if (totalCalories >= 1000) shouldUnlock = true;
          break;
        case 'yoga_pro':
          if (yogaCount >= 10) shouldUnlock = true;
          break;
        case 'marathon':
          final gymSessions = await WorkoutDatabaseHelper.instance
              .getAllWorkoutSessions();
          final yogaSessions = await YogaDatabaseHelper.instance
              .getAllSessions();
          final hasMarathon =
              gymSessions.any((s) => s.durationSeconds >= 2700) ||
              yogaSessions.any((s) => s.durationSeconds >= 2700);
          if (hasMarathon) shouldUnlock = true;
          break;
        case 'early_bird':
          final gymSessionsEB = await WorkoutDatabaseHelper.instance
              .getAllWorkoutSessions();
          final yogaSessionsEB = await YogaDatabaseHelper.instance
              .getAllSessions();
          final hasEarlyBird =
              gymSessionsEB.any((s) => s.startTime.hour < 8) ||
              yogaSessionsEB.any((s) => s.timestamp.hour < 8);
          if (hasEarlyBird) shouldUnlock = true;
          break;
        case 'night_owl':
          final gymSessionsNO = await WorkoutDatabaseHelper.instance
              .getAllWorkoutSessions();
          final yogaSessionsNO = await YogaDatabaseHelper.instance
              .getAllSessions();
          final hasNightOwl =
              gymSessionsNO.any((s) => s.startTime.hour >= 21) ||
              yogaSessionsNO.any((s) => s.timestamp.hour >= 21);
          if (hasNightOwl) shouldUnlock = true;
          break;
      }

      if (shouldUnlock) {
        await dbHelper.unlockAchievement(achievement.id);
        newlyUnlocked.add(
          achievement.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
        );
      }
    }

    return newlyUnlocked;
  }
}
