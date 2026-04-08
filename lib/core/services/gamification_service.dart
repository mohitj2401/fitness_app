import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationService {
  static final GamificationService instance = GamificationService._internal();
  GamificationService._internal();

  static const String _xpKey = 'user_total_xp';
  
  // XP Calculation Constants
  static const int gymBaseXP = 50;
  static const int xpPerSet = 10;
  static const int xpPerYogaMinute = 2;

  /// Returns the current total XP.
  Future<int> getTotalXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  /// Specialized method for Yoga sessions (based on duration)
  Future<bool> addYogaXP(int durationMinutes) async {
    final amount = durationMinutes * xpPerYogaMinute;
    return await addXP(amount < 10 ? 10 : amount); // Minimum 10 XP
  }

  /// Specialized method for Gym sessions (based on intensity/sets)
  Future<bool> addGymXP(int setCount) async {
    final amount = gymBaseXP + (setCount * xpPerSet);
    return await addXP(amount);
  }

  /// Returns the title for a given level.
  String getLevelTitle(int level) {
    if (level >= 81) return "Legend";
    if (level >= 51) return "Master";
    if (level >= 31) return "Elite";
    if (level >= 16) return "Warrior";
    if (level >= 6) return "Athlete";
    return "Novice";
  }

  /// Returns a signature color for the current level tier.
  Color getTierColor(int level) {
    if (level >= 81) return const Color(0xFFB9F2FF); // Diamond
    if (level >= 51) return const Color(0xFFE5E4E2); // Platinum
    if (level >= 31) return const Color(0xFFFFD700); // Gold
    if (level >= 16) return const Color(0xFFC0C0C0); // Silver
    if (level >= 6) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFF808080); // Iron
  }

  /// Adds XP to the total and returns whether a Level Up occurred.
  Future<bool> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentXP = prefs.getInt(_xpKey) ?? 0;
    
    final currentLevel = getLevelForXP(currentXP);
    final newXP = currentXP + (amount < 0 ? 0 : amount);
    final newLevel = getLevelForXP(newXP);
    
    await prefs.setInt(_xpKey, newXP);
    
    return newLevel > currentLevel;
  }

  /// Calculates the level based on XP.
  /// Level 1: 0 - 500 XP
  /// Level 2: 500 - 1500 XP (+1000)
  /// Level 3: 1500 - 3000 XP (+1500)
  /// Threshold for level L is 500 * (L-1) * L / 2
  int getLevelForXP(int xp) {
    int level = 1;
    while (xp >= _getXPThresholdForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  /// Returns the XP threshold to reach a specific level.
  int _getXPThresholdForLevel(int level) {
    if (level <= 1) return 0;
    return (500 * (level - 1) * level ~/ 2);
  }

  /// Returns progress within the current level (0.0 to 1.0).
  double getLevelProgress(int xp) {
    final currentLevel = getLevelForXP(xp);
    final currentThreshold = _getXPThresholdForLevel(currentLevel);
    final nextThreshold = _getXPThresholdForLevel(currentLevel + 1);
    
    final xpInCurrentLevel = xp - currentThreshold;
    final xpRequiredForLevel = nextThreshold - currentThreshold;
    
    return (xpInCurrentLevel / xpRequiredForLevel).clamp(0.0, 1.0);
  }

  /// Returns how much XP is needed for the next level.
  int getXPToNextLevel(int xp) {
    final currentLevel = getLevelForXP(xp);
    final nextThreshold = _getXPThresholdForLevel(currentLevel + 1);
    return nextThreshold - xp;
  }
}
