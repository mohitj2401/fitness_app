import 'package:flutter/material.dart';
import '../models/yoga_session_model.dart';
import '../data/yoga_db_helper.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../achievements/logic/achievement_service.dart';
import '../../achievements/presentation/achievement_unlock_dialog.dart';
import '../../achievements/models/achievement_model.dart';
import 'package:uuid/uuid.dart';

class YogaLogScreen extends StatefulWidget {
  final String title;
  const YogaLogScreen({super.key, required this.title});

  @override
  State<YogaLogScreen> createState() => _YogaLogScreenState();
}

class _YogaLogScreenState extends State<YogaLogScreen> {
  int _seconds = 0;
  bool _isTimerRunning = false;
  late final Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _isTimerRunning = true);
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
    _timerStream.listen((_) {
      if (_isTimerRunning && mounted) {
        setState(() => _seconds++);
      }
    });
  }

  Future<void> _saveSession() async {
    setState(() => _isTimerRunning = false);
    
    final session = YogaSessionModel(
      id: const Uuid().v4(),
      title: widget.title,
      durationSeconds: _seconds,
      timestamp: DateTime.now(),
    );

    await YogaDatabaseHelper.instance.createSession(session);
    
    List<AchievementModel> newlyUnlocked = [];
    try {
      newlyUnlocked = await AchievementService().checkAndUnlockAchievements();
    } catch (e) {
      debugPrint("Error checking achievements: $e");
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yoga session saved!")),
      );
      DashboardScreen.triggerRefresh();
      
      if (newlyUnlocked.isNotEmpty) {
        for (var achievement in newlyUnlocked) {
          AchievementUnlockDialog.show(context, achievement);
        }
      }

      Navigator.pop(context);
    }
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.self_improvement, size: 80, color: Colors.purpleAccent),
            const SizedBox(height: 24),
            Text(
              _formatTime(_seconds),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text("Duration", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _isTimerRunning = !_isTimerRunning),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(_isTimerRunning ? "Pause" : "Resume"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text("Finish Session"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
