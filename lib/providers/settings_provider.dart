import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('app_settings');
      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson);
        state = AppSettings.fromJson(settingsMap);
      }
    } catch (e) {
      // If loading fails, keep default settings
    debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(state.toJson());
      await prefs.setString('app_settings', settingsJson);
    } catch (e) {
    debugPrint('Error saving settings: $e');
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    state = newSettings;
    await _saveSettings();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _saveSettings();
  }

  Future<void> updateAccentColor(AccentColor accentColor) async {
    state = state.copyWith(accentColor: accentColor);
    await _saveSettings();
  }

  Future<void> updateCustomAccentColor(Color color) async {
    state = state.copyWith(customAccentColor: color);
    await _saveSettings();
  }

  Future<void> updateFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize);
    await _saveSettings();
  }

  Future<void> updateLanguage(Language language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  Future<void> updateNotifications(NotificationSettings notifications) async {
    state = state.copyWith(notifications: notifications);
    await _saveSettings();
  }

  Future<void> updateTrainingPreferences(TrainingPreferences training) async {
    state = state.copyWith(training: training);
    await _saveSettings();
  }

  Future<void> updateDataSync(bool enabled) async {
    state = state.copyWith(dataSync: enabled);
    await _saveSettings();
  }

  Future<void> updateOfflineMode(bool enabled) async {
    state = state.copyWith(offlineMode: enabled);
    await _saveSettings();
  }

  Future<void> updateAnalytics(bool enabled) async {
    state = state.copyWith(analyticsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updatePersonalizedAI(bool enabled) async {
    state = state.copyWith(personalizedAI: enabled);
    await _saveSettings();
  }

  Future<void> updateLastSyncTime(DateTime? time) async {
    state = state.copyWith(lastSyncTime: time);
    await _saveSettings();
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingCompleted: true);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await _saveSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
