import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../models/badge.dart';
import '../models/workout_session.dart';

class FirestoreException implements Exception {
  final String message;
  final String? code;

  FirestoreException(this.message, [this.code]);

  @override
  String toString() => message;
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastWorkoutDate;
  final List<DateTime> workoutDates;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastWorkoutDate,
    required this.workoutDates,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? (json['lastWorkoutDate'] as Timestamp).toDate()
          : DateTime.now(),
      workoutDates: (json['workoutDates'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastWorkoutDate': Timestamp.fromDate(lastWorkoutDate),
      'workoutDates': workoutDates.map((d) => Timestamp.fromDate(d)).toList(),
    };
  }
}

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  // ==================== User Profile ==================== //

  /// Create or update user profile
  Future<void> setUserProfile(UserProfile profile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw FirestoreException('User not authenticated');
      }

      await _firestore.collection('users').doc(userId).set(
            _userProfileToJson(profile),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw FirestoreException(
        'Failed to save user profile: ${e.toString()}',
      );
    }
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return _userProfileFromJson(doc.data()!, userId);
    } catch (e) {
      throw FirestoreException(
        'Failed to fetch user profile: ${e.toString()}',
      );
    }
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return getUserProfile(userId);
  }

  /// Stream user profile changes
  Stream<UserProfile?> watchUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map(
      (doc) {
        if (!doc.exists) return null;
        return _userProfileFromJson(doc.data()!, userId);
      },
    );
  }

  /// Update specific user profile fields
  Future<void> updateUserProfileFields(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw FirestoreException(
        'Failed to update user profile: ${e.toString()}',
      );
    }
  }

  // ==================== Streak Tracking ==================== //

  /// Get user's streak data
  Future<StreakData> getUserStreakData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tracking')
          .doc('streaks')
          .get();

      if (!doc.exists) {
        return StreakData(
          currentStreak: 0,
          longestStreak: 0,
          lastWorkoutDate: DateTime.now().subtract(const Duration(days: 100)),
          workoutDates: [],
        );
      }

      return StreakData.fromJson(doc.data()!);
    } catch (e) {
      throw FirestoreException(
        'Failed to fetch streak data: ${e.toString()}',
      );
    }
  }

  /// Update streak data
  Future<void> updateStreakData(String userId, StreakData streakData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tracking')
          .doc('streaks')
          .set(streakData.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException(
        'Failed to update streak data: ${e.toString()}',
      );
    }
  }

  /// Record a workout (for streak calculation)
  Future<void> recordWorkout(String userId, DateTime workoutDate) async {
    try {
      final streakData = await getUserStreakData(userId);
      final workoutDates = [...streakData.workoutDates];

      // Check if already recorded today
      final today = DateTime(
        workoutDate.year,
        workoutDate.month,
        workoutDate.day,
      );
      if (workoutDates.any((d) =>
          d.year == today.year && d.month == today.month && d.day == today.day)) {
        return; // Already recorded
      }

      workoutDates.add(today);
      workoutDates.sort();

      // Calculate streaks
      int currentStreak = 1;
      int longestStreak = 1;

      for (int i = workoutDates.length - 1; i > 0; i--) {
        final diff = workoutDates[i]
            .difference(workoutDates[i - 1])
            .inDays;
        if (diff == 1) {
          currentStreak++;
        } else {
          break;
        }
      }

      // Calculate longest streak
      int tempStreak = 1;
      for (int i = 0; i < workoutDates.length - 1; i++) {
        final diff = workoutDates[i + 1]
            .difference(workoutDates[i])
            .inDays;
        if (diff == 1) {
          tempStreak++;
          longestStreak = max(longestStreak, tempStreak);
        } else {
          tempStreak = 1;
        }
      }

      final newStreakData = StreakData(
        currentStreak: currentStreak,
        longestStreak: max(longestStreak, currentStreak),
        lastWorkoutDate: today,
        workoutDates: workoutDates,
      );

      await updateStreakData(userId, newStreakData);
    } catch (e) {
      throw FirestoreException(
        'Failed to record workout: ${e.toString()}',
      );
    }
  }

  // ==================== Badges ==================== //

  /// Get all badges for user
  Future<List<Badge>> getUserBadges(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .get();

      return querySnapshot.docs
          .map((doc) => Badge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        'Failed to fetch badges: ${e.toString()}',
      );
    }
  }

  /// Award badge to user
  Future<void> awardBadge(String userId, Badge badge) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc(badge.id)
          .set(badge.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException(
        'Failed to award badge: ${e.toString()}',
      );
    }
  }

  /// Update badge progress
  Future<void> updateBadgeProgress(
    String userId,
    String badgeId,
    int progress,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc(badgeId)
          .update({'currentProgress': progress});
    } catch (e) {
      throw FirestoreException(
        'Failed to update badge progress: ${e.toString()}',
      );
    }
  }

  /// Get available badges (global)
  Future<List<Badge>> getAvailableBadges() async {
    try {
      final querySnapshot =
          await _firestore.collection('badges').get();

      return querySnapshot.docs
          .map((doc) => Badge.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw FirestoreException(
        'Failed to fetch available badges: ${e.toString()}',
      );
    }
  }

  // ==================== Profile Images ==================== //

  /// Upload profile image
  Future<String> uploadProfileImage(
    String userId,
    File imageFile,
  ) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw FirestoreException(
          'Image file does not exist at path: ${imageFile.path}',
        );
      }

      // Validate file size (max 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw FirestoreException(
          'Image file is too large. Maximum size is 5MB.',
        );
      }

      final ref = _storage.ref().child('profiles/$userId/profile.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw FirestoreException(
        'Failed to upload profile image: ${e.toString()}',
      );
    }
  }

  /// Delete profile image
  Future<void> deleteProfileImage(String userId) async {
    try {
      final ref = _storage.ref().child('profiles/$userId/profile.jpg');
      await ref.delete();
    } catch (e) {
      throw FirestoreException(
        'Failed to delete profile image: ${e.toString()}',
      );
    }
  }

  // ==================== Workout Sessions ==================== //

  /// Save workout session
  Future<String> saveWorkoutSession(
    String userId,
    WorkoutSession session,
  ) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .add(session.toJson());
      return docRef.id;
    } catch (e) {
      throw FirestoreException(
        'Failed to save workout session: ${e.toString()}',
      );
    }
  }

  /// Get workout sessions
  Future<List<WorkoutSession>> getWorkoutSessions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts');

      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      query = query.orderBy('date', descending: true);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => WorkoutSession.fromJson(doc.data() as Map<String, dynamic>).copyWith(id: doc.id))
          .toList();
    } catch (e) {
      throw FirestoreException(
        'Failed to fetch workout sessions: ${e.toString()}',
      );
    }
  }

  /// Update workout session
  Future<void> updateWorkoutSession(
    String userId,
    String sessionId,
    WorkoutSession session,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(sessionId)
          .update(session.toJson());
    } catch (e) {
      throw FirestoreException(
        'Failed to update workout session: ${e.toString()}',
      );
    }
  }

  /// Delete workout session
  Future<void> deleteWorkoutSession(String userId, String sessionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .doc(sessionId)
          .delete();
    } catch (e) {
      throw FirestoreException(
        'Failed to delete workout session: ${e.toString()}',
      );
    }
  }

  // ==================== Helper Methods ==================== //

  Map<String, dynamic> _userProfileToJson(UserProfile profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'profileImageUrl': profile.profileImageUrl,
      'gender': profile.gender.toString().split('.').last,
      'dateOfBirth': profile.dateOfBirth != null
          ? Timestamp.fromDate(profile.dateOfBirth!)
          : null,
      'age': profile.age,
      'role': profile.role.toString().split('.').last,
      'height': profile.height,
      'weight': profile.weight,
      'bodyFatPercentage': profile.bodyFatPercentage,
      'muscleMass': profile.muscleMass,
      'bmi': profile.bmi,
      'primarySport': profile.primarySport,
      'secondarySports': profile.secondarySports,
      'experienceLevel': profile.experienceLevel.toString().split('.').last,
      'yearsTraining': profile.yearsTraining,
      'trainingGoals': profile.trainingGoals,
      'trainingFrequency': profile.trainingFrequency.toString().split('.').last,
      'sessionDuration': profile.sessionDuration.toString().split('.').last,
      'preferredTime': profile.preferredTime.toString().split('.').last,
      'equipmentLevel': profile.equipmentLevel.toString().split('.').last,
      'availableEquipment': profile.availableEquipment,
      'injuriesLimitations': profile.injuriesLimitations,
      'points': profile.points,
      'badges': profile.badges,
      'nextBadge': profile.nextBadge,
      'nextBadgeProgress': profile.nextBadgeProgress,
      'currentStreak': profile.currentStreak,
      'longestStreak': profile.longestStreak,
      'totalWorkouts': profile.totalWorkouts,
      'totalVolume': profile.totalVolume,
      'lastWorkoutDate': profile.lastWorkoutDate != null
          ? Timestamp.fromDate(profile.lastWorkoutDate!)
          : null,
      'notificationsEnabled': profile.notificationsEnabled,
      'darkModeEnabled': profile.darkModeEnabled,
      'weightUnit': profile.weightUnit,
      'heightUnit': profile.heightUnit,
      'createdAt': profile.createdAt != null
          ? Timestamp.fromDate(profile.createdAt!)
          : Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'onboardingCompleted': profile.onboardingCompleted,
    };
  }

  UserProfile _userProfileFromJson(Map<String, dynamic> json, String userId) {
    return UserProfile(
      id: json['id'] as String? ?? userId,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      gender: _parseGender(json['gender'] as String?),
      dateOfBirth: json['dateOfBirth'] != null
          ? (json['dateOfBirth'] as Timestamp).toDate()
          : null,
      age: json['age'] as int?,
      role: _parseUserRole(json['role'] as String?),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
      muscleMass: (json['muscleMass'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      primarySport: json['primarySport'] as String?,
      secondarySports:
          List<String>.from(json['secondarySports'] as List<dynamic>? ?? []),
      experienceLevel:
          _parseExperienceLevel(json['experienceLevel'] as String?),
      yearsTraining: json['yearsTraining'] as int?,
      trainingGoals:
          List<String>.from(json['trainingGoals'] as List<dynamic>? ?? []),
      trainingFrequency:
          _parseTrainingFrequency(json['trainingFrequency'] as String?),
      sessionDuration: _parseSessionDuration(json['sessionDuration'] as String?),
      preferredTime: _parsePreferredTime(json['preferredTime'] as String?),
      equipmentLevel:
          _parseEquipmentLevel(json['equipmentLevel'] as String?),
      availableEquipment:
          List<String>.from(json['availableEquipment'] as List<dynamic>? ?? []),
      injuriesLimitations: List<String>.from(
          json['injuriesLimitations'] as List<dynamic>? ?? []),
      points: json['points'] as int? ?? 0,
      badges: List<String>.from(json['badges'] as List<dynamic>? ?? []),
      nextBadge: json['nextBadge'] as String?,
      nextBadgeProgress: json['nextBadgeProgress'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalWorkouts: json['totalWorkouts'] as int? ?? 0,
      totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0.0,
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? (json['lastWorkoutDate'] as Timestamp).toDate()
          : null,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      weightUnit: json['weightUnit'] as String? ?? 'kg',
      heightUnit: json['heightUnit'] as String? ?? 'cm',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }

  Gender _parseGender(String? value) {
    switch (value?.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      default:
        return Gender.other;
    }
  }

  UserRole _parseUserRole(String? value) {
    switch (value?.toLowerCase()) {
      case 'athlete':
        return UserRole.athlete;
      case 'coach':
        return UserRole.coach;
      default:
        return UserRole.athlete;
    }
  }

  ExperienceLevel _parseExperienceLevel(String? value) {
    switch (value?.toLowerCase()) {
      case 'beginner':
        return ExperienceLevel.beginner;
      case 'novice':
        return ExperienceLevel.novice;
      case 'intermediate':
        return ExperienceLevel.intermediate;
      case 'advanced':
        return ExperienceLevel.advanced;
      case 'elite':
        return ExperienceLevel.elite;
      default:
        return ExperienceLevel.beginner;
    }
  }

  TrainingFrequency _parseTrainingFrequency(String? value) {
    switch (value?.toLowerCase()) {
      case 'oneday':
        return TrainingFrequency.oneDay;
      case 'twodays':
        return TrainingFrequency.twoDays;
      case 'threedays':
        return TrainingFrequency.threeDays;
      case 'fourdays':
        return TrainingFrequency.fourDays;
      case 'fivedays':
        return TrainingFrequency.fiveDays;
      case 'sixdays':
        return TrainingFrequency.sixDays;
      case 'sevendays':
        return TrainingFrequency.sevenDays;
      default:
        return TrainingFrequency.threeDays;
    }
  }

  SessionDuration _parseSessionDuration(String? value) {
    switch (value?.toLowerCase()) {
      case 'thirtymin':
        return SessionDuration.thirtyMin;
      case 'fortyfivemin':
        return SessionDuration.fortyFiveMin;
      case 'sixtymin':
        return SessionDuration.sixtyMin;
      case 'ninetymin':
        return SessionDuration.ninetyMin;
      default:
        return SessionDuration.sixtyMin;
    }
  }

  PreferredTime _parsePreferredTime(String? value) {
    switch (value?.toLowerCase()) {
      case 'morning':
        return PreferredTime.morning;
      case 'afternoon':
        return PreferredTime.afternoon;
      case 'evening':
        return PreferredTime.evening;
      default:
        return PreferredTime.morning;
    }
  }

  EquipmentLevel _parseEquipmentLevel(String? value) {
    switch (value?.toLowerCase()) {
      case 'none':
        return EquipmentLevel.none;
      case 'minimal':
        return EquipmentLevel.minimal;
      case 'homegym':
        return EquipmentLevel.homeGym;
      case 'fullgym':
        return EquipmentLevel.fullGym;
      default:
        return EquipmentLevel.none;
    }
  }
}

// Helper function for max
int max(int a, int b) => a > b ? a : b;
