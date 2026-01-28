import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import 'package:intl/intl.dart';

/// Service for exporting and downloading user data
class UserDataExportService {
  /// Generate a comprehensive JSON export of all user data
  static Map<String, dynamic> generateDataExport({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
    required Map<String, dynamic> additionalData,
  }) {
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'exportVersion': '1.0',
      'userProfile': {
        'name': userProfile.name,
        'email': userProfile.email,
        'phone': userProfile.phone,
        'dateOfBirth': userProfile.dateOfBirth?.toIso8601String(),
        'gender': userProfile.gender.toString(),
        'role': userProfile.role.toString(),
        'profileImageUrl': userProfile.profileImageUrl,
        'yearsTraining': userProfile.yearsTraining,
        'experienceLevel': userProfile.experienceLevel.toString(),
        'trainingGoals': userProfile.trainingGoals,
        'availableEquipment': userProfile.availableEquipment,
        'badges': userProfile.badges,
      },
      'workoutSessions': workoutSessions
          .map((session) => {
                'id': session.id,
                'date': session.date.toIso8601String(),
                'exercises': session.exercises
                    .map((ex) => {
                          'name': ex.exercise.name,
                          'sets': ex.sets
                              .map((set) => {
                                    'reps': set.reps,
                                    'weight': set.weight,
                                    'duration': set.duration,
                                  })
                              .toList(),
                        })
                    .toList(),
              })
          .toList(),
      'statistics': {
        'totalWorkouts': workoutSessions.length,
        'totalExercises': workoutSessions.fold(
            0,
            (sum, session) =>
                sum + session.exercises.length),
        'joinDate': additionalData['joinDate']?.toIso8601String(),
      },
      'additionalData': additionalData,
    };
  }

  /// Export data as formatted JSON string
  static String generateJSONExport({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
    required Map<String, dynamic> additionalData,
  }) {
    final data = generateDataExport(
      userProfile: userProfile,
      workoutSessions: workoutSessions,
      additionalData: additionalData,
    );
    
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Export data as CSV format (for workout history)
  static String generateCSVExport({
    required List<WorkoutSession> workoutSessions,
  }) {
    final StringBuffer csv = StringBuffer();
    
    // Header
    csv.writeln('Date,Exercise,Sets,Reps,Weight (kg),Duration (min)');
    
    // Data rows
    for (final session in workoutSessions) {
      final dateStr = DateFormat('yyyy-MM-dd').format(session.date);
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          csv.writeln(
            '$dateStr,${exercise.exercise.name},${exercise.sets.indexOf(set) + 1},'
            '${set.reps ?? "N/A"},${set.weight ?? "N/A"},${set.duration ?? "N/A"}',
          );
        }
      }
    }
    
    return csv.toString();
  }

  /// Generate a summary report
  static String generateSummaryReport({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
  }) {
    final StringBuffer report = StringBuffer();
    
    report.writeln('═══════════════════════════════════════════════════════');
    report.writeln('               USER DATA EXPORT REPORT');
    report.writeln('═══════════════════════════════════════════════════════\n');
    
    // User Information
    report.writeln('USER INFORMATION:');
    report.writeln('Name: ${userProfile.name}');
    report.writeln('Email: ${userProfile.email}');
    report.writeln('Phone: ${userProfile.phone ?? "N/A"}');
    report.writeln('Gender: ${userProfile.gender}');
    report.writeln('Role: ${userProfile.role}');
    report.writeln('Experience Level: ${userProfile.experienceLevel}');
    report.writeln('Years Training: ${userProfile.yearsTraining ?? "N/A"}');
    report.writeln('');
    
    // Training Information
    report.writeln('TRAINING INFORMATION:');
    report.writeln('Training Goals: ${userProfile.trainingGoals.join(", ")}');
    report.writeln('Available Equipment: ${userProfile.availableEquipment.join(", ")}');
    report.writeln('');
    
    // Statistics
    report.writeln('STATISTICS:');
    report.writeln('Total Workouts: ${workoutSessions.length}');
    
    int totalExercises = 0;
    int totalSets = 0;
    double totalVolume = 0;
    
    for (final session in workoutSessions) {
      totalExercises += session.exercises.length;
      for (final exercise in session.exercises) {
        totalSets += exercise.sets.length;
        for (final set in exercise.sets) {
          if (set.weight != null && set.reps != null) {
            totalVolume += set.weight! * set.reps!;
          }
        }
      }
    }
    
    report.writeln('Total Exercises Performed: $totalExercises');
    report.writeln('Total Sets: $totalSets');
    report.writeln('Total Volume (kg): ${totalVolume.toStringAsFixed(2)}');
    report.writeln('');
    
    // Achievements
    report.writeln('ACHIEVEMENTS & BADGES:');
    report.writeln('Badges Earned: ${userProfile.badges.length}');
    report.writeln('');
    
    report.writeln('═══════════════════════════════════════════════════════');
    report.writeln('Export Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    report.writeln('═══════════════════════════════════════════════════════');
    
    return report.toString();
  }
}

/// Provider for user data export
final userDataExportProvider = FutureProvider<String>((ref) async {
  // This would be implemented with actual data from providers
  return '';
});

/// Dialog for confirming data download
class DataDownloadConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const DataDownloadConfirmationDialog({
    super.key,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AlertDialog(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      title: const Row(
        children: [
          Icon(Icons.download_rounded, color: Colors.blue),
          SizedBox(width: 8),
          Text('Download Your Data'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will download all your personal data including:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DataItem(
                  icon: Icons.person,
                  label: 'Personal Information',
                ),
                _DataItem(
                  icon: Icons.fitness_center,
                  label: 'Workout History',
                ),
                _DataItem(
                  icon: Icons.bar_chart,
                  label: 'Progress Metrics',
                ),
                _DataItem(
                  icon: Icons.emoji_events,
                  label: 'Badges & Achievements',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The file will be downloaded in JSON format and can be imported to another platform.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          icon: const Icon(Icons.download),
          label: const Text('Download'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _DataItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DataItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
