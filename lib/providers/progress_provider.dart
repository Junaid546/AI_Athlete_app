import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress_metric.dart';
import '../models/exercise_progress.dart';
import '../models/workout_frequency.dart';
import '../models/body_photo.dart';
import '../models/workout_session.dart';

enum TimePeriod { daily, weekly, monthly, yearly, allTime }

// Data models for chart visualization
class DailyProgressData {
  final DateTime date;
  final double volume; // Total weight moved
  final int duration; // Minutes
  final int caloriesBurned;
  final int exercises;
  
  DailyProgressData({
    required this.date,
    required this.volume,
    required this.duration,
    required this.caloriesBurned,
    required this.exercises,
  });
}

class HourlyProgressData {
  final int hour; // 0-23
  final double volume;
  final int duration;
  final int caloriesBurned;
  
  HourlyProgressData({
    required this.hour,
    required this.volume,
    required this.duration,
    required this.caloriesBurned,
  });
}

class WeeklyProgressData {
  final int week;
  final double totalVolume;
  final int totalDuration; // Minutes
  final int totalCalories;
  final int workoutDays;
  final List<DailyProgressData> dailyData;
  
  WeeklyProgressData({
    required this.week,
    required this.totalVolume,
    required this.totalDuration,
    required this.totalCalories,
    required this.workoutDays,
    required this.dailyData,
  });
}

class MonthlyProgressData {
  final int month; // 1-12
  final int year;
  final double totalVolume;
  final int totalDuration; // Minutes
  final int totalCalories;
  final int workoutDays;
  final List<WeeklyProgressData> weeklyData;
  
  MonthlyProgressData({
    required this.month,
    required this.year,
    required this.totalVolume,
    required this.totalDuration,
    required this.totalCalories,
    required this.workoutDays,
    required this.weeklyData,
  });
}

class ProgressState {
  final List<ProgressMetric> volumeMetrics;
  final List<ExerciseProgress> exerciseProgress;
  final List<WorkoutFrequency> workoutFrequency;
  final List<BodyPhoto> bodyPhotos;
  final bool isLoading;
  final String? error;

  ProgressState({
    this.volumeMetrics = const [],
    this.exerciseProgress = const [],
    this.workoutFrequency = const [],
    this.bodyPhotos = const [],
    this.isLoading = false,
    this.error,
  });

  ProgressState copyWith({
    List<ProgressMetric>? volumeMetrics,
    List<ExerciseProgress>? exerciseProgress,
    List<WorkoutFrequency>? workoutFrequency,
    List<BodyPhoto>? bodyPhotos,
    bool? isLoading,
    String? error,
  }) {
    return ProgressState(
      volumeMetrics: volumeMetrics ?? this.volumeMetrics,
      exerciseProgress: exerciseProgress ?? this.exerciseProgress,
      workoutFrequency: workoutFrequency ?? this.workoutFrequency,
      bodyPhotos: bodyPhotos ?? this.bodyPhotos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier() : super(ProgressState()) {
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    // Load cached data from SharedPreferences
    // For simplicity, we'll implement basic caching later
  }

  Future<void> loadProgressData(List<WorkoutSession> sessions, TimePeriod period) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final filteredSessions = _filterSessionsByPeriod(sessions, period);

      final volumeMetrics = _calculateVolumeMetrics(filteredSessions);
      final exerciseProgress = _calculateExerciseProgress(filteredSessions);
      final workoutFrequency = _calculateWorkoutFrequency(filteredSessions);

      // For body photos, we'll need to fetch from Firestore or cache
      final bodyPhotos = await _loadBodyPhotos();

      state = state.copyWith(
        volumeMetrics: volumeMetrics,
        exerciseProgress: exerciseProgress,
        workoutFrequency: workoutFrequency,
        bodyPhotos: bodyPhotos,
        isLoading: false,
      );

      _cacheData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  List<WorkoutSession> _filterSessionsByPeriod(List<WorkoutSession> sessions, TimePeriod period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case TimePeriod.daily:
        startDate = now.subtract(const Duration(days: 1));
        break;
      case TimePeriod.weekly:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.monthly:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case TimePeriod.yearly:
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case TimePeriod.allTime:
        return sessions;
    }

    return sessions.where((session) => session.date.isAfter(startDate)).toList();
  }

  List<ProgressMetric> _calculateVolumeMetrics(List<WorkoutSession> sessions) {
    final metrics = <ProgressMetric>[];

    for (final session in sessions) {
      double totalVolume = 0;
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          if (set.weight != null && set.reps != null) {
            totalVolume += set.weight! * set.reps!;
          }
        }
      }
      metrics.add(ProgressMetric(
        date: session.date,
        metricType: 'volume',
        value: totalVolume,
      ));
    }

