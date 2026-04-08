import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_card.dart';
import '../data/exercise_repository.dart';
import '../models/exercise_model.dart';
import 'exercise_log_screen.dart';

class ExerciseListScreen extends StatelessWidget {
  final String categoryName;
  final List<ExerciseCategory> categories;

  const ExerciseListScreen({
    super.key,
    required this.categoryName,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final List<Exercise> exercises = [];
    for (var cat in categories) {
      exercises.addAll(ExerciseRepository.getExercisesByCategory(cat));
    }

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
            title: Text(
              categoryName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            sliver: exercises.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Text("Coming Soon!", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final exercise = exercises[index];
                        return _buildExerciseCard(context, exercise);
                      },
                      childCount: exercises.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseLogScreen(
                exercise: exercise,
                durationSeconds: 0,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: exercise.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(exercise.icon, color: exercise.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${exercise.difficultyText.toUpperCase()} • ${exercise.muscleGroups.join(', ')}",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}
