import 'package:uuid/uuid.dart';

class WorkoutSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final String name; // e.g., "Leg Day", "Morning Workout"
  final String note;
  final List<WorkoutSet> sets;

  WorkoutSession({
    String? id,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
    this.name = 'Workout',
    this.note = '',
    this.sets = const [],
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'name': name,
      'note': note,
    };
  }

  factory WorkoutSession.fromMap(
    Map<String, dynamic> map,
    List<WorkoutSet> sets,
  ) {
    return WorkoutSession(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      durationSeconds: map['durationSeconds'] ?? 0,
      name: map['name'] ?? 'Workout',
      note: map['note'] ?? '',
      sets: sets,
    );
  }

  WorkoutSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    String? name,
    String? note,
    List<WorkoutSet>? sets,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      name: name ?? this.name,
      note: note ?? this.note,
      sets: sets ?? this.sets,
    );
  }
}

class WorkoutSet {
  final String id;
  final String sessionId;
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final bool isCompleted;
  final DateTime timestamp;

  WorkoutSet({
    String? id,
    required this.sessionId,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    this.isCompleted = true,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'weight': weight.toString(),
      'reps': reps,
      'isCompleted': isCompleted ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'],
      sessionId: map['sessionId'],
      exerciseId: map['exerciseId'],
      exerciseName: map['exerciseName'],
      weight: double.tryParse(map['weight'].toString()) ?? 0.0,
      reps: map['reps'] as int,
      isCompleted: (map['isCompleted'] as int) == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
