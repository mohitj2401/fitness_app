import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../widgets/weekly_progress_card.dart';
import '../../data/measurement_database_helper.dart';
import '../../models/measurement_model.dart';
import '../../../../core/services/streak_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  BodyMeasurement? _latestMeasurement;
  List<bool> _weeklyActivity = List.filled(7, false);
  int _streakCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final measurement = await MeasurementDatabaseHelper.instance.getLatestMeasurement();
    final activity = await StreakService.instance.getLastSevenDaysActivity();
    final streak = await StreakService.instance.calculateCurrentStreak();

    if (mounted) {
      setState(() {
        _latestMeasurement = measurement;
        _weeklyActivity = activity;
        _streakCount = streak;
        _isLoading = false;
      });
    }
  }

  void _showAddMeasurementDialog() {
    final weightController = TextEditingController(text: _latestMeasurement?.weight.toString() ?? "");
    final bodyFatController = TextEditingController(text: _latestMeasurement?.bodyFat.toString() ?? "");

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
                "Log Measurement",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildDialogField(weightController, "Weight", "kg"),
              const SizedBox(height: 16),
              _buildDialogField(bodyFatController, "Body Fat", "%"),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.accentPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final weight = double.tryParse(weightController.text);
                      final bodyFat = double.tryParse(bodyFatController.text);
                      if (weight != null && bodyFat != null) {
                        await MeasurementDatabaseHelper.instance.addMeasurement(
                          BodyMeasurement(weight: weight, bodyFat: bodyFat, timestamp: DateTime.now()),
                        );
                        _loadData();
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text("Save Entry"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, String suffix) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppThemes.accentPurple),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_chart_rounded),
                onPressed: _showAddMeasurementDialog,
              ),
              const SizedBox(width: 8),
            ],
            title: Text(
              "Analytics",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WeeklyProgressCard(),
                  const SizedBox(height: 32),
                  
                  Text(
                    "BODY MEASUREMENTS",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMeasurementCard(
                    context,
                    label: "Body Weight",
                    value: _latestMeasurement?.weight.toStringAsFixed(1) ?? "--",
                    unit: "kg",
                    trend: "Last updated today",
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildMeasurementCard(
                    context,
                    label: "Body Fat",
                    value: _latestMeasurement?.bodyFat.toStringAsFixed(1) ?? "--",
                    unit: "%",
                    trend: "Stable",
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "STREAK",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Text(
                        "$_streakCount DAYS",
                        style: const TextStyle(
                          color: AppThemes.accentPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final days = ["M", "T", "W", "T", "F", "S", "S"];
                        final completed = _weeklyActivity[index];
                        return Column(
                          children: [
                            Text(
                              days[index],
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: completed 
                                  ? AppThemes.accentPurple 
                                  : Colors.white.withValues(alpha: 0.1),
                              ),
                              child: completed
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                            ),
                          ],
                        );
                      }),
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

  Widget _buildMeasurementCard(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required String trend,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.monitor_weight_outlined, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            trend,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
