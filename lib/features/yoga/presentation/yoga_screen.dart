import '../data/yoga_db_helper.dart';
import '../models/yoga_session_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'yoga_session_screen.dart';
import 'yoga_daily_report_screen.dart';

class YogaScreen extends StatefulWidget {
  const YogaScreen({super.key});

  @override
  State<YogaScreen> createState() => _YogaScreenState();
}

class _YogaScreenState extends State<YogaScreen> {
  List<YogaSessionModel> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final sessions = await YogaDatabaseHelper.instance.getAllSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yoga & Mindfulness"),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: "Daily Report",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const YogaDailyReportScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, "Categories"),
              const SizedBox(height: 10),
              _buildCategoryGrid(context),
              const SizedBox(height: 20),
              _buildSectionHeader(context, "Recent Sessions"),
              const SizedBox(height: 10),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_sessions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No sessions yet. Start your journey!"),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sessions.length > 5
                      ? 5
                      : _sessions.length, // Show last 5
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.self_improvement,
                          color: Colors.purple,
                        ),
                        title: Text(session.title),
                        subtitle: Text(
                          "${_formatDuration(session.durationSeconds)} • ${DateFormat.yMMMd().format(session.timestamp)}",
                        ),
                        trailing: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return "${s}s";
    return "${m}m ${s}s";
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      {
        "image": "assets/images/yoga/categories/asanas.png",
        "label": "Asanas",
        "color": Colors.orange,
      },
      {
        "image": "assets/images/yoga/categories/pranayama.png",
        "label": "Pranayama",
        "color": Colors.blue,
      },
      {
        "image": "assets/images/yoga/categories/meditation.png",
        "label": "Meditation",
        "color": Colors.green,
      },
      {
        "image": "assets/images/yoga/categories/surya_namaskar.png",
        "label": "Surya Namaskar",
        "color": Colors.amber,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      YogaSessionScreen(sessionTitle: cat["label"] as String),
                ),
              );

              if (result == true) {
                _loadHistory();
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.asset(cat["image"] as String, fit: BoxFit.cover),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                // Text content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat["label"] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
