import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../data/exercise_data.dart';
import 'exercise_list_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Workouts'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [SizedBox(height: 40)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercise Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(context),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Stats',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickStats(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      {
        'category': ExerciseCategory.chest,
        'name': 'Chest',
        'icon': Icons.favorite,
        'color': Colors.red,
        'count': ExerciseData.getExercisesByCategory(
          ExerciseCategory.chest,
        ).length,
      },
      {
        'category': ExerciseCategory.back,
        'name': 'Back',
        'icon': Icons.accessibility_new,
        'color': Colors.blue,
        'count': ExerciseData.getExercisesByCategory(
          ExerciseCategory.back,
        ).length,
      },
      {
        'category': ExerciseCategory.legs,
        'name': 'Legs',
        'icon': Icons.directions_walk,
        'color': Colors.green,
        'count': ExerciseData.getExercisesByCategory(
          ExerciseCategory.legs,
        ).length,
      },
      {
        'category': ExerciseCategory.shoulders,
        'name': 'Shoulders',
        'icon': Icons.airline_seat_recline_extra,
        'color': Colors.orange,
        'count': ExerciseData.getExercisesByCategory(
          ExerciseCategory.shoulders,
        ).length,
      },
      {
        'category': ExerciseCategory.arms,
        'name': 'Arms',
        'icon': Icons.fitness_center,
        'color': Colors.purple,
        'count': ExerciseData.getExercisesByCategory(
          ExerciseCategory.arms,
        ).length,
      },
      {
        'category': ExerciseCategory.core,
        'name': 'Core',
        'icon': Icons.album,
        'color': Colors.teal,
        'count': ExerciseData.getExercisesByCategory(
          ExerciseCategory.core,
        ).length,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseListScreen(
                    category: cat['category'] as ExerciseCategory,
                    categoryName: cat['name'] as String,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (cat['color'] as Color).withValues(alpha: 0.7),
                    (cat['color'] as Color),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${cat['count']} exercises',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    color: Colors.purple,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${ExerciseData.allExercises.length}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Exercises',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Icon(Icons.category, color: Colors.blue, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    '6',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
