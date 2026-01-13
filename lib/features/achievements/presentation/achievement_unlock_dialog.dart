import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../../../main.dart'; // Import to access navigatorKey

class AchievementUnlockDialog extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementUnlockDialog({super.key, required this.achievement});

  static void show(BuildContext context, AchievementModel achievement) {
    // We use the global navigator key to ensure the dialog stays visible
    // even if the calling screen is popped or replaced.
    final state = navigatorKey.currentState;
    if (state != null && state.context.mounted) {
      showDialog(
        context: state.context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => AchievementUnlockDialog(achievement: achievement),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ACHIEVEMENT UNLOCKED!",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("AWESOME!"),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -40,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _getIcon(achievement.iconName),
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'bolt':
        return Icons.bolt;
      case 'timer':
        return Icons.timer;
      case 'military_tech':
        return Icons.military_tech;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'bedtime':
        return Icons.bedtime;
      default:
        return Icons.emoji_events;
    }
  }
}
