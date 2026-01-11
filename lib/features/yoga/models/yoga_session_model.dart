import 'dart:convert';

class YogaSessionModel {
  final String id;
  final String title;
  final int durationSeconds;
  final DateTime timestamp;

  YogaSessionModel({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory YogaSessionModel.fromMap(Map<String, dynamic> map) {
    return YogaSessionModel(
      id: map['id'],
      title: map['title'],
      durationSeconds: map['durationSeconds'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory YogaSessionModel.fromJson(String source) =>
      YogaSessionModel.fromMap(json.decode(source));
}
