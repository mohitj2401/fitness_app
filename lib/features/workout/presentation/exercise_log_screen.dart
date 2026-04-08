import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/services/gamification_service.dart';
import '../models/exercise_model.dart';
import '../models/workout_log_model.dart';
import '../data/workout_db_helper.dart';
import 'exercise_report_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../achievements/logic/achievement_service.dart';
import '../../achievements/models/achievement_model.dart';
import '../../achievements/presentation/achievement_unlock_dialog.dart';

class ExerciseLogScreen extends StatefulWidget {
  final Exercise exercise;
  final int durationSeconds;

  const ExerciseLogScreen({
    super.key,
    required this.exercise,
    required this.durationSeconds,
  });

  @override
  State<ExerciseLogScreen> createState() => _ExerciseLogScreenState();
}

class _ExerciseLogScreenState extends State<ExerciseLogScreen> {
  final List<WorkoutSet> _sets = [];
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = widget.durationSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _addSet() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight != null && reps != null) {
      setState(() {
        _sets.add(
          WorkoutSet(
            sessionId: '', // Temporary, will be assigned when saving session
            exerciseId: widget.exercise.id,
            exerciseName: widget.exercise.name,
            weight: weight,
            reps: reps,
          ),
        );
      });
      // Keep weight, arguably useful. Clear reps?
      // _repsController.clear();
    }
  }

  void _removeSet(int index) {
    setState(() {
      _sets.removeAt(index);
    });
  }

  Future<void> _saveAndFinish() async {
    if (_sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log at least one set.")),
      );
      return;
    }

    try {
      // 1. Create a WorkoutSession for this single exercise
      final session = WorkoutSession(
        startTime: DateTime.now().subtract(
          Duration(seconds: _elapsedSeconds),
        ),
        endTime: DateTime.now(),
        durationSeconds: _elapsedSeconds,
        name: widget.exercise.name, // Naming the session after the exercise
        sets:
            [], // We'll add sets individually or as part of create, but DB helper handles list
      );

      // 2. Assign the new session ID to all sets
      final setsWithId = _sets
          .map(
            (s) => WorkoutSet(
              id: s.id,
              sessionId: session.id, // Assign generated session ID
              exerciseId: s.exerciseId,
              exerciseName: s.exerciseName,
              weight: s.weight,
              reps: s.reps,
              timestamp: s.timestamp,
            ),
          )
          .toList();

      final sessionToSave = session.copyWith(sets: setsWithId);

      // 3. Save to DB
      await WorkoutDatabaseHelper.instance.createWorkoutSession(sessionToSave);

      // 4. Add XP
      bool leveledUp = await GamificationService.instance.addGymXP(_sets.length);
      
      if (leveledUp && mounted) {
        _showLevelUpCelebration();
      }

      List<AchievementModel> netUnlocked = [];
      // 5. Check for achievements
      try {
        netUnlocked = await AchievementService().checkAndUnlockAchievements();
      } catch (e) {
        debugPrint("Error checking achievements: $e");
      }

      if (mounted) {
        // Navigate to report screen first
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseReportScreen(session: sessionToSave),
          ),
        );

        // Refresh dashboard stats
        DashboardScreen.triggerRefresh();

        // Show celebrations on the root navigator (handled inside show)
        if (netUnlocked.isNotEmpty) {
          for (var achievement in netUnlocked) {
            AchievementUnlockDialog.show(context, achievement);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  void _showLevelUpCelebration() async {
    final xp = await GamificationService.instance.getTotalXP();
    final level = GamificationService.instance.getLevelForXP(xp);
    final title = GamificationService.instance.getLevelTitle(level);
    final tierColor = GamificationService.instance.getTierColor(level);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, color: tierColor, size: 80),
                const SizedBox(height: 16),
                Text(
                  "LEVEL UP!",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: tierColor,
                        letterSpacing: 2,
                      ),
                ),
                Text(
                  "NEW RANK: ${title.toUpperCase()}",
                  style: TextStyle(
                    color: tierColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "You've reached a new level of fitness. Keep pushing your limits!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.accentPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("CONTINUE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Premium Timer Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              borderRadius: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_rounded, color: AppThemes.accentPurple, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "ELAPSED: ${_formatDuration(_elapsedSeconds)}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const Text(
                  "SETS COMPLETED",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (_sets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        "No sets added yet.",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ..._sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppThemes.accentPurple.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  color: AppThemes.accentPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "${set.weight} kg  ×  ${set.reps} reps",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: Colors.white.withValues(alpha: 0.3), size: 20),
                            onPressed: () => _removeSet(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),
                const Text(
                  "ADD NEW SET",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(_weightController, "Weight", "kg"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(_repsController, "Reps", ""),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppThemes.accentPurple, AppThemes.accentMagenta],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppThemes.accentPurple.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _addSet,
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveAndFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.withValues(alpha: 0.8),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "FINISH WORKOUT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, String suffix) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppThemes.accentPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
