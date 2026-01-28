import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../providers/user_profile_provider_firebase.dart';

/// Manages user streak tracking
class StreakNotifier extends StateNotifier<StreakData?> {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  final String userId;

  StreakNotifier(
    this._firestoreService,
    this._authService,
    this.userId,
  ) : super(null) {
    _loadStreakData();
  }

  /// Load streak data from Firestore
  Future<void> _loadStreakData() async {
    try {
      final streakData = await _firestoreService.getUserStreakData(userId);
      state = streakData;
    } catch (e) {
    debugPrint('Error loading streak data: $e');
    }
  }

  /// Record a workout and update streaks
  Future<void> recordWorkout({
    required DateTime workoutDate,
    required int totalWorkouts,
    required double totalVolume,
  }) async {
    try {
      // Record the workout in Firestore
      await _firestoreService.recordWorkout(userId, workoutDate);

      // Reload streak data
      await _loadStreakData();

      // Update user profile with new streak and workout stats
      final userProfileNotifier = _authService.currentUser != null
          ? UserProfileNotifier(_firestoreService, _authService)
          : null;

      if (userProfileNotifier != null && state != null) {
        await userProfileNotifier.updateStreaks(
          state!.currentStreak,
          state!.longestStreak,
        );
        await userProfileNotifier.updateTotalWorkouts(totalWorkouts);
        await userProfileNotifier.updateTotalVolume(totalVolume);
        await userProfileNotifier.updateLastWorkoutDate(workoutDate);
      }
    } catch (e) {
    debugPrint('Error recording workout: $e');
      rethrow;
    }
  }

  /// Check if there's an active streak (worked out today or yesterday)
  bool get hasActiveStreak {
    if (state == null || state!.workoutDates.isEmpty) {
      return false;
    }

    final today = DateTime.now();

    final lastWorkout = state!.lastWorkoutDate;
    final daysDiff = today.difference(lastWorkout).inDays;

    return daysDiff <= 1;
  }

  /// Get days until streak is lost
  int get daysUntilStreakLost {
    if (!hasActiveStreak) {
      return 0;
    }

    final today = DateTime.now();
    final lastWorkout = state!.lastWorkoutDate;
    final daysDiff = today.difference(lastWorkout).inDays;

    return 2 - daysDiff; // 2 days - days already passed
  }
}

/// Provider for streak data
final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakData?>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser == null) {
    return StreakNotifier(firestoreService, authService, '');
  }

  return StreakNotifier(firestoreService, authService, currentUser.uid);
});
