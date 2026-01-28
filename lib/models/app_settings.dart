import 'package:flutter/material.dart';
enum AccentColor { purple, blue, green, red, yellow, custom }
enum Language {
  englishUS,
  englishUK,
  spanish,
  french,
  german,
  italian,
  portuguese,
  chinese,
  japanese,
  korean,
  arabic,
  hindi;

  String getLanguageDisplayName() {
    switch (this) {
      case Language.englishUS:
        return 'English (US)';
      case Language.englishUK:
        return 'English (UK)';
      case Language.spanish:
        return 'Español';
      case Language.french:
        return 'Français';
      case Language.german:
        return 'Deutsch';
      case Language.italian:
        return 'Italiano';
      case Language.portuguese:
        return 'Português';
      case Language.chinese:
        return '中文';
      case Language.japanese:
        return '日本語';
      case Language.korean:
        return '한국어';
      case Language.arabic:
        return 'العربية';
      case Language.hindi:
        return 'हिन्दी';
    }
  }
}
enum NotificationSound { defaultSound, none }

class NotificationSettings {
  final bool pushNotifications;
  final bool workoutReminders;
  final TimeOfDay workoutReminderTime;
  final bool streakAlerts;
  final bool aiInsights;
  final bool achievementUnlocks;
  final bool coachMessages;
  final bool prCelebrations;
  final bool socialUpdates;
  final bool emailNotifications;
  final NotificationSound notificationSound;
  final TimeOfDay doNotDisturbStart;
  final TimeOfDay doNotDisturbEnd;

