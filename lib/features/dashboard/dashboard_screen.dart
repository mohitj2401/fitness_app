import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_bloc.dart';
import '../workout/presentation/workout_history_screen.dart';
import '../achievements/presentation/achievements_screen.dart';
import '../workout/data/workout_db_helper.dart';
import '../achievements/data/achievement_db_helper.dart';
import '../yoga/data/yoga_db_helper.dart';
import '../workout/models/workout_log_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/services/gamification_service.dart';
import '../../core/services/streak_service.dart';
import '../yoga/models/yoga_session_model.dart';
import '../yoga/presentation/yoga_screen.dart';


// New UI Components
import 'presentation/widgets/weekly_progress_card.dart';
import 'presentation/widgets/active_sessions_card.dart';
import 'presentation/widgets/calories_burned_card.dart';
import 'presentation/widgets/workout_card.dart';
import 'presentation/screens/progress_screen.dart';
import 'presentation/screens/workouts_library_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  static void triggerRefresh() {
    refreshNotifier.value++;
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String _userName = "Sarah Jenkins";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Sarah Jenkins";
    });
  }

  Future<void> _updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    setState(() {
      _userName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(userName: _userName),
      const ProgressScreen(),
      const WorkoutsLibraryScreen(),
      ProfileScreen(
        userName: _userName,
        onNameChanged: _updateUserName,
      ),
    ];
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          body: screens[_currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              indicatorColor: AppThemes.accentPurple.withValues(alpha: 0.2),
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AppThemes.accentPurple),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics, color: AppThemes.accentPurple),
                  label: 'Progress',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fitness_center_outlined),
                  selectedIcon: Icon(Icons.fitness_center, color: AppThemes.accentPurple),
                  label: 'Workouts',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppThemes.accentPurple),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _dailySessions = 0;
  int _weeklySessions = 0;
  int _caloriesBurned = 0;
  int _totalXP = 0;
  int _currentLevel = 1;
  double _levelProgress = 0.0;
  int _streak = 0;
  List<dynamic> _recentActivity = []; // Mixed Gym and Yoga
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    DashboardScreen.refreshNotifier.addListener(_loadStats);
  }

  @override
  void dispose() {
    DashboardScreen.refreshNotifier.removeListener(_loadStats);
    super.dispose();
  }

  Future<void> _loadStats() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    // Find most recent Monday
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

    final gymToday = await WorkoutDatabaseHelper.instance.getSessionsCountAfter(todayStart);
    final yogaToday = await YogaDatabaseHelper.instance.getSessionsCountAfter(todayStart);
    
    final gymWeek = await WorkoutDatabaseHelper.instance.getSessionsCountAfter(weekStart);
    final yogaWeek = await YogaDatabaseHelper.instance.getSessionsCountAfter(weekStart);

    final gymSeconds = await WorkoutDatabaseHelper.instance.getTotalDuration();
    final yogaSeconds = await YogaDatabaseHelper.instance.getTotalDuration();
    
    // Fetch and merge activities
    final recentGym = await WorkoutDatabaseHelper.instance.getAllWorkoutSessions();
    final recentYoga = await YogaDatabaseHelper.instance.getAllSessions();

    if (mounted) {
      setState(() {
        _dailySessions = gymToday + yogaToday;
        _weeklySessions = gymWeek + yogaWeek;
        
        final totalSeconds = gymSeconds + yogaSeconds;
        _caloriesBurned = ((totalSeconds / 60) * 5).toInt(); 
        
        // Merge and sort by date (most recent first)
        _recentActivity = [...recentGym, ...recentYoga]
          ..sort((a, b) {
            final dateA = a is WorkoutSession ? a.startTime : (a as YogaSessionModel).timestamp;
            final dateB = b is WorkoutSession ? b.startTime : (b as YogaSessionModel).timestamp;
            return dateB.compareTo(dateA);
          });
        _recentActivity = _recentActivity.take(5).toList();
        
        _loadGamificationData();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGamificationData() async {
    final xp = await GamificationService.instance.getTotalXP();
    final streak = await StreakService.instance.calculateCurrentStreak();
    
    if (mounted) {
      setState(() {
        _totalXP = xp;
        _currentLevel = GamificationService.instance.getLevelForXP(xp);
        _levelProgress = GamificationService.instance.getLevelProgress(xp);
        _streak = streak;
      });
    }
  }

  Widget _buildLevelHUD() {
    final title = GamificationService.instance.getLevelTitle(_currentLevel);
    final tierColor = GamificationService.instance.getTierColor(_currentLevel);

    return InkWell(
      onTap: _showLevelsInfoModal,
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Level $_currentLevel",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tierColor,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tierColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: tierColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              color: tierColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${GamificationService.instance.getXPToNextLevel(_totalXP)} XP to next level",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fireplace_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "$_streak Day Streak",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  FractionallySizedBox(
                    widthFactor: _levelProgress,
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppThemes.accentPurple, Color(0xFF9D50BB)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showLevelsInfoModal() {
    final ranks = [
      {"name": "Novice", "levels": "1 - 5", "color": const Color(0xFF808080), "min": 1},
      {"name": "Athlete", "levels": "6 - 15", "color": const Color(0xFFCD7F32), "min": 6},
      {"name": "Warrior", "levels": "16 - 30", "color": const Color(0xFFC0C0C0), "min": 16},
      {"name": "Elite", "levels": "31 - 50", "color": const Color(0xFFFFD700), "min": 31},
      {"name": "Master", "levels": "51 - 80", "color": const Color(0xFFE5E4E2), "min": 51},
      {"name": "Legend", "levels": "81+", "color": const Color(0xFFB9F2FF), "min": 81},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "MASTERY PATH",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                ),
                Text(
                  "Reach new levels to unlock prestigious titles and colors.",
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: ranks.length,
                    itemBuilder: (context, index) {
                      final rank = ranks[index];
                      final isCurrent = _currentLevel >= (rank["min"] as int) && 
                                       (index == ranks.length - 1 || _currentLevel < (ranks[index + 1]["min"] as int));
                      final color = rank["color"] as Color;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCurrent ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent ? color.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                            width: isCurrent ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rank["name"] as String,
                                  style: TextStyle(
                                    color: isCurrent ? color : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Levels ${rank["levels"]}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "CURRENT",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              "Your Progress",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Good Morning, ${widget.userName.split(' ').first}!",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLevelHUD(),
                        const SizedBox(height: 24),
                        const WeeklyProgressCard(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 180,
                                child: ActiveSessionsCard(
                                  count: _dailySessions,
                                  total: _weeklySessions,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 180,
                                child: CaloriesBurnedCard(
                                  calories: _caloriesBurned,
                                  target: 1000,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Yoga Quick Access
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const YogaScreen()),
                          ),
                          borderRadius: BorderRadius.circular(24),
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            gradientColors: [
                              Colors.blueAccent.withValues(alpha: 0.1),
                              Colors.purpleAccent.withValues(alpha: 0.1),
                            ],
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.self_improvement_rounded, color: Colors.purpleAccent),
                                ),
                                const SizedBox(width: 20),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "YOGA & MINDFULNESS",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        "Find your center. Start a practice.",
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.3), size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TODAY'S WORKOUTS",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WorkoutHistoryScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "See all",
                                style: TextStyle(
                                  color: AppThemes.accentPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: _recentActivity.isEmpty
                              ? Center(
                                  child: Text(
                                    "No workouts yet. Start one today!",
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _recentActivity.length,
                                  itemBuilder: (context, index) {
                                    final item = _recentActivity[index];
                                    final bool isYoga = item is! WorkoutSession;
                                    
                                    final String title = isYoga ? item.title : item.name;
                                    final int duration = isYoga ? item.durationSeconds : item.durationSeconds;
                                    final IconData icon = isYoga ? Icons.self_improvement_rounded : Icons.history;

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: FeaturedWorkoutCard(
                                        title: title,
                                        duration: "${(duration / 60).floor()} min",
                                        calories: "${(duration / 60 * 5).floor()} kcal",
                                        icon: icon,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String userName;
  final Function(String) onNameChanged;
  
  const ProfileScreen({
    super.key,
    required this.userName,
    required this.onNameChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _workoutCount = 0;
  int _totalMinutes = 0;
  int _achievementCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    DashboardScreen.refreshNotifier.addListener(_loadStats);
  }

  @override
  void dispose() {
    DashboardScreen.refreshNotifier.removeListener(_loadStats);
    super.dispose();
  }

  Future<void> _loadStats() async {
    final gymCount = await WorkoutDatabaseHelper.instance.getWorkoutCount();
    final gymSeconds = await WorkoutDatabaseHelper.instance.getTotalDuration();
    final yogaCount = await YogaDatabaseHelper.instance.getSessionCount();
    final yogaSeconds = await YogaDatabaseHelper.instance.getTotalDuration();
    final achievementCount = await AchievementDatabaseHelper.instance.getUnlockedCount();

    if (mounted) {
      setState(() {
        _workoutCount = (gymCount + yogaCount).toInt();
        _totalMinutes = ((gymSeconds + yogaSeconds) / 60).floor();
        _achievementCount = achievementCount.toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: AppThemes.accentPurple),
                onPressed: () => _showEditNameDialog(context),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppThemes.accentPurple.withValues(alpha: 0.2),
                      Colors.black,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppThemes.accentPurple.withValues(alpha: 0.3), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.person_rounded, size: 60, color: AppThemes.accentPurple),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        "PREMIUM MEMBER",
                        style: TextStyle(
                          color: AppThemes.accentPurple.withValues(alpha: 0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 40),
                  const Text(
                    "ACCOUNT SETTINGS",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuOption(
                    context,
                    icon: Icons.emoji_events_rounded,
                    title: "Achievements",
                    subtitle: "Track your milestones",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                  ),
                  _buildMenuOption(
                    context,
                    icon: Icons.history_rounded,
                    title: "Workout History",
                    subtitle: "View past performances",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen())),
                  ),
                  _buildMenuOption(
                    context,
                    icon: Icons.palette_rounded,
                    title: "App Theme",
                    subtitle: "Customize your experience",
                    onTap: () => _showThemeBottomSheet(context),
                  ),
                  _buildMenuOption(
                    context,
                    icon: Icons.delete_sweep_rounded,
                    title: "Reset Account",
                    subtitle: "Permanent data removal",
                    color: Colors.redAccent,
                    onTap: () => _showResetConfirmation(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Sessions", "$_workoutCount"),
          Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.1)),
          _buildStatItem("Minutes", "$_totalMinutes"),
          Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.1)),
          _buildStatItem("Badges", "$_achievementCount"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (color ?? AppThemes.accentPurple).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? AppThemes.accentPurple, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2)),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassCard(
          padding: const EdgeInsets.all(24.0),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Theme",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildThemeOption(context, "Light Mode", AppThemeMode.light),
              _buildThemeOption(context, "Dark Mode", AppThemeMode.dark),
              _buildThemeOption(context, "AMOLED Mode", AppThemeMode.amoled),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, AppThemeMode mode) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isSelected = state.themeMode == mode;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 16,
            child: RadioListTile<AppThemeMode>(
              title: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              value: mode,
              activeColor: AppThemes.accentPurple,
              groupValue: state.themeMode,
              onChanged: (val) {
                if (val != null) {
                  context.read<ThemeBloc>().add(ThemeChanged(val));
                  Navigator.pop(context);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reset All Data?",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "This action cannot be undone. All your workout history and achievements will be permanently removed.",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _resetAllData();
                    },
                    child: const Text("RESET DATA"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetAllData() async {
    await WorkoutDatabaseHelper.instance.clearAllData();
    await YogaDatabaseHelper.instance.clearAllData();
    await AchievementDatabaseHelper.instance.resetAchievements();
    DashboardScreen.triggerRefresh();
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.userName);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Profile",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Your Name",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppThemes.accentPurple, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.accentPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        widget.onNameChanged(controller.text.trim());
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("SAVE CHANGES"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
