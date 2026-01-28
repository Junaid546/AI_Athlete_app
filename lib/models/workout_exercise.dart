import 'exercise.dart';
import 'workout_set.dart';

class WorkoutExercise {
  final String id;
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final int targetSets;
  final int? targetReps;
  final double? targetWeight;
  final Duration? targetDuration;
  final String? notes;
  final bool completed;
  final DateTime? completedAt;

  WorkoutExercise({
    required this.id,
    required this.exercise,
    required this.sets,
    required this.targetSets,
    this.targetReps,
    this.targetWeight,
    this.targetDuration,
    this.notes,
    this.completed = false,
    this.completedAt,
  });

  WorkoutExercise copyWith({
    String? id,
    Exercise? exercise,
    List<WorkoutSet>? sets,
    int? targetSets,
    int? targetReps,
    double? targetWeight,
    Duration? targetDuration,
    String? notes,
    bool? completed,
    DateTime? completedAt,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      targetDuration: targetDuration ?? this.targetDuration,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise': exercise.toJson(),
      'sets': sets.map((s) => s.toJson()).toList(),
      'targetSets': targetSets,
      'targetReps': targetReps,
      'targetWeight': targetWeight,
      'targetDuration': targetDuration?.inSeconds,
      'notes': notes,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'],
      exercise: Exercise.fromJson(json['exercise']),
      sets: (json['sets'] as List<dynamic>?)
          ?.map((s) => WorkoutSet.fromJson(s))
          .toList() ?? [],
      targetSets: json['targetSets'] ?? 0,
      targetReps: json['targetReps'],
      targetWeight: json['targetWeight']?.toDouble(),
      targetDuration: json['targetDuration'] != null
          ? Duration(seconds: json['targetDuration'])
          : null,
      notes: json['notes'],
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  // Helper methods
  int get completedSets => sets.where((s) => s.completed).length;
  double get progress => targetSets > 0 ? completedSets / targetSets : 0.0;

  bool get isCompleted => completedSets >= targetSets;

  // Calculate total volume for this exercise
  double get totalVolume {
    return sets
        .where((s) => s.completed && s.weight != null && s.reps != null)
        .fold(0.0, (sum, set) => sum + (set.weight! * set.reps!));
  }

  // Get best set (highest weight or most reps)
  WorkoutSet? get bestSet {
    if (sets.isEmpty) return null;

    return sets
        .where((s) => s.completed)
        .fold<WorkoutSet?>(null, (best, current) {
      if (best == null) return current;

      // Compare by volume (weight * reps) or just reps if no weight
      double currentVolume = (current.weight ?? 0) * (current.reps ?? 0);
      double bestVolume = (best.weight ?? 0) * (best.reps ?? 0);

      if (currentVolume > bestVolume) return current;
      if (currentVolume == bestVolume && (current.reps ?? 0) > (best.reps ?? 0)) return current;

      return best;
    });
  }

  // Add a new set
  WorkoutExercise addSet(WorkoutSet set) {
    final newSets = List<WorkoutSet>.from(sets)..add(set);
    return copyWith(sets: newSets);
  }

  // Update a set
  WorkoutExercise updateSet(String setId, WorkoutSet updatedSet) {
    final newSets = sets.map((s) => s.id == setId ? updatedSet : s).toList();
    return copyWith(sets: newSets);
  }

  // Remove a set
  WorkoutExercise removeSet(String setId) {
    final newSets = sets.where((s) => s.id != setId).toList();
    return copyWith(sets: newSets);
  }
}