  const NotificationSettings({
    this.pushNotifications = true,
    this.workoutReminders = true,
    this.workoutReminderTime = const TimeOfDay(hour: 9, minute: 0),
    this.streakAlerts = true,
    this.aiInsights = true,
    this.achievementUnlocks = true,
    this.coachMessages = true,
    this.prCelebrations = true,
    this.socialUpdates = false,
    this.emailNotifications = false,
    this.notificationSound = NotificationSound.defaultSound,
    this.doNotDisturbStart = const TimeOfDay(hour: 22, minute: 0),
    this.doNotDisturbEnd = const TimeOfDay(hour: 7, minute: 0),
  });

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? workoutReminders,
    TimeOfDay? workoutReminderTime,
    bool? streakAlerts,
    bool? aiInsights,
    bool? achievementUnlocks,
    bool? coachMessages,
    bool? prCelebrations,
    bool? socialUpdates,
    bool? emailNotifications,
    NotificationSound? notificationSound,
    TimeOfDay? doNotDisturbStart,
    TimeOfDay? doNotDisturbEnd,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      workoutReminderTime: workoutReminderTime ?? this.workoutReminderTime,
      streakAlerts: streakAlerts ?? this.streakAlerts,
      aiInsights: aiInsights ?? this.aiInsights,
      achievementUnlocks: achievementUnlocks ?? this.achievementUnlocks,
      coachMessages: coachMessages ?? this.coachMessages,
      prCelebrations: prCelebrations ?? this.prCelebrations,
      socialUpdates: socialUpdates ?? this.socialUpdates,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      notificationSound: notificationSound ?? this.notificationSound,
      doNotDisturbStart: doNotDisturbStart ?? this.doNotDisturbStart,
      doNotDisturbEnd: doNotDisturbEnd ?? this.doNotDisturbEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'workoutReminders': workoutReminders,
      'workoutReminderTime': '${workoutReminderTime.hour}:${workoutReminderTime.minute}',
      'streakAlerts': streakAlerts,
      'aiInsights': aiInsights,
      'achievementUnlocks': achievementUnlocks,
      'coachMessages': coachMessages,
      'prCelebrations': prCelebrations,
      'socialUpdates': socialUpdates,
      'emailNotifications': emailNotifications,
      'notificationSound': notificationSound.name,
      'doNotDisturbStart': '${doNotDisturbStart.hour}:${doNotDisturbStart.minute}',
      'doNotDisturbEnd': '${doNotDisturbEnd.hour}:${doNotDisturbEnd.minute}',
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['pushNotifications'] ?? true,
      workoutReminders: json['workoutReminders'] ?? true,
      workoutReminderTime: _parseTimeOfDay(json['workoutReminderTime'] ?? '9:0'),
      streakAlerts: json['streakAlerts'] ?? true,
      aiInsights: json['aiInsights'] ?? true,
      achievementUnlocks: json['achievementUnlocks'] ?? true,
      coachMessages: json['coachMessages'] ?? true,
      prCelebrations: json['prCelebrations'] ?? true,
      socialUpdates: json['socialUpdates'] ?? false,
      emailNotifications: json['emailNotifications'] ?? false,
      notificationSound: NotificationSound.values.firstWhere(
        (e) => e.name == json['notificationSound'],
        orElse: () => NotificationSound.defaultSound,
      ),
      doNotDisturbStart: _parseTimeOfDay(json['doNotDisturbStart'] ?? '22:0'),
      doNotDisturbEnd: _parseTimeOfDay(json['doNotDisturbEnd'] ?? '7:0'),
    );
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class TrainingPreferences {
  final String defaultWeightUnit;
  final String defaultDistanceUnit;
  final Duration strengthRestTimer;
  final Duration hypertrophyRestTimer;
  final Duration enduranceRestTimer;
  final bool autoStartRestTimer;
  final bool restTimerSound;
  final bool vibrationFeedback;
  final bool voiceGuidance;
  final bool keepScreenOn;
  final bool showExerciseVideos;
  final List<String> connectedMusicServices;

  const TrainingPreferences({
    this.defaultWeightUnit = 'kg',
    this.defaultDistanceUnit = 'km',
    this.strengthRestTimer = const Duration(minutes: 3),
    this.hypertrophyRestTimer = const Duration(minutes: 1, seconds: 30),
    this.enduranceRestTimer = const Duration(seconds: 45),
    this.autoStartRestTimer = true,
    this.restTimerSound = true,
    this.vibrationFeedback = true,
    this.voiceGuidance = false,
    this.keepScreenOn = true,
    this.showExerciseVideos = true,
    this.connectedMusicServices = const [],
  });

  TrainingPreferences copyWith({
    String? defaultWeightUnit,
    String? defaultDistanceUnit,
    Duration? strengthRestTimer,
    Duration? hypertrophyRestTimer,
    Duration? enduranceRestTimer,
    bool? autoStartRestTimer,
    bool? restTimerSound,
    bool? vibrationFeedback,
    bool? voiceGuidance,
    bool? keepScreenOn,
    bool? showExerciseVideos,
    List<String>? connectedMusicServices,
  }) {
    return TrainingPreferences(
      defaultWeightUnit: defaultWeightUnit ?? this.defaultWeightUnit,
      defaultDistanceUnit: defaultDistanceUnit ?? this.defaultDistanceUnit,
      strengthRestTimer: strengthRestTimer ?? this.strengthRestTimer,
      hypertrophyRestTimer: hypertrophyRestTimer ?? this.hypertrophyRestTimer,
      enduranceRestTimer: enduranceRestTimer ?? this.enduranceRestTimer,
      autoStartRestTimer: autoStartRestTimer ?? this.autoStartRestTimer,
      restTimerSound: restTimerSound ?? this.restTimerSound,
      vibrationFeedback: vibrationFeedback ?? this.vibrationFeedback,
      voiceGuidance: voiceGuidance ?? this.voiceGuidance,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      showExerciseVideos: showExerciseVideos ?? this.showExerciseVideos,
      connectedMusicServices: connectedMusicServices ?? this.connectedMusicServices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultWeightUnit': defaultWeightUnit,
      'defaultDistanceUnit': defaultDistanceUnit,
      'strengthRestTimer': strengthRestTimer.inSeconds,
      'hypertrophyRestTimer': hypertrophyRestTimer.inSeconds,
      'enduranceRestTimer': enduranceRestTimer.inSeconds,
      'autoStartRestTimer': autoStartRestTimer,
      'restTimerSound': restTimerSound,
      'vibrationFeedback': vibrationFeedback,
      'voiceGuidance': voiceGuidance,
      'keepScreenOn': keepScreenOn,
      'showExerciseVideos': showExerciseVideos,
      'connectedMusicServices': connectedMusicServices,
    };
  }

  factory TrainingPreferences.fromJson(Map<String, dynamic> json) {
    return TrainingPreferences(
      defaultWeightUnit: json['defaultWeightUnit'] ?? 'kg',
      defaultDistanceUnit: json['defaultDistanceUnit'] ?? 'km',
      strengthRestTimer: Duration(seconds: json['strengthRestTimer'] ?? 180),
      hypertrophyRestTimer: Duration(seconds: json['hypertrophyRestTimer'] ?? 90),
      enduranceRestTimer: Duration(seconds: json['enduranceRestTimer'] ?? 45),
      autoStartRestTimer: json['autoStartRestTimer'] ?? true,
      restTimerSound: json['restTimerSound'] ?? true,
      vibrationFeedback: json['vibrationFeedback'] ?? true,
      voiceGuidance: json['voiceGuidance'] ?? false,
      keepScreenOn: json['keepScreenOn'] ?? true,
      showExerciseVideos: json['showExerciseVideos'] ?? true,
      connectedMusicServices: List<String>.from(json['connectedMusicServices'] ?? []),
    );
  }
}

