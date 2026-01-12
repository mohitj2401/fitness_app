import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/yoga_db_helper.dart';
import '../data/yoga_statistics.dart';
import '../models/yoga_session_model.dart';

class YogaDailyReportScreen extends StatefulWidget {
  const YogaDailyReportScreen({super.key});

  @override
  State<YogaDailyReportScreen> createState() => _YogaDailyReportScreenState();
}

class _YogaDailyReportScreenState extends State<YogaDailyReportScreen> {
  YogaStatistics? _statistics;
  List<YogaSessionModel> _sessions = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final sessions = await YogaDatabaseHelper.instance.getAllSessions();
    setState(() {
      _sessions = sessions;
      _statistics = YogaStatistics.fromSessions(sessions);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yoga Daily Report")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No yoga sessions recorded yet."),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallStats(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Daily Breakdown"),
                    const SizedBox(height: 12),
                    _buildDailyBreakdown(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Sessions by Type"),
                    const SizedBox(height: 12),
                    _buildSessionsByType(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOverallStats() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Overall Statistics",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  "Total Sessions",
                  _statistics!.totalSessions.toString(),
                  Icons.fitness_center,
                  Colors.blue,
                ),
                _buildStatItem(
                  "Total Minutes",
                  _statistics!.totalMinutes.toString(),
                  Icons.timer,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildDailyBreakdown() {
    final dailyData = _statistics!.getDailyMinutesSorted();

    if (dailyData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No daily data available."),
        ),
      );
    }

    return Column(
      children: dailyData.take(7).map((entry) {
        final date = DateTime.parse(entry.key);
        final minutes = entry.value;
        final isToday = _isToday(date);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isToday
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : null,
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              DateFormat.yMMMd().format(date),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(isToday ? "Today" : DateFormat.EEEE().format(date)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$minutes min",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionsByType() {
    final sessionsByType = _statistics!.sessionsByType.entries.toList();
    sessionsByType.sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sessionsByType.map((entry) {
        final percentage = (_statistics!.totalSessions > 0)
            ? (entry.value / _statistics!.totalSessions * 100).round()
            : 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorForType(entry.key),
              child: Text(
                entry.value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(entry.key),
            subtitle: Text("$percentage% of total sessions"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      }).toList(),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Asanas':
        return Colors.orange;
      case 'Pranayama':
        return Colors.blue;
      case 'Meditation':
        return Colors.green;
      case 'Surya Namaskar':
        return Colors.amber;
      default:
        return Colors.purple;
    }
  }
}
