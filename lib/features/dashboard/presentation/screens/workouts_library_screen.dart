import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../workout/presentation/exercise_list_screen.dart';
import '../../../workout/models/exercise_model.dart';
import '../../../workout/presentation/exercise_timer_screen.dart';
import '../../../workout/data/exercise_repository.dart';

class WorkoutsLibraryScreen extends StatelessWidget {
  const WorkoutsLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chestCount = ExerciseRepository.getExercisesByCategory(ExerciseCategory.chest).length;
    final shoulderCount = ExerciseRepository.getExercisesByCategory(ExerciseCategory.shoulders).length;
    final legsCount = ExerciseRepository.getExercisesByCategory(ExerciseCategory.legs).length;
    final armsCount = ExerciseRepository.getExercisesByCategory(ExerciseCategory.arms).length;
    final coreCount = ExerciseRepository.getExercisesByCategory(ExerciseCategory.core).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Text(
              "Library",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EXPLORE CATEGORIES",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildCategoryCard(
                    context,
                    title: "Chest & Shoulders",
                    count: "${chestCount + shoulderCount} Exercises",
                    image: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=400",
                    color: Colors.blueAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExerciseListScreen(
                          categoryName: "Chest & Shoulders",
                          categories: [ExerciseCategory.chest, ExerciseCategory.shoulders],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    context,
                    title: "Legs",
                    count: "$legsCount Exercises",
                    image: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&q=80&w=400",
                    color: Colors.orangeAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExerciseListScreen(
                          categoryName: "Legs",
                          categories: [ExerciseCategory.legs],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    context,
                    title: "Arms & Core",
                    count: "${armsCount + coreCount} Exercises",
                    image: "https://images.unsplash.com/photo-1538356111083-d2d417721598?auto=format&fit=crop&q=80&w=400",
                    color: Colors.tealAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExerciseListScreen(
                          categoryName: "Arms & Core",
                          categories: [ExerciseCategory.arms, ExerciseCategory.core],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    "QUICK START",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildQuickStartButton(
                    context,
                    label: "Begin Free Workout",
                    icon: Icons.play_arrow_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String count,
    required String image,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Stack(
        children: [
          // Background Color/Image Placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          count,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartButton(BuildContext context, {required String label, required IconData icon}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final freeExercise = Exercise(
            id: "free_workout",
            name: "Free Workout",
            category: ExerciseCategory.core,
            difficulty: DifficultyLevel.beginner,
            muscleGroups: ["General"],
            description: "General training session",
            instructions: ["Start your workout", "Stop when finished"],
            icon: Icons.fitness_center_rounded,
            color: Colors.deepPurpleAccent,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExerciseTimerScreen(exercise: freeExercise),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: AppThemes.accentPurple.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppThemes.accentPurple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
