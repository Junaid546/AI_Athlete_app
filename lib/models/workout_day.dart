import 'workout_exercise.dart';

class WorkoutDay {
  final String id;
  final int week;
  final int day;
  final String name;
  final String description;
  final List<WorkoutExercise> exercises;
  final Duration estimatedDuration;
  final String? focus; // e.g., "Upper Body", "Lower Body", "Full Body"
  final bool isRestDay;
  final DateTime? scheduledDate;

  WorkoutDay({
    required this.id,
    required this.week,
    required this.day,
    required this.name,
    required this.description,
    required this.exercises,
    required this.estimatedDuration,
    this.focus,
    this.isRestDay = false,
    this.scheduledDate,
  });

  WorkoutDay copyWith({
    String? id,
    int? week,
    int? day,
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    Duration? estimatedDuration,
    String? focus,
    bool? isRestDay,
    DateTime? scheduledDate,
  }) {
    return WorkoutDay(
      id: id ?? this.id,
      week: week ?? this.week,
      day: day ?? this.day,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      focus: focus ?? this.focus,
      isRestDay: isRestDay ?? this.isRestDay,
      scheduledDate: scheduledDate ?? this.scheduledDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week': week,
      'day': day,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'estimatedDuration': estimatedDuration.inMinutes,
      'focus': focus,
      'isRestDay': isRestDay,
      'scheduledDate': scheduledDate?.toIso8601String(),
    };
  }

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      id: json['id'],
      week: json['week'],
      day: json['day'],
      name: json['name'],
      description: json['description'],
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromJson(e))
          .toList() ?? [],
      estimatedDuration: Duration(minutes: json['estimatedDuration'] ?? 60),
      focus: json['focus'],
      isRestDay: json['isRestDay'] ?? false,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
    );
  }

  // Helper methods
  int get totalExercises => exercises.length;
  int get completedExercises => exercises.where((e) => e.completed).length;
  double get progress => totalExercises > 0 ? completedExercises / totalExercises : 0.0;

  bool get isCompleted => completedExercises >= totalExercises;

  // Calculate total volume for the day
  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) => sum + exercise.totalVolume);
  }

  // Get exercises by muscle group
  List<WorkoutExercise> exercisesForMuscle(String muscle) {
    return exercises.where((e) =>
      e.exercise.primaryMuscles.any((m) => m.name == muscle) ||
      e.exercise.secondaryMuscles.any((m) => m.name == muscle)
    ).toList();
  }

  // Add exercise
  WorkoutDay addExercise(WorkoutExercise exercise) {
    final newExercises = List<WorkoutExercise>.from(exercises)..add(exercise);
    return copyWith(exercises: newExercises);
  }

  // Update exercise
  WorkoutDay updateExercise(String exerciseId, WorkoutExercise updatedExercise) {
    final newExercises = exercises.map((e) => e.id == exerciseId ? updatedExercise : e).toList();
    return copyWith(exercises: newExercises);
  }

  // Remove exercise
  WorkoutDay removeExercise(String exerciseId) {
    final newExercises = exercises.where((e) => e.id != exerciseId).toList();
    return copyWith(exercises: newExercises);
  }
}
