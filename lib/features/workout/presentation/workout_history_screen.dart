import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout_log_model.dart';
import '../data/workout_db_helper.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  late Future<List<WorkoutSession>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = WorkoutDatabaseHelper.instance.getAllWorkoutSessions();
    });
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    }
    final minutes = seconds ~/ 60;
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            title: const Text(
              "History",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<WorkoutSession>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                final sessions = snapshot.data ?? [];
                if (sessions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(64.0),
                      child: Text("No workouts logged yet.", style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                final grouped = _groupSessions(sessions);

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, i) {
                    final groupName = grouped.keys.elementAt(i);
                    final groupSessions = grouped[groupName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            groupName.toUpperCase(),
                            style: TextStyle(
                              color: AppThemes.accentPurple.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        ...groupSessions.map((session) => _buildHistoryCard(session)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<WorkoutSession>> _groupSessions(List<WorkoutSession> sessions) {
    final Map<String, List<WorkoutSession>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var session in sessions) {
      final sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      String group;
      if (sessionDate == today) {
        group = "Today";
      } else if (sessionDate == yesterday) {
        group = "Yesterday";
      } else {
        group = DateFormat('MMMM d').format(sessionDate);
      }

      if (grouped[group] == null) grouped[group] = [];
      grouped[group]!.add(session);
    }
    return grouped;
  }

  Widget _buildHistoryCard(WorkoutSession session) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemes.accentPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded, color: AppThemes.accentPurple, size: 20),
            ),
            title: Text(
              DateFormat.jm().format(session.startTime),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              "${_formatDuration(session.durationSeconds)} • ${session.sets.length} items",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 12),
                    ..._buildSessionDetails(session),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSessionDetails(WorkoutSession session) {
    // Group sets by exercise name for cleaner display in history
    final Map<String, List<WorkoutSet>> setsByExercise = {};
    for (var set in session.sets) {
      if (setsByExercise[set.exerciseName] == null) {
        setsByExercise[set.exerciseName] = [];
      }
      setsByExercise[set.exerciseName]!.add(set);
    }

    return setsByExercise.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppThemes.accentPurple,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value
                  .map(
                    (set) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Text(
                        "${set.weight}kg x ${set.reps}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    }).toList();
  }
}
