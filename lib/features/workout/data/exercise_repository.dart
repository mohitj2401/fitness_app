import 'package:flutter/material.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  static final List<Exercise> exercises = [
    // Chest
    Exercise(
      id: 'bench_press',
      name: 'Bench Press',
      category: ExerciseCategory.chest,
      difficulty: DifficultyLevel.intermediate,
      muscleGroups: ['Chest', 'Triceps', 'Shoulders'],
      description: 'The bench press is an upper-body weight training exercise in which the trainee presses a weight upwards while lying on a weight training bench.',
      instructions: [
        'Lie on your back on a flat bench.',
        'Grip the bar with hands just wider than shoulder-width apart.',
        'Lower the bar slowly to your chest.',
        'Push the bar back up to the starting position.'
      ],
      icon: Icons.fitness_center,
      color: Colors.blue,
    ),
    Exercise(
      id: 'pushups',
      name: 'Pushups',
      category: ExerciseCategory.chest,
      difficulty: DifficultyLevel.beginner,
      muscleGroups: ['Chest', 'Arms', 'Shoulders'],
      description: 'A conditioning exercise performed in a prone position by raising and lowering the body with the arms.',
      instructions: [
        'Start in a plank position.',
        'Lower your body until your chest nearly touches the floor.',
        'Push yourself back up.'
      ],
      icon: Icons.unfold_more,
      color: Colors.blueAccent,
    ),
    
    // Back
    Exercise(
      id: 'pullups',
      name: 'Pullups',
      category: ExerciseCategory.back,
      difficulty: DifficultyLevel.advanced,
      muscleGroups: ['Back', 'Biceps'],
      description: 'An upper-body strength exercise where you pull your body up until your chin is above the bar.',
      instructions: [
        'Grab the pull-up bar with palms facing away.',
        'Pull yourself up until your chin clears the bar.',
        'Lower yourself back down with control.'
      ],
      icon: Icons.vertical_align_top,
      color: Colors.green,
    ),
    
    // Legs
    Exercise(
      id: 'squats',
      name: 'Squats',
      category: ExerciseCategory.legs,
      difficulty: DifficultyLevel.beginner,
      muscleGroups: ['Quads', 'Glutes', 'Hamstrings'],
      description: 'A compound, full-body exercise that trains primarily the muscles of the thighs, hips, and buttocks.',
      instructions: [
        'Stand with feet shoulder-width apart.',
        'Lower your hips as if sitting in a chair.',
        'Keep your back straight and chest up.',
        'Return to the standing position.'
      ],
      icon: Icons.downhill_skiing,
      color: Colors.orange,
    ),
    
    // Shoulders
    Exercise(
      id: 'overhead_press',
      name: 'Overhead Press',
      category: ExerciseCategory.shoulders,
      difficulty: DifficultyLevel.intermediate,
      muscleGroups: ['Shoulders', 'Triceps'],
      description: 'A fundamental upper body exercise that targets the deltoid muscles.',
      instructions: [
        'Hold the barbell at shoulder height.',
        'Press the bar directly overhead until arms are locked.',
        'Lower back to shoulder height.'
      ],
      icon: Icons.upload,
      color: Colors.red,
    ),
    
    // Arms
    Exercise(
      id: 'bicep_curls',
      name: 'Bicep Curls',
      category: ExerciseCategory.arms,
      difficulty: DifficultyLevel.beginner,
      muscleGroups: ['Biceps'],
      description: 'A variable-resistance weight training exercise that targets the biceps brachii.',
      instructions: [
        'Hold dumbbells at your sides.',
        'Curl the weights toward your shoulders.',
        'Lower back down slowly.'
      ],
      icon: Icons.gesture,
      color: Colors.purple,
    ),
    
    // Core
    Exercise(
      id: 'plank',
      name: 'Plank',
      category: ExerciseCategory.core,
      difficulty: DifficultyLevel.beginner,
      muscleGroups: ['Abs', 'Core'],
      description: 'An isometric core strength exercise that involves maintaining a position similar to a push-up for the maximum possible time.',
      instructions: [
        'Hold a push-up position but on your forearms.',
        'Keep your body in a straight line.',
        'Engage your core and hold.'
      ],
      icon: Icons.horizontal_rule,
      color: Colors.teal,
    ),
  ];

  static List<Exercise> getExercisesByCategory(ExerciseCategory category) {
    return exercises.where((e) => e.category == category).toList();
  }
}
