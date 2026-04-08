import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../workout/data/workout_db_helper.dart';
import '../../../yoga/data/yoga_db_helper.dart';

class WeeklyProgressCard extends StatefulWidget {
  const WeeklyProgressCard({super.key});

  @override
  State<WeeklyProgressCard> createState() => _WeeklyProgressCardState();
}

class _WeeklyProgressCardState extends State<WeeklyProgressCard> {
  List<double> _weeklyData = List.filled(7, 0.0);
  int _totalMinutes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final gymSessions = await WorkoutDatabaseHelper.instance.getAllWorkoutSessions();
    final yogaSessions = await YogaDatabaseHelper.instance.getAllSessions();

    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1=Mon, 7=Sun
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    final Map<int, int> dayMinutes = {};
    int total = 0;

    for (var s in gymSessions) {
      if (s.startTime.isAfter(monday.subtract(const Duration(seconds: 1)))) {
        final day = s.startTime.weekday - 1;
        dayMinutes[day] = (dayMinutes[day] ?? 0) + (s.durationSeconds ~/ 60);
        total += (s.durationSeconds ~/ 60).toInt();
      }
    }

    for (var s in yogaSessions) {
      if (s.timestamp.isAfter(monday.subtract(const Duration(seconds: 1)))) {
        final day = s.timestamp.weekday - 1;
        dayMinutes[day] = (dayMinutes[day] ?? 0) + (s.durationSeconds ~/ 60);
        total += (s.durationSeconds ~/ 60).toInt();
      }
    }

    if (mounted) {
      setState(() {
        _weeklyData = List.generate(7, (i) => (dayMinutes[i] ?? 0).toDouble());
        _totalMinutes = total;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 180,
        child: GlassCard(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    // Normalize data for painter (0.0 to 1.0)
    double maxVal = _weeklyData.reduce((curr, next) => curr > next ? curr : next);
    if (maxVal < 60) maxVal = 60; // Min scale of 60 mins
    final normalizedPoints = _weeklyData.map((v) => v / maxVal).toList();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradientColors: [
        AppThemes.accentPurple.withValues(alpha: 0.8),
        AppThemes.accentMagenta.withValues(alpha: 0.6),
      ],
      borderColor: Colors.white.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WORKOUT PROGRESS (Weekly)",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${(_totalMinutes / 300 * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "of target",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: CubicBezierPainter(normalizedPoints),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DayLabel("Mon"),
              _DayLabel("Tue"),
              _DayLabel("Wed"),
              _DayLabel("Thu"),
              _DayLabel("Fri"),
              _DayLabel("Sat"),
              _DayLabel("Sun"),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                "Total Time: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              Text(
                "${_totalMinutes ~/ 60}h ${_totalMinutes % 60}m",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Text(
                "This Week",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String day;
  const _DayLabel(this.day);

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class CubicBezierPainter extends CustomPainter {
  final List<double> normalizedPoints;
  CubicBezierPainter(this.normalizedPoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (normalizedPoints.isEmpty) return;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    // Calculate actual points based on data
    final points = List.generate(7, (i) {
      final x = i * (size.width / 6);
      final y = size.height * (1.0 - (normalizedPoints[i] * 0.8 + 0.1)); // Range 0.1 to 0.9
      return Offset(x, y);
    });

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
      );
      
      fillPath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
      );
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots at points
    final dotPaint = Paint()..color = Colors.white;
    final dotOuterPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 6, dotOuterPaint);
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
