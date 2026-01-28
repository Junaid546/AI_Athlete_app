/// Common utilities for the app
library;

import 'package:flutter/foundation.dart';
import '../models/workout_session.dart';

void appDebugPrint(String tag, String message) {
  debugPrint('[$tag] $message');
}

/// Calculate the current streak from workout sessions
int calculateCurrentStreak(List<WorkoutSession> sessions) {
  if (sessions.isEmpty) return 0;

  try {
    final sessionsByDate = <DateTime, int>{};
    for (final session in sessions) {
      final date = DateTime(session.date.year, session.date.month, session.date.day);
      sessionsByDate[date] = (sessionsByDate[date] ?? 0) + 1;
    }

    int streak = 0;
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    bool hasWorkoutToday = sessionsByDate.containsKey(normalizedToday);
    bool hasWorkoutYesterday = sessionsByDate.containsKey(normalizedToday.subtract(const Duration(days: 1)));

    if (!hasWorkoutToday && !hasWorkoutYesterday) {
      return 0;
    }

    for (int i = 0; i < 366; i++) {
      final checkDate = normalizedToday.subtract(Duration(days: i));
      if (sessionsByDate.containsKey(checkDate)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  } catch (e) {
    return 0;
  }
}

/// Calculate the longest streak from workout sessions
int calculateLongestStreak(List<WorkoutSession> sessions) {
  if (sessions.isEmpty) return 0;

  try {
    final sessionsByDate = <DateTime, int>{};
    for (final session in sessions) {
      final date = DateTime(session.date.year, session.date.month, session.date.day);
      sessionsByDate[date] = (sessionsByDate[date] ?? 0) + 1;
    }

    final sortedDates = sessionsByDate.keys.toList()..sort();
    if (sortedDates.isEmpty) return 0;

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final dayDiff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (dayDiff == 1) {
        currentStreak++;
        longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  } catch (e) {
    return 0;
  }
}
