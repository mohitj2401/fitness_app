import 'package:shared_preferences/shared_preferences.dart';
import '../models/yoga_session_model.dart';

class YogaStorageService {
  static const String _storageKey = 'yoga_sessions_history';

  Future<void> saveSession(YogaSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_storageKey) ?? [];

    // Add new session to top of list
    history.insert(0, session.toJson());

    await prefs.setStringList(_storageKey, history);
  }

  Future<List<YogaSessionModel>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_storageKey) ?? [];

    return history.map((e) => YogaSessionModel.fromJson(e)).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
