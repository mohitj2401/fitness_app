class BodyMeasurement {
  final int? id;
  final double weight;
  final double bodyFat;
  final DateTime timestamp;

  BodyMeasurement({
    this.id,
    required this.weight,
    required this.bodyFat,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'body_fat': bodyFat,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id'],
      weight: map['weight'],
      bodyFat: map['body_fat'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
