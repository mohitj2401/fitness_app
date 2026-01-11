import '../models/yoga_session_model.dart';

class YogaStatistics {
  final int totalSessions;
  final int totalMinutes;
  final Map<String, int> sessionsByType;
  final Map<String, int> dailyMinutes; // Date string -> minutes

  YogaStatistics({
    required this.totalSessions,
    required this.totalMinutes,
    required this.sessionsByType,
    required this.dailyMinutes,
  });

  static YogaStatistics fromSessions(List<YogaSessionModel> sessions) {
    int totalSessions = sessions.length;
    int totalMinutes = 0;
    Map<String, int> sessionsByType = {};
    Map<String, int> dailyMinutes = {};

    for (var session in sessions) {
      // Total minutes
      totalMinutes += (session.durationSeconds / 60).round();

      // Sessions by type
      sessionsByType[session.title] = (sessionsByType[session.title] ?? 0) + 1;

      // Daily minutes
      String dateKey = _formatDate(session.timestamp);
      int minutes = (session.durationSeconds / 60).round();
      dailyMinutes[dateKey] = (dailyMinutes[dateKey] ?? 0) + minutes;
    }

    return YogaStatistics(
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      sessionsByType: sessionsByType,
      dailyMinutes: dailyMinutes,
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int getMinutesForDate(DateTime date) {
    return dailyMinutes[_formatDate(date)] ?? 0;
  }

  List<MapEntry<String, int>> getDailyMinutesSorted() {
    var entries = dailyMinutes.entries.toList();
    entries.sort((a, b) => b.key.compareTo(a.key)); // Most recent first
    return entries;
  }
}
