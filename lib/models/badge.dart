class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int requirementValue;
  final String requirementType; // 'workouts', 'streak', 'weight', etc.
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;
  final String unlockCriteria;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.requirementValue,
    required this.requirementType,
    required this.isUnlocked,
    this.unlockedAt,
    required this.currentProgress,
    required this.unlockCriteria,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: json['category'] as String,
      requirementValue: json['requirementValue'] as int,
      requirementType: json['requirementType'] as String,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      currentProgress: json['currentProgress'] as int,
      unlockCriteria: json['unlockCriteria'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category,
      'requirementValue': requirementValue,
      'requirementType': requirementType,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
      'unlockCriteria': unlockCriteria,
    };
  }

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? category,
    int? requirementValue,
    String? requirementType,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
    String? unlockCriteria,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      requirementValue: requirementValue ?? this.requirementValue,
      requirementType: requirementType ?? this.requirementType,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      unlockCriteria: unlockCriteria ?? this.unlockCriteria,
    );
  }
}
