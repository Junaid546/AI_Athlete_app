enum AchievementType {
  streak,
  volume,
  strength,
  consistency,
  milestone,
  personalRecord,
  social,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final AchievementType type;
  final AchievementRarity rarity;
  final int points;
  final Map<String, dynamic> criteria; // Conditions to unlock
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress; // Current progress towards achievement
  final int target; // Target value to unlock

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.type,
    required this.rarity,
    required this.points,
    required this.criteria,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.target,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    AchievementType? type,
    AchievementRarity? rarity,
    int? points,
    Map<String, dynamic>? criteria,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? target,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      points: points ?? this.points,
      criteria: criteria ?? this.criteria,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'type': type.name,
      'rarity': rarity.name,
      'points': points,
      'criteria': criteria,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'target': target,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconName: json['iconName'],
      type: AchievementType.values.firstWhere((e) => e.name == json['type']),
      rarity: AchievementRarity.values.firstWhere((e) => e.name == json['rarity']),
      points: json['points'],
      criteria: json['criteria'] ?? {},
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      progress: json['progress'] ?? 0,
      target: json['target'],
    );
  }

  double get progressPercentage => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => progress >= target;

  String get rarityColor {
    switch (rarity) {
      case AchievementRarity.common: return '#9CA3AF'; // Gray
      case AchievementRarity.rare: return '#3B82F6'; // Blue
      case AchievementRarity.epic: return '#8B5CF6'; // Purple
      case AchievementRarity.legendary: return '#F59E0B'; // Gold
    }
  }

  String get typeDisplayName {
    switch (type) {
      case AchievementType.streak: return 'Streak';
      case AchievementType.volume: return 'Volume';
      case AchievementType.strength: return 'Strength';
      case AchievementType.consistency: return 'Consistency';
      case AchievementType.milestone: return 'Milestone';
      case AchievementType.personalRecord: return 'PR';
      case AchievementType.social: return 'Social';
    }
  }
}

// Predefined achievements
class AchievementTemplates {
  static final List<Achievement> all = [
    // Streak achievements
    Achievement(
      id: 'first_workout',
      title: 'First Steps',
      description: 'Complete your first workout',
      iconName: 'fitness_center',
      type: AchievementType.milestone,
      rarity: AchievementRarity.common,
      points: 10,
      criteria: {'completedWorkouts': 1},
      target: 1,
    ),
    Achievement(
      id: 'week_streak',
      title: 'Week Warrior',
      description: 'Workout for 7 consecutive days',
      iconName: 'local_fire_department',
      type: AchievementType.streak,
      rarity: AchievementRarity.rare,
      points: 50,
      criteria: {'consecutiveDays': 7},
      target: 7,
    ),
    Achievement(
      id: 'month_streak',
      title: 'Monthly Master',
      description: 'Workout for 30 consecutive days',
      iconName: 'whatshot',
      type: AchievementType.streak,
      rarity: AchievementRarity.epic,
      points: 200,
      criteria: {'consecutiveDays': 30},
      target: 30,
    ),

    // Volume achievements
    Achievement(
      id: 'volume_1000',
      title: 'Ton Lifter',
      description: 'Lift 1,000 kg total volume',
      iconName: 'scale',
      type: AchievementType.volume,
      rarity: AchievementRarity.common,
      points: 25,
      criteria: {'totalVolume': 1000},
      target: 1000,
    ),
    Achievement(
      id: 'volume_10000',
      title: 'Iron Warrior',
      description: 'Lift 10,000 kg total volume',
      iconName: 'sports_gymnastics',
      type: AchievementType.volume,
      rarity: AchievementRarity.epic,
      points: 150,
      criteria: {'totalVolume': 10000},
      target: 10000,
    ),

    // Strength achievements
    Achievement(
      id: 'bench_100',
      title: 'Bench Boss',
      description: 'Bench press 100 kg',
      iconName: 'fitness_center',
      type: AchievementType.strength,
      rarity: AchievementRarity.rare,
      points: 75,
      criteria: {'exercise': 'bench_press', 'weight': 100},
      target: 100,
    ),

    // Consistency achievements
    Achievement(
      id: 'consistency_50',
      title: 'Dedicated Athlete',
      description: 'Complete 50 workouts',
      iconName: 'timeline',
      type: AchievementType.consistency,
      rarity: AchievementRarity.rare,
      points: 100,
      criteria: {'totalWorkouts': 50},
      target: 50,
    ),
  ];
}
