class ExerciseProgress {
  final String exerciseName;
  final double startWeight;
  final double currentWeight;
  final int prCount;

  ExerciseProgress({
    required this.exerciseName,
    required this.startWeight,
    required this.currentWeight,
    required this.prCount,
  });

  double get progressPercentage {
    if (startWeight == 0) return 0;
    return ((currentWeight - startWeight) / startWeight) * 100;
  }

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) {
    return ExerciseProgress(
      exerciseName: json['exerciseName'],
      startWeight: json['startWeight'].toDouble(),
      currentWeight: json['currentWeight'].toDouble(),
      prCount: json['prCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'startWeight': startWeight,
      'currentWeight': currentWeight,
      'prCount': prCount,
    };
  }
}