class AppSettings {
  final ThemeMode themeMode;
  final AccentColor accentColor;
  final Color customAccentColor;
  final double fontSize;
  final Language language;
  final NotificationSettings notifications;
  final TrainingPreferences training;
  final bool dataSync;
  final bool offlineMode;
  final bool analyticsEnabled;
  final bool personalizedAI;
  final DateTime? lastSyncTime;
  final bool onboardingCompleted;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.accentColor = AccentColor.purple,
    this.customAccentColor = const Color(0xFF8B5CF6),
    this.fontSize = 1.0,
    this.language = Language.englishUS,
    this.notifications = const NotificationSettings(),
    this.training = const TrainingPreferences(),
    this.dataSync = true,
    this.offlineMode = true,
    this.analyticsEnabled = true,
    this.personalizedAI = true,
    this.lastSyncTime,
    this.onboardingCompleted = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    AccentColor? accentColor,
    Color? customAccentColor,
    double? fontSize,
    Language? language,
    NotificationSettings? notifications,
    TrainingPreferences? training,
    bool? dataSync,
    bool? offlineMode,
    bool? analyticsEnabled,
    bool? personalizedAI,
    DateTime? lastSyncTime,
    bool? onboardingCompleted,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      customAccentColor: customAccentColor ?? this.customAccentColor,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      training: training ?? this.training,
      dataSync: dataSync ?? this.dataSync,
      offlineMode: offlineMode ?? this.offlineMode,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      personalizedAI: personalizedAI ?? this.personalizedAI,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'accentColor': accentColor.name,
      'customAccentColor': customAccentColor.value,
      'fontSize': fontSize,
      'language': language.name,
      'notifications': notifications.toJson(),
      'training': training.toJson(),
      'dataSync': dataSync,
      'offlineMode': offlineMode,
      'analyticsEnabled': analyticsEnabled,
      'personalizedAI': personalizedAI,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'onboardingCompleted': onboardingCompleted,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      accentColor: AccentColor.values.firstWhere(
        (e) => e.name == json['accentColor'],
        orElse: () => AccentColor.purple,
      ),
      customAccentColor: Color(json['customAccentColor'] ?? 0xFF8B5CF6),
      fontSize: json['fontSize']?.toDouble() ?? 1.0,
      language: Language.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => Language.englishUS,
      ),
      notifications: json['notifications'] != null
          ? NotificationSettings.fromJson(json['notifications'])
          : const NotificationSettings(),
      training: json['training'] != null
          ? TrainingPreferences.fromJson(json['training'])
          : const TrainingPreferences(),
      dataSync: json['dataSync'] ?? true,
      offlineMode: json['offlineMode'] ?? true,
      analyticsEnabled: json['analyticsEnabled'] ?? true,
      personalizedAI: json['personalizedAI'] ?? true,
      lastSyncTime: json['lastSyncTime'] != null ? DateTime.parse(json['lastSyncTime']) : null,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
    );
  }

  // Helper methods
  Color getAccentColor() {
    if (accentColor == AccentColor.custom) {
      return customAccentColor;
    }
    switch (accentColor) {
      case AccentColor.purple:
        return const Color(0xFF8B5CF6);
      case AccentColor.blue:
        return const Color(0xFF3B82F6);
      case AccentColor.green:
        return const Color(0xFF10B981);
      case AccentColor.red:
        return const Color(0xFFEF4444);
      case AccentColor.yellow:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

}
