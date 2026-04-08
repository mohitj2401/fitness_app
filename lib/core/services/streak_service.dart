import '../../features/workout/data/workout_db_helper.dart';
import '../../features/yoga/data/yoga_db_helper.dart';

class StreakService {
  static final StreakService instance = StreakService._internal();
  StreakService._internal();

  /// Calculates the current workout streak in days.
  Future<int> calculateCurrentStreak() async {
    final gymSessions = await WorkoutDatabaseHelper.instance.getAllWorkoutSessions();
    final yogaSessions = await YogaDatabaseHelper.instance.getAllSessions();

    final allDates = <DateTime>{};

    for (var s in gymSessions) {
      allDates.add(DateTime(s.startTime.year, s.startTime.month, s.startTime.day));
    }
    for (var s in yogaSessions) {
      allDates.add(DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day));
    }

    if (allDates.isEmpty) return 0;
    
    int streak = 0;
    DateTime checkDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // If today is not done, check if yesterday was done to continue the streak
    if (!allDates.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (allDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Returns a list of booleans representing completion for the last 7 days (Mon-Sun or similar)
  /// for the streak visualization.
  Future<List<bool>> getLastSevenDaysActivity() async {
    final gymSessions = await WorkoutDatabaseHelper.instance.getAllWorkoutSessions();
    final yogaSessions = await YogaDatabaseHelper.instance.getAllSessions();

    final allDates = <DateTime>{};
    for (var s in gymSessions) {
      allDates.add(DateTime(s.startTime.year, s.startTime.month, s.startTime.day));
    }
    for (var s in yogaSessions) {
      allDates.add(DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day));
    }

    final List<bool> activity = [];
    final today = DateTime.now();
    
    // Calculate Mon-Sun for current week
    final int currentWeekday = today.weekday; // 1 = Mon, 7 = Sun
    final DateTime monday = today.subtract(Duration(days: currentWeekday - 1));

    for (int i = 0; i < 7; i++) {
      final dateToCheck = DateTime(monday.year, monday.month, monday.day).add(Duration(days: i));
      activity.add(allDates.contains(dateToCheck));
    }

    return activity;
  }
}
