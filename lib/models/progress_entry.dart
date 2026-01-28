enum ProgressMetric {
  weight,
  bodyFat,
  muscleMass,
  bmi,
  workoutVolume,
  maxStrength,
  endurance,
  flexibility,
}

class ProgressEntry {
  final String id;
  final String userId;
  final DateTime date;
  final ProgressMetric metric;
  final double value;
  final String? unit; // kg, lbs, %, etc.
  final String? notes;
  final String? exerciseId; // For exercise-specific progress
  final String? exerciseName;
  final DateTime createdAt;

  ProgressEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.metric,
    required this.value,
    this.unit,
    this.notes,
    this.exerciseId,
    this.exerciseName,
    required this.createdAt,
  });

  ProgressEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    ProgressMetric? metric,
    double? value,
    String? unit,
    String? notes,
    String? exerciseId,
    String? exerciseName,
    DateTime? createdAt,
  }) {
    return ProgressEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      metric: metric ?? this.metric,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'metric': metric.name,
      'value': value,
      'unit': unit,
      'notes': notes,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProgressEntry.fromJson(Map<String, dynamic> json) {
    return ProgressEntry(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      metric: ProgressMetric.values.firstWhere((e) => e.name == json['metric']),
      value: json['value'].toDouble(),
      unit: json['unit'],
      notes: json['notes'],
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get displayValue {
    if (unit != null) {
      return '${value.toStringAsFixed(1)} $unit';
    }
    return value.toStringAsFixed(1);
  }

  String get metricDisplayName {
    switch (metric) {
      case ProgressMetric.weight: return 'Body Weight';
      case ProgressMetric.bodyFat: return 'Body Fat %';
      case ProgressMetric.muscleMass: return 'Muscle Mass';
      case ProgressMetric.bmi: return 'BMI';
      case ProgressMetric.workoutVolume: return 'Workout Volume';
      case ProgressMetric.maxStrength: return 'Max Strength';
      case ProgressMetric.endurance: return 'Endurance';
      case ProgressMetric.flexibility: return 'Flexibility';
    }
  }
}
