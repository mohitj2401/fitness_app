import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/gamification_service.dart';
import '../data/yoga_db_helper.dart';
import '../models/yoga_session_model.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../achievements/models/achievement_model.dart';
import '../../achievements/logic/achievement_service.dart';
import '../../achievements/presentation/achievement_unlock_dialog.dart';

class YogaSessionScreen extends StatefulWidget {
  final String sessionTitle;
  const YogaSessionScreen({super.key, required this.sessionTitle});

  @override
  State<YogaSessionScreen> createState() => _YogaSessionScreenState();
}

class _YogaSessionScreenState extends State<YogaSessionScreen> {
  bool _isPlaying = false;
  int _durationSeconds = 0;
  Timer? _timer;

  Map<String, String> get _sessionData {
    switch (widget.sessionTitle) {
      case 'Pranayama':
        return {
          'pose': 'Sukhasana',
          'image': 'assets/images/yoga/categories/pranayama.png',
          'focus': 'Focus on your breathing (Pranayama)',
        };
      case 'Meditation':
        return {
          'pose': 'Dhyana',
          'image': 'assets/images/yoga/categories/meditation.png',
          'focus': 'Focus on your mindfulness (Meditation)',
        };
      case 'Surya Namaskar':
        return {
          'pose': 'Surya Namaskar',
          'image': 'assets/images/yoga/categories/surya_namaskar.png',
          'focus': 'Follow the flow of the sun.',
        };
      default:
        return {
          'pose': 'Tadasana',
          'image': 'assets/images/yoga/poses/tadasana.png',
          'focus': 'Focus on your posture and breath.',
        };
    }
  }
  // Removed YogaStorageService

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _durationSeconds++;
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _endSession() async {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });

    if (_durationSeconds < 5) {
      // Too short, just exit
      Navigator.pop(context);
      return;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Material(
            color: Colors.transparent,
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.help_outline_rounded, color: AppThemes.accentPurple, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "End Session?",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "You have practiced for ${_formatDuration(_durationSeconds)}.\nSave this session to your history?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              "DISCARD",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemes.accentPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              "SAVE SESSION",
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (shouldSave == true && mounted) {
      final session = YogaSessionModel(
        id: const Uuid().v4(),
        title: widget.sessionTitle,
        durationSeconds: _durationSeconds,
        timestamp: DateTime.now(),
      );

      await YogaDatabaseHelper.instance.createSession(session);

      // Add XP
      bool leveledUp = await GamificationService.instance.addYogaXP(_durationSeconds ~/ 60);

      List<AchievementModel> newlyUnlocked = [];
      // Check for achievements
      try {
        newlyUnlocked = await AchievementService().checkAndUnlockAchievements();
      } catch (e) {
        debugPrint("Error checking achievements: $e");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session saved successfully!")),
        );

        // Pop the session screen first 
        Navigator.pop(context, true);

        // Refresh dashboard stats
        DashboardScreen.triggerRefresh();

        // Level Up Celebration
        if (leveledUp) {
          _showLevelUpCelebration();
        }

        // Show achievements
        if (newlyUnlocked.isNotEmpty) {
          for (var achievement in newlyUnlocked) {
            AchievementUnlockDialog.show(context, achievement);
          }
        }
      }
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showLevelUpCelebration() async {
    final xp = await GamificationService.instance.getTotalXP();
    final level = GamificationService.instance.getLevelForXP(xp);
    final title = GamificationService.instance.getLevelTitle(level);
    final tierColor = GamificationService.instance.getTierColor(level);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Material(
            color: Colors.transparent,
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, color: tierColor, size: 80),
                const SizedBox(height: 16),
                Text(
                  "LEVEL UP!",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: tierColor,
                        letterSpacing: 2,
                      ),
                ),
                Text(
                  "NEW RANK: ${title.toUpperCase()}",
                  style: TextStyle(
                    color: tierColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "You've reached a new level of fitness. Keep pushing your limits!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.accentPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("CONTINUE", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sessionTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppThemes.accentPurple.withOpacity(0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Yoga pose image
                Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      _sessionData['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Current Pose: ${_sessionData['pose']}",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _sessionData['focus']!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 40),
                // Timer display with GlassCard
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    child: Text(
                      _formatDuration(_durationSeconds),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontFeatures: [const FontFeature.tabularFigures()],
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.large(
                      heroTag: "play",
                      onPressed: _toggleTimer,
                      elevation: 0,
                      backgroundColor: _isPlaying
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: _isPlaying ? Colors.orange : Colors.green,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 40,
                        color: _isPlaying ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 24),
                    FloatingActionButton.large(
                      heroTag: "stop",
                      onPressed: _endSession,
                      elevation: 0,
                      backgroundColor: Colors.red.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.red, width: 2),
                      ),
                      child: const Icon(Icons.stop_rounded, size: 40, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
