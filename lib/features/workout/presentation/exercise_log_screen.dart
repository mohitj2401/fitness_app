import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../models/workout_log_model.dart';
import '../data/workout_db_helper.dart';
import 'exercise_report_screen.dart';

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
          Duration(seconds: widget.durationSeconds),
        ),
        endTime: DateTime.now(),
        durationSeconds: widget.durationSeconds,
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

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExerciseReportScreen(session: sessionToSave),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Log ${widget.exercise.name}")),
      body: Column(
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Time: ${_formatDuration(widget.durationSeconds)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Sets Completed",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_sets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "No sets added yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ..._sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text("${index + 1}")),
                      title: Text("${set.weight} kg x ${set.reps} reps"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeSet(index),
                      ),
                    ),
                  );
                }),

                const Divider(height: 32),

                // Input area
                const Text(
                  "Add Set",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: "Weight (kg)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Reps",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addSet,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveAndFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Finish & Save",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
