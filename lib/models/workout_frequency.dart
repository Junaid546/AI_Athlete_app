class WorkoutFrequency {
  final DateTime date;
  final bool completed;

  WorkoutFrequency({
    required this.date,
    required this.completed,
  });

  factory WorkoutFrequency.fromJson(Map<String, dynamic> json) {
    return WorkoutFrequency(
      date: DateTime.parse(json['date']),
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'completed': completed,
    };
  }
}