    return metrics..sort((a, b) => a.date.compareTo(b.date));
  }

  List<ExerciseProgress> _calculateExerciseProgress(List<WorkoutSession> sessions) {
    final exerciseMap = <String, List<double>>{};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final exerciseName = exercise.exercise.name;
        exerciseMap.putIfAbsent(exerciseName, () => []);
        double maxWeight = 0;
        for (final set in exercise.sets) {
          if (set.weight != null && set.weight! > maxWeight) {
            maxWeight = set.weight!;
          }
        }
        if (maxWeight > 0) {
          exerciseMap[exerciseName]!.add(maxWeight);
        }
      }
    }

    final progress = <ExerciseProgress>[];
    for (final entry in exerciseMap.entries) {
      if (entry.value.isNotEmpty) {
        final sortedWeights = entry.value..sort();
        final startWeight = sortedWeights.first;
        final currentWeight = sortedWeights.last;
        final prCount = _countPRs(sortedWeights);

        progress.add(ExerciseProgress(
          exerciseName: entry.key,
          startWeight: startWeight,
          currentWeight: currentWeight,
          prCount: prCount,
        ));
      }
    }

    return progress..sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
  }

  int _countPRs(List<double> weights) {
    int prs = 0;
    double currentMax = 0;
    for (final weight in weights) {
      if (weight > currentMax) {
        currentMax = weight;
        prs++;
      }
    }
    return prs;
  }

  List<WorkoutFrequency> _calculateWorkoutFrequency(List<WorkoutSession> sessions) {
    final frequency = <WorkoutFrequency>[];
    final sessionDates = sessions.map((s) => s.date).toSet();

    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final completed = sessionDates.contains(DateTime(date.year, date.month, date.day));
      frequency.add(WorkoutFrequency(date: date, completed: completed));
    }

    return frequency;
  }

  // Note: The following aggregation methods are preserved for future use
  // but are not currently called from the provider
  /*
  // Aggregate daily data
  List<DailyProgressData> _aggregateDailyData(List<WorkoutSession> sessions) {
    final Map<DateTime, DailyProgressData> dailyMap = {};
    
    for (final session in sessions) {
      final date = DateTime(session.date.year, session.date.month, session.date.day);
      
      double volume = 0;
      int duration = 0;
      int caloriesBurned = 0;
      int exerciseCount = session.exercises.length;
      
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          if (set.weight != null && set.reps != null) {
            volume += set.weight! * set.reps!;
          }
          duration += ((set.duration as num?)?.toInt()) ?? 0;
        }
      }
      
      // Estimate calories (rough calculation: ~5 calories per kg lifted)
      caloriesBurned = (volume * 0.005).toInt();
      
      dailyMap[date] = DailyProgressData(
        date: date,
        volume: volume,
        duration: duration,
        caloriesBurned: caloriesBurned,
        exercises: exerciseCount,
      );
    }
    
    return dailyMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  // Aggregate weekly data
  List<WeeklyProgressData> _aggregateWeeklyData(List<DailyProgressData> dailyData) {
    final Map<int, WeeklyProgressData> weeklyMap = {};
    
    for (final daily in dailyData) {
      final weekOfYear = _getWeekOfYear(daily.date);
      
      if (!weeklyMap.containsKey(weekOfYear)) {
        weeklyMap[weekOfYear] = WeeklyProgressData(
          week: weekOfYear,
          totalVolume: 0,
          totalDuration: 0,
          totalCalories: 0,
          workoutDays: 0,
          dailyData: [],
        );
      }
      
      final week = weeklyMap[weekOfYear]!;
      weeklyMap[weekOfYear] = WeeklyProgressData(
        week: week.week,
        totalVolume: week.totalVolume + daily.volume,
        totalDuration: week.totalDuration + daily.duration,
        totalCalories: week.totalCalories + daily.caloriesBurned,
        workoutDays: week.workoutDays + 1,
        dailyData: [...week.dailyData, daily],
      );
    }
    
    return weeklyMap.values.toList()..sort((a, b) => a.week.compareTo(b.week));
  }

  // Aggregate monthly data
  List<MonthlyProgressData> _aggregateMonthlyData(List<WeeklyProgressData> weeklyData) {
    final Map<String, MonthlyProgressData> monthlyMap = {};
    
    for (final week in weeklyData) {
      if (week.dailyData.isEmpty) continue;
      
      final firstDay = week.dailyData.first.date;
      final monthKey = '${firstDay.year}-${firstDay.month}';
      
      if (!monthlyMap.containsKey(monthKey)) {
        monthlyMap[monthKey] = MonthlyProgressData(
          month: firstDay.month,
          year: firstDay.year,
          totalVolume: 0,
          totalDuration: 0,
          totalCalories: 0,
          workoutDays: 0,
          weeklyData: [],
        );
      }
      
      final month = monthlyMap[monthKey]!;
      monthlyMap[monthKey] = MonthlyProgressData(
        month: month.month,
        year: month.year,
        totalVolume: month.totalVolume + week.totalVolume,
        totalDuration: month.totalDuration + week.totalDuration,
        totalCalories: month.totalCalories + week.totalCalories,
        workoutDays: month.workoutDays + week.workoutDays,
        weeklyData: [...month.weeklyData, week],
      );
    }
    
    return monthlyMap.values.toList()
      ..sort((a, b) => a.year != b.year
          ? a.year.compareTo(b.year)
          : a.month.compareTo(b.month));
  }

  // Aggregate hourly data for today
  List<HourlyProgressData> _aggregateHourlyData(List<WorkoutSession> sessions) {
    final today = DateTime.now();
    final todaySessions = sessions.where((s) =>
        s.date.year == today.year &&
        s.date.month == today.month &&
        s.date.day == today.day).toList();
    
    final Map<int, HourlyProgressData> hourlyMap = {};
    
    for (int hour = 0; hour < 24; hour++) {
      hourlyMap[hour] = HourlyProgressData(
        hour: hour,
        volume: 0,
        duration: 0,
        caloriesBurned: 0,
      );
    }
    
    for (final session in todaySessions) {
      final hour = session.date.hour;
      final hourData = hourlyMap[hour] ?? HourlyProgressData(
        hour: hour,
        volume: 0,
        duration: 0,
        caloriesBurned: 0,
      );
      
      double volume = 0;
      int duration = 0;
      
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          if (set.weight != null && set.reps != null) {
            volume += set.weight! * set.reps!;
          }
          duration += ((set.duration as num?)?.toInt()) ?? 0;
        }
      }
      
      hourlyMap[hour] = HourlyProgressData(
        hour: hour,
        volume: hourData.volume + volume,
        duration: hourData.duration + duration,
        caloriesBurned: hourData.caloriesBurned + (volume * 0.005).toInt(),
      );
    }
    
    return hourlyMap.values.toList();
  }

  int _getWeekOfYear(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final dayOfWeek = jan4.weekday;
    final jan4WeekDate = jan4.subtract(Duration(days: dayOfWeek - 1));
    return ((date.difference(jan4WeekDate).inDays) / 7).ceil();
  }
  */

  Future<List<BodyPhoto>> _loadBodyPhotos() async {
    // TODO: Implement Firestore fetch for body photos
    // For now, return empty list
    return [];
  }

  void _cacheData() async {
    // TODO: Implement caching with SharedPreferences
  }

  // Statistics calculations
  int get totalWorkouts => state.workoutFrequency.where((f) => f.completed).length;

  double get totalVolume => state.volumeMetrics.fold(0, (sum, m) => sum + m.value);

  int get currentStreak {
    int streak = 0;
    for (final freq in state.workoutFrequency.reversed) {
      if (freq.completed) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  double get averageSessionDuration {
    // TODO: Calculate from session data
    return 45.0; // Placeholder
  }

  String get favoriteExercise {
    if (state.exerciseProgress.isEmpty) return 'None';
    return state.exerciseProgress.first.exerciseName;
  }

  double get bestMonthVolume {
    // TODO: Calculate monthly volumes
    return totalVolume; // Placeholder
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  throw UnimplementedError('SharedPreferences must be provided');
});

final progressProviderFamily = StateNotifierProvider.family<ProgressNotifier, ProgressState, SharedPreferences>((ref, prefs) {
  return ProgressNotifier();
});

// Helper provider to get SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be provided at app level');
});

// Combined provider
final progressCombinedProvider = StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  // final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressNotifier();
});
