import 'workout_exercise.dart';

enum SessionType {
  planned, // From a workout plan
  custom, // Custom workout
  quick, // Quick session
}

class WorkoutSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String planId;
  final String planName;
  final SessionType type;
  final List<WorkoutExercise> exercises;
  final Duration? plannedDuration;
  final Duration? actualDuration;
  final double totalVolume; // kg or lbs lifted
  final int totalSets;
  final int totalReps;
  final double? caloriesBurned;
  final int averageHeartRate;
  final String? notes;
  final String? location;
  final bool completed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.planId,
    required this.planName,
    this.type = SessionType.planned,
    required this.exercises,
    this.plannedDuration,
    this.actualDuration,
    this.totalVolume = 0.0,
    this.totalSets = 0,
    this.totalReps = 0,
    this.caloriesBurned,
    this.averageHeartRate = 0,
    this.notes,
    this.location,
    this.completed = false,
    required this.createdAt,
    this.updatedAt,
  });

  WorkoutSession copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? planId,
    String? planName,
    SessionType? type,
    List<WorkoutExercise>? exercises,
    Duration? plannedDuration,
    Duration? actualDuration,
    double? totalVolume,
    int? totalSets,
    int? totalReps,
    double? caloriesBurned,
    int? averageHeartRate,
    String? notes,
    String? location,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      type: type ?? this.type,
      exercises: exercises ?? this.exercises,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      totalVolume: totalVolume ?? this.totalVolume,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'planId': planId,
      'planName': planName,
      'type': type.name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'plannedDuration': plannedDuration?.inSeconds,
      'actualDuration': actualDuration?.inSeconds,
      'totalVolume': totalVolume,
      'totalSets': totalSets,
      'totalReps': totalReps,
      'caloriesBurned': caloriesBurned,
      'averageHeartRate': averageHeartRate,
      'notes': notes,
      'location': location,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      planId: json['planId'],
      planName: json['planName'],
      type: SessionType.values.firstWhere((e) => e.name == json['type'], orElse: () => SessionType.planned),
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromJson(e))
          .toList() ?? [],
      plannedDuration: json['plannedDuration'] != null ? Duration(seconds: json['plannedDuration']) : null,
      actualDuration: json['actualDuration'] != null ? Duration(seconds: json['actualDuration']) : null,
      totalVolume: json['totalVolume']?.toDouble() ?? 0.0,
      totalSets: json['totalSets'] ?? 0,
      totalReps: json['totalReps'] ?? 0,
      caloriesBurned: json['caloriesBurned']?.toDouble(),
      averageHeartRate: json['averageHeartRate'] ?? 0,
      notes: json['notes'],
      location: json['location'],
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Legacy getters for backward compatibility
  DateTime get date => startTime;
  Duration get duration => actualDuration ?? plannedDuration ?? Duration.zero;
  List<String> get exercisesNames => exercises.map((e) => e.exercise.name).toList();

  // Helper methods
  int get completedExercises => exercises.where((e) => e.completed).length;
  double get progress => exercises.isNotEmpty ? completedExercises / exercises.length : 0.0;

  bool get isCompleted => completedExercises >= exercises.length;

  // Calculate session stats
  double get calculatedVolume => exercises.fold(0.0, (sum, e) => sum + e.totalVolume);
  int get calculatedSets => exercises.fold(0, (sum, e) => sum + e.completedSets);
  int get calculatedReps => exercises.fold(0, (sum, e) => sum + e.sets.where((s) => s.completed).fold(0, (sum, s) => sum + (s.reps ?? 0)));

  // Get personal records from this session
  List<WorkoutExercise> get personalRecords {
    return exercises.where((e) => e.bestSet != null).toList();
  }

  // Duration display
  String get durationDisplay {
    final dur = actualDuration ?? plannedDuration;
    if (dur == null) return '--:--';
    final minutes = dur.inMinutes;
    final seconds = dur.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
