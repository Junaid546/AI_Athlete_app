import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  UserProfileNotifier(this._firestoreService, this._authService) : super(null) {
    _loadCurrentUserProfile();
  }

  /// Load the current authenticated user's profile from Firestore
  Future<void> _loadCurrentUserProfile() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        state = null;
        return;
      }

      final profile = await _firestoreService.getCurrentUserProfile();
      if (profile != null) {
        state = profile;
      } else {
        // Create default profile for new user
        final newProfile = _createDefaultProfile(currentUser);
        await setProfile(newProfile);
      }
    } catch (e) {
    debugPrint('Error loading user profile: $e');
      state = null;
    }
  }

  /// Create a default profile for a newly authenticated user
  static UserProfile _createDefaultProfile(User firebaseUser) {
    return UserProfile(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      profileImageUrl: firebaseUser.photoURL,
      gender: Gender.other,
      role: UserRole.athlete,
      experienceLevel: ExperienceLevel.beginner,
      trainingFrequency: TrainingFrequency.threeDays,
      sessionDuration: SessionDuration.sixtyMin,
      preferredTime: PreferredTime.morning,
      equipmentLevel: EquipmentLevel.none,
      points: 0,
      badges: [],
      currentStreak: 0,
      longestStreak: 0,
      totalWorkouts: 0,
      totalVolume: 0.0,
      notificationsEnabled: true,
      darkModeEnabled: false,
      weightUnit: 'kg',
      heightUnit: 'cm',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      onboardingCompleted: false,
    );
  }

  /// Set/save the entire user profile
  Future<void> setProfile(UserProfile profile) async {
    try {
      await _firestoreService.setUserProfile(profile);
      state = profile;
    } catch (e) {
    debugPrint('Error setting profile: $e');
      rethrow;
    }
  }

  /// Update the user profile
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _firestoreService.setUserProfile(profile);
      state = profile;
    } catch (e) {
    debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  /// Update specific profile fields
  Future<void> updateProfileField(String field, dynamic value) async {
    if (state == null) return;
    try {
      final userId = state!.id;
      await _firestoreService.updateUserProfileFields(userId, {field: value});
      
      // Update local state
      state = state!.copyWith();
      // Re-fetch to ensure sync
      await _loadCurrentUserProfile();
    } catch (e) {
    debugPrint('Error updating field $field: $e');
      rethrow;
    }
  }

  /// Refresh the user profile from Firestore
  Future<void> refreshProfile() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        state = null;
        return;
      }

      final profile = await _firestoreService.getUserProfile(currentUser.uid);
      state = profile;
    } catch (e) {
    debugPrint('Error refreshing profile: $e');
      rethrow;
    }
  }

  /// Update profile image URL
  Future<void> updateProfileImageUrl(String imageUrl) async {
    if (state == null) return;
    try {
      await updateProfileField('profileImageUrl', imageUrl);
    } catch (e) {
    debugPrint('Error updating profile image: $e');
      rethrow;
    }
  }

  /// Update streak information
  Future<void> updateStreaks(int currentStreak, int longestStreak) async {
    if (state == null) return;
    try {
      final userId = state!.id;
      await _firestoreService.updateUserProfileFields(userId, {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      });
      state = state!.copyWith(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );
    } catch (e) {
    debugPrint('Error updating streaks: $e');
      rethrow;
    }
  }

  /// Update badge information
  Future<void> updateBadges(List<String> badgeIds, {String? nextBadge, int? nextProgress}) async {
    if (state == null) return;
    try {
      final userId = state!.id;
      await _firestoreService.updateUserProfileFields(userId, {
        'badges': badgeIds,
        if (nextBadge != null) 'nextBadge': nextBadge,
        if (nextProgress != null) 'nextBadgeProgress': nextProgress,
      });
      state = state!.copyWith(
        badges: badgeIds,
        nextBadge: nextBadge,
        nextBadgeProgress: nextProgress,
      );
    } catch (e) {
    debugPrint('Error updating badges: $e');
      rethrow;
    }
  }

  /// Update points
  Future<void> updatePoints(int newPoints) async {
    if (state == null) return;
    try {
      await updateProfileField('points', newPoints);
    } catch (e) {
    debugPrint('Error updating points: $e');
      rethrow;
    }
  }

  /// Update total workouts count
  Future<void> updateTotalWorkouts(int count) async {
    if (state == null) return;
    try {
      await updateProfileField('totalWorkouts', count);
    } catch (e) {
    debugPrint('Error updating workouts: $e');
      rethrow;
    }
  }

  /// Update total volume
  Future<void> updateTotalVolume(double volume) async {
    if (state == null) return;
    try {
      await updateProfileField('totalVolume', volume);
    } catch (e) {
    debugPrint('Error updating total volume: $e');
      rethrow;
    }
  }

  /// Update last workout date
  Future<void> updateLastWorkoutDate(DateTime date) async {
    if (state == null) return;
    try {
      await updateProfileField('lastWorkoutDate', date.toIso8601String());
    } catch (e) {
    debugPrint('Error updating last workout date: $e');
      rethrow;
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    if (state == null) return;
    try {
      await updateProfileField('onboardingCompleted', true);
    } catch (e) {
    debugPrint('Error completing onboarding: $e');
      rethrow;
    }
  }

  /// Reload profile when authentication state changes
  void handleAuthStateChange(User? user) {
    if (user == null) {
      state = null;
    } else {
      _loadCurrentUserProfile();
    }
  }
}

// Provider for FirestoreService
final firestoreServiceProvider = Provider((ref) {
  return FirestoreService();
});

// Provider for AuthService
final authServiceProvider = Provider((ref) {
  return AuthService();
});

// State notifier provider for user profile with Firestore backing
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  
  return UserProfileNotifier(firestoreService, authService);
});

// Watch auth state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Stream provider for watching user profile changes in real-time
final userProfileStreamProvider = StreamProvider((ref) {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  final currentUser = authService.currentUser;
  if (currentUser == null) {
    return const Stream.empty();
  }

  return firestoreService.watchUserProfile(currentUser.uid);
});

// Add debug printing - using print to avoid conflicts

