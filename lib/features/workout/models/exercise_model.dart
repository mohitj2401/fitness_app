import 'package:flutter/material.dart';

enum ExerciseCategory { chest, back, legs, shoulders, arms, core }

enum DifficultyLevel { beginner, intermediate, advanced }

class Exercise {
  final String id;
  final String name;
  final ExerciseCategory category;
  final DifficultyLevel difficulty;
  final List<String> muscleGroups;
  final String description;
  final List<String> instructions;
  final IconData icon;
  final Color color;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.muscleGroups,
    required this.description,
    required this.instructions,
    required this.icon,
    required this.color,
  });

  String get difficultyText {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }

  String get categoryText {
    switch (category) {
      case ExerciseCategory.chest:
        return 'Chest';
      case ExerciseCategory.back:
        return 'Back';
      case ExerciseCategory.legs:
        return 'Legs';
      case ExerciseCategory.shoulders:
        return 'Shoulders';
      case ExerciseCategory.arms:
        return 'Arms';
      case ExerciseCategory.core:
        return 'Core';
    }
  }
}
