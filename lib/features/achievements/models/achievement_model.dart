class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String category; // 'gym', 'yoga', 'consistency'
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementModel copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      iconName: iconName,
      category: category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'category': category,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    return AchievementModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconName: map['iconName'],
      category: map['category'],
      isUnlocked: map['isUnlocked'] == 1,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
    );
  }
}
