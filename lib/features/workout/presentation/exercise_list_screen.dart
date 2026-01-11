import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../data/exercise_data.dart';
import 'exercise_detail_screen.dart';

class ExerciseListScreen extends StatefulWidget {
  final ExerciseCategory category;
  final String categoryName;

  const ExerciseListScreen({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  DifficultyLevel? _selectedDifficulty;
  String _searchQuery = '';

  List<Exercise> get _filteredExercises {
    var exercises = ExerciseData.getExercisesByCategory(widget.category);

    if (_selectedDifficulty != null) {
      exercises = exercises
          .where((e) => e.difficulty == _selectedDifficulty)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      exercises = exercises
          .where(
            (e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Exercises'),
        actions: [
          PopupMenuButton<DifficultyLevel?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedDifficulty = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Levels')),
              const PopupMenuItem(
                value: DifficultyLevel.beginner,
                child: Text('Beginner'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.intermediate,
                child: Text('Intermediate'),
              ),
              const PopupMenuItem(
                value: DifficultyLevel.advanced,
                child: Text('Advanced'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Filter Chips
          if (_selectedDifficulty != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Chip(
                    label: Text(_selectedDifficulty!.name),
                    onDeleted: () {
                      setState(() {
                        _selectedDifficulty = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          // Exercise List
          Expanded(
            child: _filteredExercises.isEmpty
                ? const Center(child: Text('No exercises found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: exercise.color.withValues(
                              alpha: 0.2,
                            ),
                            child: Icon(
                              exercise.icon,
                              color: exercise.color,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                exercise.muscleGroups.join(', '),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getDifficultyColor(
                                        exercise.difficulty,
                                      ).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      exercise.difficultyText,
                                      style: TextStyle(
                                        color: _getDifficultyColor(
                                          exercise.difficulty,
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExerciseDetailScreen(exercise: exercise),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
    }
  }
}
