import 'workout_day.dart';

enum PlanCategory {
  strength,
  hypertrophy,
  endurance,
  power,
  sportSpecific,
  bodyweight,
  beginner,
  intermediate,
  advanced,
  custom,
}

enum PlanType {
  linear, // Same workouts every week
  periodized, // Progressive overload over weeks
  undulating, // Varying intensity/frequency
  custom,
}

class WorkoutPlan {
  final String id;
  final String name;
  final String description;
  final String authorId;
  final String authorName;
  final PlanCategory category;
  final PlanType type;
  final int weeks;
  final int daysPerWeek;
  final int difficulty; // 1-5
  final List<String> targetGoals;
  final List<String> requiredEquipment;
  final Duration estimatedDuration; // per session
  final List<WorkoutDay> workoutDays;
  final bool isPublic;
  final int rating; // 1-5
  final int reviewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? videoUrl;

  WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.category,
    required this.type,
    required this.weeks,
    required this.daysPerWeek,
    required this.difficulty,
    required this.targetGoals,
    required this.requiredEquipment,
    required this.estimatedDuration,
    required this.workoutDays,
    this.isPublic = false,
    this.rating = 0,
    this.reviewCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.videoUrl,
  });

  WorkoutPlan copyWith({
    String? id,
    String? name,
    String? description,
    String? authorId,
    String? authorName,
    PlanCategory? category,
    PlanType? type,
    int? weeks,
    int? daysPerWeek,
    int? difficulty,
    List<String>? targetGoals,
    List<String>? requiredEquipment,
    Duration? estimatedDuration,
    List<WorkoutDay>? workoutDays,
    bool? isPublic,
    int? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? videoUrl,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      category: category ?? this.category,
      type: type ?? this.type,
      weeks: weeks ?? this.weeks,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      difficulty: difficulty ?? this.difficulty,
      targetGoals: targetGoals ?? this.targetGoals,
      requiredEquipment: requiredEquipment ?? this.requiredEquipment,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      workoutDays: workoutDays ?? this.workoutDays,
      isPublic: isPublic ?? this.isPublic,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'category': category.name,
      'type': type.name,
      'weeks': weeks,
      'daysPerWeek': daysPerWeek,
      'difficulty': difficulty,
      'targetGoals': targetGoals,
      'requiredEquipment': requiredEquipment,
      'estimatedDuration': estimatedDuration.inMinutes,
      'workoutDays': workoutDays.map((d) => d.toJson()).toList(),
      'isPublic': isPublic,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      category: PlanCategory.values.firstWhere((e) => e.name == json['category']),
      type: PlanType.values.firstWhere((e) => e.name == json['type']),
      weeks: json['weeks'],
      daysPerWeek: json['daysPerWeek'],
      difficulty: json['difficulty'],
      targetGoals: List<String>.from(json['targetGoals'] ?? []),
      requiredEquipment: List<String>.from(json['requiredEquipment'] ?? []),
      estimatedDuration: Duration(minutes: json['estimatedDuration'] ?? 60),
      workoutDays: (json['workoutDays'] as List<dynamic>?)
          ?.map((d) => WorkoutDay.fromJson(d))
          .toList() ?? [],
      isPublic: json['isPublic'] ?? false,
      rating: json['rating'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
    );
  }

  // Helper methods
  WorkoutDay? getDay(int week, int day) {
    try {
      return workoutDays.firstWhere(
        (d) => d.week == week && d.day == day,
      );
    } catch (e) {
      return null;
    }
  }

  List<WorkoutDay> getWeek(int week) {
    return workoutDays.where((d) => d.week == week).toList();
  }

  int get totalSessions => weeks * daysPerWeek;

  String get difficultyText {
    switch (difficulty) {
      case 1: return 'Beginner';
      case 2: return 'Novice';
      case 3: return 'Intermediate';
      case 4: return 'Advanced';
      case 5: return 'Elite';
      default: return 'Unknown';
    }
  }

  String get categoryText {
    return category.name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim().replaceFirstMapped(
      RegExp(r'^.'), (match) => match.group(0)!.toUpperCase()
    );
  }
}
