import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge.dart';
import '../services/firestore_service.dart';

import '../providers/user_profile_provider_firebase.dart';

/// Badge achievement data
class BadgeAchievementData {
  final List<Badge> unlockedBadges;
  final List<Badge> lockedBadges;
  final Badge? nextBadge;
  final int nextBadgeProgress;

  BadgeAchievementData({
    required this.unlockedBadges,
    required this.lockedBadges,
    this.nextBadge,
    this.nextBadgeProgress = 0,
  });
}

/// Manages badge achievements
class BadgeNotifier extends StateNotifier<BadgeAchievementData?> {
  final FirestoreService _firestoreService;
  final String userId;

  BadgeNotifier(
    this._firestoreService,
    this.userId,
  ) : super(null) {
    _loadBadges();
  }

  /// Load all badges and calculate achievements
  Future<void> _loadBadges() async {
    try {
      final userBadges = await _firestoreService.getUserBadges(userId);
      final availableBadges = await _firestoreService.getAvailableBadges();

      final unlockedBadges =
          userBadges.where((b) => b.isUnlocked).toList();
      final lockedBadges = availableBadges
          .where((b) =>
              !userBadges.any((ub) => ub.id == b.id) ||
              userBadges.firstWhere((ub) => ub.id == b.id).isUnlocked == false)
          .toList();

      // Find next badge to unlock
      Badge? nextBadge;
      int nextBadgeProgress = 0;

      if (lockedBadges.isNotEmpty) {
        nextBadge = lockedBadges.first;
        final userBadge = userBadges.firstWhere(
          (b) => b.id == nextBadge!.id,
          orElse: () => nextBadge!,
        );
        nextBadgeProgress =
            ((userBadge.currentProgress / userBadge.requirementValue) * 100)
                .toInt()
                .clamp(0, 100);
      }

      state = BadgeAchievementData(
        unlockedBadges: unlockedBadges,
        lockedBadges: lockedBadges,
        nextBadge: nextBadge,
        nextBadgeProgress: nextBadgeProgress,
      );
    } catch (e) {
    debugPrint('Error loading badges: $e');
    }
  }

  /// Award a badge to the user
  Future<void> awardBadge(Badge badge) async {
    try {
      final unlockedBadge = badge.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      await _firestoreService.awardBadge(userId, unlockedBadge);

      // Update user profile badges
      final currentBadges = state?.unlockedBadges.map((b) => b.id).toList() ?? [];
      if (!currentBadges.contains(badge.id)) {
        currentBadges.add(badge.id);
        // Update in user profile
      }

      // Reload badges
      await _loadBadges();
    } catch (e) {
    debugPrint('Error awarding badge: $e');
      rethrow;
    }
  }

  /// Update badge progress
  Future<void> updateBadgeProgress(
    String badgeId,
    int currentProgress,
  ) async {
    try {
      await _firestoreService.updateBadgeProgress(userId, badgeId, currentProgress);

      // Check if badge should be unlocked
      final badge = state?.lockedBadges.firstWhere(
        (b) => b.id == badgeId,
        orElse: () => state!.unlockedBadges.firstWhere(
          (b) => b.id == badgeId,
          orElse: () => Badge(
            id: '',
            name: '',
            description: '',
            icon: '',
            category: '',
            requirementValue: 0,
            requirementType: '',
            isUnlocked: false,
            currentProgress: 0,
            unlockCriteria: '',
          ),
        ),
      );

      if (badge != null && !badge.isUnlocked && currentProgress >= badge.requirementValue) {
        await awardBadge(badge);
      } else {
        // Just reload to update progress
        await _loadBadges();
      }
    } catch (e) {
    debugPrint('Error updating badge progress: $e');
      rethrow;
    }
  }

  /// Get badge by ID
  Badge? getBadgeById(String badgeId) {
    if (state == null) return null;

    try {
      return state!.unlockedBadges.firstWhere((b) => b.id == badgeId);
    } catch (e) {
      try {
        return state!.lockedBadges.firstWhere((b) => b.id == badgeId);
      } catch (e) {
        return null;
      }
    }
  }

  /// Check specific achievement criteria
  void checkAchievements({
    required int totalWorkouts,
    required int currentStreak,
    required double totalVolume,
    required int points,
  }) {
    if (state == null) return;

    // Unlock badges based on criteria
    for (final badge in state!.lockedBadges) {
      int progress = 0;

      switch (badge.requirementType) {
        case 'workouts':
          progress = totalWorkouts;
          break;
        case 'streak':
          progress = currentStreak;
          break;
        case 'volume':
          progress = totalVolume.toInt();
          break;
        case 'points':
          progress = points;
          break;
      }

      // Update progress
      if (progress > 0) {
        updateBadgeProgress(badge.id, progress);
      }
    }
  }
}

/// Provider for badge achievements
final badgeProvider =
    StateNotifierProvider<BadgeNotifier, BadgeAchievementData?>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser == null) {
    return BadgeNotifier(firestoreService, '');
  }

  return BadgeNotifier(firestoreService, currentUser.uid);
});
