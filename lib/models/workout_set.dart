enum SetType {
  normal,
  warmUp,
  dropSet,
  failure,
  amrap, // As Many Reps As Possible
  time, // Time-based set
}

class WorkoutSet {
  final String id;
  final int setNumber;
  final double? weight; // in kg or lbs
  final int? reps;
  final Duration? duration; // for time-based sets
  final int? rpe; // Rate of Perceived Exertion (1-10)
  final SetType type;
  final bool completed;
  final String? notes;
  final DateTime? completedAt;
  final double? restTime; // in seconds

  WorkoutSet({
    required this.id,
    required this.setNumber,
    this.weight,
    this.reps,
    this.duration,
    this.rpe,
    this.type = SetType.normal,
    this.completed = false,
    this.notes,
    this.completedAt,
    this.restTime,
  });

  WorkoutSet copyWith({
    String? id,
    int? setNumber,
    double? weight,
    int? reps,
    Duration? duration,
    int? rpe,
    SetType? type,
    bool? completed,
    String? notes,
    DateTime? completedAt,
    double? restTime,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      rpe: rpe ?? this.rpe,
      type: type ?? this.type,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      restTime: restTime ?? this.restTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'duration': duration?.inSeconds,
      'rpe': rpe,
      'type': type.name,
      'completed': completed,
      'notes': notes,
      'completedAt': completedAt?.toIso8601String(),
      'restTime': restTime,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'],
      setNumber: json['setNumber'],
      weight: json['weight']?.toDouble(),
      reps: json['reps'],
      duration: json['duration'] != null ? Duration(seconds: json['duration']) : null,
      rpe: json['rpe'],
      type: SetType.values.firstWhere((e) => e.name == json['type'], orElse: () => SetType.normal),
      completed: json['completed'] ?? false,
      notes: json['notes'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      restTime: json['restTime']?.toDouble(),
    );
  }

  // Helper methods
  bool get isTimeBased => type == SetType.time || duration != null;
  bool get isRepBased => !isTimeBased;

  String get displayValue {
    if (isTimeBased) {
      return duration != null ? '${duration!.inSeconds}s' : 'Time';
    } else {
      return reps != null ? '$reps reps' : 'Reps';
    }
  }

  String get displayWeight {
    if (weight != null) {
      return '${weight!.toStringAsFixed(1)}kg';
    }
    return '';
  }
}
