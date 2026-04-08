import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../data/achievement_db_helper.dart';
import '../models/achievement_model.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<AchievementModel> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final achievements = await AchievementDatabaseHelper.instance
        .getAllAchievements();
    if (mounted) {
      setState(() {
        _achievements = achievements;
        _isLoading = false;
      });
    }
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
              "Achievements",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final achievement = _achievements[index];
                        return _AchievementCard(
                          achievement: achievement,
                          icon: _getIcon(achievement.iconName),
                        );
                      },
                      childCount: _achievements.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final IconData icon;

  const _AchievementCard({required this.achievement, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final color = isUnlocked ? AppThemes.accentPurple : Colors.white.withValues(alpha: 0.2);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isUnlocked ? Colors.white : Colors.white.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          if (isUnlocked && achievement.unlockedAt != null) ...[
            const SizedBox(height: 12),
            Text(
              "UNLOCKED ${DateFormat('MMM d').format(achievement.unlockedAt!)}".toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                color: AppThemes.accentPurple,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
