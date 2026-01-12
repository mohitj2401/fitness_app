import 'package:flutter/material.dart';
import '../models/workout_log_model.dart';

class ExerciseReportScreen extends StatelessWidget {
  final WorkoutSession session;

  const ExerciseReportScreen({super.key, required this.session});

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  double get _totalVolume {
    return session.sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Report"),
        automaticallyImplyLeading: false, // Prevent going back to log screen
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Great Job!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              session.name,
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.timer,
                  label: "Duration",
                  value: _formatDuration(session.durationSeconds),
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.fitness_center,
                  label: "Total Volume",
                  value: "${_totalVolume.toStringAsFixed(1)} kg",
                  color: Colors.purple,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.repeat,
                  label: "Total Sets",
                  value: "${session.sets.length}",
                  color: Colors.orange,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.star,
                  label: "Avg Reps",
                  value: session.sets.isNotEmpty
                      ? (session.sets.fold(0, (s, set) => s + set.reps) /
                                session.sets.length)
                            .toStringAsFixed(1)
                      : "0",
                  color: Colors.amber,
                ),
              ],
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Go back to dashboard (pop until first)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("Back to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
