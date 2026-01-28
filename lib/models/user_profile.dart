
enum UserRole { athlete, coach }

enum Gender { male, female, other }

enum ExperienceLevel { beginner, novice, intermediate, advanced, elite }

enum TrainingFrequency { oneDay, twoDays, threeDays, fourDays, fiveDays, sixDays, sevenDays }

enum SessionDuration { thirtyMin, fortyFiveMin, sixtyMin, ninetyMin }

enum PreferredTime { morning, afternoon, evening }

enum EquipmentLevel { none, minimal, homeGym, fullGym }

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final Gender gender;
  final DateTime? dateOfBirth;
  final int? age; // Calculated from dateOfBirth
  final UserRole role;

  // Body metrics
  final double? height; // in cm
  final double? weight; // in kg
  final double? bodyFatPercentage;
  final double? muscleMass;
  final double? bmi; // Calculated

  // Training profile
  final String? primarySport;
  final List<String> secondarySports;
  final ExperienceLevel experienceLevel;
  final int? yearsTraining;
  final List<String> trainingGoals;
  final TrainingFrequency trainingFrequency;
  final SessionDuration sessionDuration;
  final PreferredTime preferredTime;
  final EquipmentLevel equipmentLevel;
  final List<String> availableEquipment;
  final List<String> injuriesLimitations;

  // Progress & achievements
  final int points;
  final List<String> badges;
  final String? nextBadge;
  final int nextBadgeProgress;
  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;
  final double totalVolume; // kg lifted
  final DateTime? lastWorkoutDate;

  // Preferences
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String weightUnit; // 'kg' or 'lbs'
  final String heightUnit; // 'cm' or 'ft'

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool onboardingCompleted;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.gender,
    this.dateOfBirth,
    this.age,
    required this.role,
    this.height,
    this.weight,
    this.bodyFatPercentage,
    this.muscleMass,
    this.bmi,
    this.primarySport,
    this.secondarySports = const [],
    required this.experienceLevel,
    this.yearsTraining,
    this.trainingGoals = const [],
    required this.trainingFrequency,
    required this.sessionDuration,
    required this.preferredTime,
    required this.equipmentLevel,
    this.availableEquipment = const [],
    this.injuriesLimitations = const [],
    this.points = 0,
    this.badges = const [],
    this.nextBadge,
    this.nextBadgeProgress = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWorkouts = 0,
    this.totalVolume = 0.0,
    this.lastWorkoutDate,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.weightUnit = 'kg',
    this.heightUnit = 'cm',
    this.createdAt,
    this.updatedAt,
    this.onboardingCompleted = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    Gender? gender,
    DateTime? dateOfBirth,
    int? age,
    UserRole? role,
    double? height,
    double? weight,
    double? bodyFatPercentage,
    double? muscleMass,
    double? bmi,
    String? primarySport,
    List<String>? secondarySports,
    ExperienceLevel? experienceLevel,
    int? yearsTraining,
    List<String>? trainingGoals,
    TrainingFrequency? trainingFrequency,
    SessionDuration? sessionDuration,
    PreferredTime? preferredTime,
    EquipmentLevel? equipmentLevel,
    List<String>? availableEquipment,
    List<String>? injuriesLimitations,
    int? points,
    List<String>? badges,
    String? nextBadge,
    int? nextBadgeProgress,
    int? currentStreak,
    int? longestStreak,
    int? totalWorkouts,
    double? totalVolume,
    DateTime? lastWorkoutDate,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? weightUnit,
    String? heightUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      role: role ?? this.role,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMass: muscleMass ?? this.muscleMass,
      bmi: bmi ?? this.bmi,
      primarySport: primarySport ?? this.primarySport,
      secondarySports: secondarySports ?? this.secondarySports,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      yearsTraining: yearsTraining ?? this.yearsTraining,
      trainingGoals: trainingGoals ?? this.trainingGoals,
      trainingFrequency: trainingFrequency ?? this.trainingFrequency,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      preferredTime: preferredTime ?? this.preferredTime,
      equipmentLevel: equipmentLevel ?? this.equipmentLevel,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      injuriesLimitations: injuriesLimitations ?? this.injuriesLimitations,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      nextBadge: nextBadge ?? this.nextBadge,
      nextBadgeProgress: nextBadgeProgress ?? this.nextBadgeProgress,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalVolume: totalVolume ?? this.totalVolume,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'gender': gender.name,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'age': age,
      'role': role.name,
      'height': height,
      'weight': weight,
      'bodyFatPercentage': bodyFatPercentage,
      'muscleMass': muscleMass,
      'bmi': bmi,
      'primarySport': primarySport,
      'secondarySports': secondarySports,
      'experienceLevel': experienceLevel.name,
      'yearsTraining': yearsTraining,
      'trainingGoals': trainingGoals,
      'trainingFrequency': trainingFrequency.name,
      'sessionDuration': sessionDuration.name,
      'preferredTime': preferredTime.name,
      'equipmentLevel': equipmentLevel.name,
      'availableEquipment': availableEquipment,
      'injuriesLimitations': injuriesLimitations,
      'points': points,
      'badges': badges,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalWorkouts': totalWorkouts,
      'totalVolume': totalVolume,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'weightUnit': weightUnit,
      'heightUnit': heightUnit,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'onboardingCompleted': onboardingCompleted,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profileImageUrl'],
      gender: Gender.values.firstWhere((e) => e.name == json['gender']),
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      age: json['age'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      bodyFatPercentage: json['bodyFatPercentage']?.toDouble(),
      muscleMass: json['muscleMass']?.toDouble(),
      bmi: json['bmi']?.toDouble(),
      primarySport: json['primarySport'],
      secondarySports: List<String>.from(json['secondarySports'] ?? []),
      experienceLevel: ExperienceLevel.values.firstWhere((e) => e.name == json['experienceLevel']),
      yearsTraining: json['yearsTraining'],
      trainingGoals: List<String>.from(json['trainingGoals'] ?? []),
      trainingFrequency: TrainingFrequency.values.firstWhere((e) => e.name == json['trainingFrequency']),
      sessionDuration: SessionDuration.values.firstWhere((e) => e.name == json['sessionDuration']),
      preferredTime: PreferredTime.values.firstWhere((e) => e.name == json['preferredTime']),
      equipmentLevel: EquipmentLevel.values.firstWhere((e) => e.name == json['equipmentLevel']),
      availableEquipment: List<String>.from(json['availableEquipment'] ?? []),
      injuriesLimitations: List<String>.from(json['injuriesLimitations'] ?? []),
      points: json['points'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalVolume: json['totalVolume']?.toDouble() ?? 0.0,
      lastWorkoutDate: json['lastWorkoutDate'] != null ? DateTime.parse(json['lastWorkoutDate']) : null,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      darkModeEnabled: json['darkModeEnabled'] ?? false,
      weightUnit: json['weightUnit'] ?? 'kg',
      heightUnit: json['heightUnit'] ?? 'cm',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
    );
  }

  // Legacy getters for backward compatibility
  String? get sport => primarySport;
  String? get goal => trainingGoals.isNotEmpty ? trainingGoals.first : null;

  // Helper methods
  int get calculatedAge {
    if (dateOfBirth == null) return age ?? 0;
    final now = DateTime.now();
    int calculatedAge = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  double? get calculatedBMI {
    if (height == null || weight == null || height == 0) return null;
    return weight! / ((height! / 100) * (height! / 100));
  }

  String get displayWeight {
    if (weight == null) return '--';
    return '${weight!.toStringAsFixed(1)} $weightUnit';
  }

  String get displayHeight {
    if (height == null) return '--';
    if (heightUnit == 'cm') {
      return '${height!.toInt()} cm';
    } else {
      final feet = height! ~/ 30.48;
      final inches = ((height! % 30.48) / 2.54).round();
      return '$feet\'$inches"';
    }
  }

  bool get hasActiveStreak {
    if (lastWorkoutDate == null) return false;
    final daysSinceLastWorkout = DateTime.now().difference(lastWorkoutDate!).inDays;
    return daysSinceLastWorkout <= 1; // Allow 1 day gap for streak
  }
}
