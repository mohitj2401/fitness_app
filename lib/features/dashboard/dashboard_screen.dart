import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_bloc.dart';
import '../yoga/presentation/yoga_screen.dart';
import '../workout/presentation/workout_screen.dart';
import '../workout/presentation/workout_history_screen.dart';
import '../achievements/presentation/achievements_screen.dart';
import '../workout/data/workout_db_helper.dart';
import '../workout/models/workout_log_model.dart';
import '../yoga/data/yoga_db_helper.dart';
import '../yoga/models/yoga_session_model.dart';
import '../achievements/data/achievement_db_helper.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  // Global notifier to trigger stats refresh across all tabs
  static final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  // Helper to trigger refresh
  static void triggerRefresh() {
    refreshNotifier.value++;
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const YogaScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.self_improvement_outlined),
                selectedIcon: Icon(Icons.self_improvement),
                label: 'Yoga',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _workoutCount = 0;
  int _totalMinutes = 0;
  int _caloriesBurned = 0;
  WorkoutSession? _lastWorkout;
  YogaSessionModel? _lastYoga;
  int _achievementCount = 0;
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
    // Gym stats
    final gymCount = await WorkoutDatabaseHelper.instance.getWorkoutCount();
    final gymSeconds = await WorkoutDatabaseHelper.instance.getTotalDuration();
    final lastWorkout = await WorkoutDatabaseHelper.instance.getLastWorkout();

    // Yoga stats
    final yogaCount = await YogaDatabaseHelper.instance.getSessionCount();
    final yogaSeconds = await YogaDatabaseHelper.instance.getTotalDuration();

    // Fetch last yoga session
    final yogaSessions = await YogaDatabaseHelper.instance.getAllSessions();
    final lastYoga = yogaSessions.isNotEmpty ? yogaSessions.first : null;

    // Achievement stats
    final achievementCount = await AchievementDatabaseHelper.instance
        .getUnlockedCount();

    if (mounted) {
      setState(() {
        _workoutCount = gymCount + yogaCount;
        _totalMinutes = (gymSeconds + yogaSeconds) ~/ 60;
        _achievementCount = achievementCount;
        // Simple calorie estimation: ~5 cal per minute of exercise
        _caloriesBurned = _totalMinutes * 5;
        _lastWorkout = lastWorkout;
        _lastYoga = lastYoga;
        _isLoading = false;
      });
    }
  }

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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Welcome back!",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Ready to crush your fitness goals?",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Cards
                        _buildStatsSection(context),
                        const SizedBox(height: 24),
                        // Quick Actions
                        Text(
                          "Quick Actions",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        // Recent Activity
                        Text(
                          "Recent Activity",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildRecentActivity(context),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          context,
          icon: Icons.fitness_center,
          label: "Sessions",
          value: "$_workoutCount",
          color: Colors.orange,
        ),
        _buildStatCard(
          context,
          icon: Icons.timer,
          label: "Minutes",
          value: "$_totalMinutes",
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          icon: Icons.local_fire_department,
          label: "Calories",
          value: _caloriesBurned > 999
              ? "${(_caloriesBurned / 1000).toStringAsFixed(1)}k"
              : "$_caloriesBurned",
          color: Colors.red,
        ),
        _buildStatCard(
          context,
          icon: Icons.emoji_events,
          label: "Badges",
          value: "$_achievementCount",
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          context,
          icon: Icons.play_circle_filled,
          label: "Start Workout",
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutScreen()),
            );
          },
        ),
        _buildActionCard(
          context,
          icon: Icons.self_improvement,
          label: "Yoga Session",
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const YogaScreen()),
            );
          },
        ),
        _buildActionCard(
          context,
          icon: Icons.history,
          label: "Workout History",
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
            );
          },
        ),
        _buildActionCard(
          context,
          icon: Icons.emoji_events,
          label: "Achievements",
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AchievementsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    if (_lastWorkout == null && _lastYoga == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No recent activity. Start a workout!"),
        ),
      );
    }

    // Determine which activity is more recent
    bool showYoga = false;
    if (_lastYoga != null) {
      if (_lastWorkout == null) {
        showYoga = true;
      } else if (_lastYoga!.timestamp.isAfter(_lastWorkout!.startTime)) {
        showYoga = true;
      }
    }

    if (showYoga) {
      return _buildActivityItem(
        context,
        icon: Icons.self_improvement,
        title: _lastYoga!.title,
        subtitle:
            "${_lastYoga!.durationSeconds ~/ 60} mins • ${DateFormat.yMMMd().format(_lastYoga!.timestamp)}",
        color: Colors.purple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const YogaScreen()),
          );
        },
      );
    }

    return _buildActivityItem(
      context,
      icon: Icons.fitness_center,
      title: _lastWorkout!.name.isNotEmpty
          ? _lastWorkout!.name
          : "Workout Session",
      subtitle:
          "${_lastWorkout!.durationSeconds ~/ 60} mins • ${DateFormat.yMMMd().format(_lastWorkout!.startTime)}",
      color: Colors.blue,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
        );
      },
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
    final achievementCount = await AchievementDatabaseHelper.instance
        .getUnlockedCount();

    if (mounted) {
      setState(() {
        _workoutCount = gymCount + yogaCount;
        _totalMinutes = (gymSeconds + yogaSeconds) ~/ 60;
        _achievementCount = achievementCount;
      });
    }
  }

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
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "My Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Member since ${DateFormat.yMMM().format(DateTime.now())}",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Stats Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsOverview(context),
                  const SizedBox(height: 24),
                  Text(
                    "Profile",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    context,
                    icon: Icons.emoji_events,
                    title: "Achievements",
                    subtitle: "View your earned badges",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AchievementsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Settings",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildSettingsCard(
                    context,
                    icon: Icons.palette,
                    title: "App Theme",
                    subtitle: "Light, Dark, AMOLED",
                    onTap: () => _showThemeBottomSheet(context),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Support",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    context,
                    icon: Icons.feedback,
                    title: "Feedback",
                    subtitle: "Share your thoughts",
                    onTap: () {},
                  ),
                  _buildSettingsCard(
                    context,
                    icon: Icons.contact_support,
                    title: "Contact Us",
                    subtitle: "Get help and support",
                    onTap: () {},
                  ),
                  _buildSettingsCard(
                    context,
                    icon: Icons.info,
                    title: "About Us",
                    subtitle: "Learn more about the app",
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Account Actions",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    context,
                    icon: Icons.delete_forever,
                    title: "Reset All Data",
                    subtitle: "Clear all sessions and achievements",
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

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset All Data?"),
        content: const Text(
          "This will permanently delete all your workout history, yoga sessions, and achievements. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("RESET EVERYTHING"),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    await WorkoutDatabaseHelper.instance.clearAllData();
    await YogaDatabaseHelper.instance.clearAllData();
    await AchievementDatabaseHelper.instance.resetAchievements();

    DashboardScreen.triggerRefresh();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All data has been cleared.")),
      );
    }
  }

  Widget _buildStatsOverview(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.fitness_center,
            label: "Sessions",
            value: "$_workoutCount",
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.timer,
            label: "Minutes",
            value: "$_totalMinutes",
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.emoji_events,
            label: "Badges",
            value: "$_achievementCount",
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Theme",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      RadioListTile<AppThemeMode>(
                        title: const Text("Light Mode"),
                        value: AppThemeMode.light,
                        groupValue: state.themeMode,
                        onChanged: (val) {
                          context.read<ThemeBloc>().add(ThemeChanged(val!));
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<AppThemeMode>(
                        title: const Text("Dark Mode"),
                        value: AppThemeMode.dark,
                        groupValue: state.themeMode,
                        onChanged: (val) {
                          context.read<ThemeBloc>().add(ThemeChanged(val!));
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<AppThemeMode>(
                        title: const Text("AMOLED Mode"),
                        value: AppThemeMode.amoled,
                        groupValue: state.themeMode,
                        onChanged: (val) {
                          context.read<ThemeBloc>().add(ThemeChanged(val!));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
