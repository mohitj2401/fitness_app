import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../data/yoga_db_helper.dart';
import '../models/yoga_session_model.dart';

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
      builder: (context) => AlertDialog(
        title: const Text("End Session?"),
        content: Text(
          "You have practiced for ${_formatDuration(_durationSeconds)}. Save this session?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Discard"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session saved successfully!")),
        );
        Navigator.pop(context, true); // Return true to signal refresh needed
      }
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sessionTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
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
                      "assets/images/yoga/poses/tadasana.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Current Pose: Tadasana",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Focus on your breathing (Pranayama)",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 40),
                // Timer display with card background
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatDuration(_durationSeconds),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontFeatures: [const FontFeature.tabularFigures()],
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
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
                      backgroundColor: _isPlaying
                          ? Colors.orange
                          : Colors.green,
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 20),
                    FloatingActionButton.large(
                      heroTag: "stop",
                      onPressed: _endSession,
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.stop, size: 36),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
