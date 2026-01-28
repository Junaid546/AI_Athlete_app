import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';

class PDFExportService {
  static final PDFExportService _instance = PDFExportService._internal();

  factory PDFExportService() {
    return _instance;
  }

  PDFExportService._internal();

  /// Generate training summary PDF
  Future<void> generateTrainingSummaryPDF({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
    required dynamic streakData,
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    try {
      final pdf = pw.Document();

      // Filter sessions by date range
      final filteredSessions = _filterSessionsByDate(workoutSessions, startDate, endDate);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(userProfile),
            pw.SizedBox(height: 20),
            _buildStatsSummary(userProfile, filteredSessions),
            pw.SizedBox(height: 20),
            _buildRecentWorkouts(filteredSessions),
          ],
        ),
      );

      // Preview the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Training_Summary_${userProfile.name.replaceAll(' ', '_')}_${DateTime.now().toIso8601String().split('T')[0]}',
      );
    } catch (e) {
    debugPrint('Error generating training summary PDF: $e');
      rethrow;
    }
  }

  /// Generate workout log PDF
  Future<void> generateWorkoutLogPDF({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(userProfile),
            pw.SizedBox(height: 20),
            _buildWorkoutLogTable(workoutSessions),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Workout_Log_${userProfile.name.replaceAll(' ', '_')}_${DateTime.now().toIso8601String().split('T')[0]}',
      );
    } catch (e) {
    debugPrint('Error generating workout log PDF: $e');
      rethrow;
    }
  }

  /// Generate progress graph PDF
  Future<void> generateProgressGraphPDF({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(userProfile),
            pw.SizedBox(height: 20),
            _buildStatsSummary(userProfile, workoutSessions),
            pw.SizedBox(height: 20),
            _buildWeeklyVolumeChart(workoutSessions),
            pw.SizedBox(height: 20),
            _buildWorkoutFrequencyChart(workoutSessions),
            pw.SizedBox(height: 20),
            _buildStreakProgressionChart(workoutSessions),
            pw.SizedBox(height: 20),
            _buildTopExercisesChart(workoutSessions),
            pw.SizedBox(height: 20),
            _buildBodyMetricsChart(userProfile),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Progress_Graphs_${userProfile.name.replaceAll(' ', '_')}_${DateTime.now().toIso8601String().split('T')[0]}',
      );
    } catch (e) {
    debugPrint('Error generating progress graph PDF: $e');
      rethrow;
    }
  }

  /// Generate and download CSV export instead
  Future<String> generateCSVExport({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
  }) async {
    try {
      final buffer = StringBuffer();

      // Headers
      buffer.writeln('User Profile Report');
      buffer.writeln('Generated: ${DateTime.now()}');
      buffer.writeln('');

      // User Info
      buffer.writeln('User Information');
      buffer.writeln('Name,${userProfile.name}');
      buffer.writeln('Email,${userProfile.email}');
      buffer.writeln('Role,${userProfile.role.toString().split('.').last}');
      buffer.writeln('Experience Level,${userProfile.experienceLevel.toString().split('.').last}');
      buffer.writeln('');

      // Stats
      buffer.writeln('Performance Stats');
      buffer.writeln('Total Workouts,${userProfile.totalWorkouts}');
      buffer.writeln('Current Streak,${userProfile.currentStreak} days');
      buffer.writeln('Longest Streak,${userProfile.longestStreak} days');
      buffer.writeln('Total Volume,${userProfile.totalVolume.toStringAsFixed(2)} kg');
      buffer.writeln('Points,${userProfile.points}');
      buffer.writeln('Badges,${userProfile.badges.length}');
      buffer.writeln('');

      // Body Metrics
      buffer.writeln('Body Metrics');
      buffer.writeln('Height,${userProfile.height} cm');
      buffer.writeln('Weight,${userProfile.weight} kg');
      buffer.writeln('Body Fat,${userProfile.bodyFatPercentage}%');
      buffer.writeln('');

      // Workout History
      buffer.writeln('Workout History');
      buffer.writeln('Date,Plan,Volume,Exercises,Status');
      for (final session in workoutSessions) {
        buffer.writeln(
          '${session.startTime.toString().split(' ')[0]},${session.planName},${session.totalVolume.toStringAsFixed(1)} kg,${session.exercises.length},${session.completed ? 'Completed' : 'In Progress'}',
        );
      }

      return buffer.toString();
    } catch (e) {
    debugPrint('Error generating CSV export: $e');
      rethrow;
    }
  }

  // Helper methods for PDF generation

  List<WorkoutSession> _filterSessionsByDate(List<WorkoutSession> sessions, DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return sessions;
    return sessions.where((session) {
      final sessionDate = session.startTime;
      if (startDate != null && sessionDate.isBefore(startDate)) return false;
      if (endDate != null && sessionDate.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  pw.Widget _buildHeader(UserProfile userProfile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'AI Athlete Training Report',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated for: ${userProfile.name}',
          style: pw.TextStyle(fontSize: 16),
        ),
        pw.Text(
          'Date: ${DateTime.now().toString().split(' ')[0]}',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          height: 2,
          color: PdfColors.blue,
        ),
      ],
    );
  }

  pw.Widget _buildStatsSummary(UserProfile userProfile, List<WorkoutSession> sessions) {
    final totalVolume = sessions.fold<double>(0, (sum, s) => sum + s.totalVolume);
    final avgVolume = sessions.isNotEmpty ? totalVolume / sessions.length : 0.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Performance Summary',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total Workouts', userProfile.totalWorkouts.toString()),
              _buildStatItem('Current Streak', '${userProfile.currentStreak} days'),
              _buildStatItem('Total Volume', '${totalVolume.toStringAsFixed(1)} kg'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Avg Volume/Session', '${avgVolume.toStringAsFixed(1)} kg'),
              _buildStatItem('Longest Streak', '${userProfile.longestStreak} days'),
              _buildStatItem('Points Earned', userProfile.points.toString()),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
        ),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildRecentWorkouts(List<WorkoutSession> sessions) {
    final recentSessions = sessions.take(10).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Recent Workouts',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Plan', isHeader: true),
                _buildTableCell('Volume', isHeader: true),
                _buildTableCell('Exercises', isHeader: true),
                _buildTableCell('Status', isHeader: true),
              ],
            ),
            ...recentSessions.map((session) => pw.TableRow(
              children: [
                _buildTableCell(session.startTime.toString().split(' ')[0]),
                _buildTableCell(session.planName),
                _buildTableCell('${session.totalVolume.toStringAsFixed(1)} kg'),
                _buildTableCell(session.exercises.length.toString()),
                _buildTableCell(session.completed ? 'Completed' : 'In Progress'),
              ],
            )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildWorkoutLogTable(List<WorkoutSession> sessions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Complete Workout Log',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Plan', isHeader: true),
                _buildTableCell('Duration', isHeader: true),
                _buildTableCell('Volume', isHeader: true),
                _buildTableCell('Exercises', isHeader: true),
                _buildTableCell('Status', isHeader: true),
              ],
            ),
            ...sessions.map((session) => pw.TableRow(
              children: [
                _buildTableCell(session.startTime.toString().split(' ')[0]),
                _buildTableCell(session.planName),
                _buildTableCell(session.durationDisplay),
                _buildTableCell('${session.totalVolume.toStringAsFixed(1)} kg'),
                _buildTableCell(session.exercises.length.toString()),
                _buildTableCell(session.completed ? 'Completed' : 'In Progress'),
              ],
            )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildWeeklyVolumeChart(List<WorkoutSession> sessions) {
    // Simple bar chart representation using text
    final weeklyData = _calculateWeeklyVolume(sessions);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Weekly Volume Progression',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          height: 200,
          child: pw.Column(
            children: weeklyData.map((data) => pw.Row(
              children: [
                pw.Container(
                  width: 60,
                  child: pw.Text(data['day'] as String, style: pw.TextStyle(fontSize: 10)),
                ),
                pw.Container(
                  width: 200,
                  height: 20,
                  child: pw.Stack(
                    children: [
                      pw.Container(
                        width: 200,
                        height: 20,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                      pw.Container(
                        width: ((data['volume'] as double) / 1000) * 200, // Scale to max 1000kg
                        height: 20,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  width: 50,
                  child: pw.Text('${(data['volume'] as double).toStringAsFixed(0)}kg', style: pw.TextStyle(fontSize: 10)),
                ),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildWorkoutFrequencyChart(List<WorkoutSession> sessions) {
    final frequencyData = _calculateExerciseFrequency(sessions);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Exercise Frequency',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          height: 150,
          child: pw.Column(
            children: frequencyData.take(5).map((data) => pw.Row(
              children: [
                pw.Container(
                  width: 100,
                  child: pw.Text(data['exercise'] as String, style: pw.TextStyle(fontSize: 10)),
                ),
                pw.Container(
                  width: 150,
                  height: 15,
                  child: pw.Stack(
                    children: [
                      pw.Container(
                        width: 150,
                        height: 15,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                      pw.Container(
                        width: ((data['count'] as int) / 20) * 150, // Scale to max 20 workouts
                        height: 15,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  width: 30,
                  child: pw.Text('${data['count']}', style: pw.TextStyle(fontSize: 10)),
                ),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildStreakProgressionChart(List<WorkoutSession> sessions) {
    final streakData = _calculateStreakProgression(sessions);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Streak Progression (Last 30 Days)',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          height: 100,
          child: pw.Column(
            children: [
              pw.Text('Current streak: ${streakData.isNotEmpty ? streakData.last : 0} days', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 8),
              pw.Text('Streak values: ${streakData.join(', ')}', style: pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTopExercisesChart(List<WorkoutSession> sessions) {
    final topExercises = _calculateTopExercises(sessions);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Top Exercises by Volume',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          height: 200,
          child: pw.Column(
            children: topExercises.take(10).map((exercise) => pw.Row(
              children: [
                pw.Container(
                  width: 120,
                  child: pw.Text(exercise['name'] as String, style: pw.TextStyle(fontSize: 10)),
                ),
                pw.Container(
                  width: 200,
                  height: 15,
                  child: pw.Stack(
                    children: [
                      pw.Container(
                        width: 200,
                        height: 15,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                      pw.Container(
                        width: ((exercise['volume'] as double) / 5000) * 200, // Scale to max 5000kg
                        height: 15,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.orange,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  width: 50,
                  child: pw.Text('${(exercise['volume'] as double).toStringAsFixed(0)}kg', style: pw.TextStyle(fontSize: 10)),
                ),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBodyMetricsChart(UserProfile userProfile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Body Metrics',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildBodyMetricItem('Weight', '${userProfile.weight?.toStringAsFixed(1) ?? '--'} kg'),
                  _buildBodyMetricItem('Height', '${userProfile.height?.toStringAsFixed(0) ?? '--'} cm'),
                  _buildBodyMetricItem('Body Fat', '${userProfile.bodyFatPercentage?.toStringAsFixed(1) ?? '--'}%'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBodyMetricItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  // Data calculation methods

  List<Map<String, dynamic>> _calculateWeeklyVolume(List<WorkoutSession> sessions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = <Map<String, dynamic>>[];

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final daySessions = sessions.where((s) =>
        s.startTime.year == day.year &&
        s.startTime.month == day.month &&
        s.startTime.day == day.day
      ).toList();

      final totalVolume = daySessions.fold<double>(0, (sum, s) => sum + s.totalVolume);

      weeklyData.add({
        'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
        'volume': totalVolume,
      });
    }

    return weeklyData;
  }

  List<Map<String, dynamic>> _calculateExerciseFrequency(List<WorkoutSession> sessions) {
    final exerciseCount = <String, int>{};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final name = exercise.exercise.name;
        exerciseCount[name] = (exerciseCount[name] ?? 0) + 1;
      }
    }

    final sorted = exerciseCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => {'exercise': e.key, 'count': e.value}).toList();
  }

  List<int> _calculateStreakProgression(List<WorkoutSession> sessions) {
    // Simplified streak calculation - in real app would use streak provider
    final sortedSessions = sessions.where((s) => s.completed).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final streakData = <int>[];
    int currentStreak = 0;
    DateTime? lastDate;

    for (final session in sortedSessions) {
      final sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);

      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDiff = sessionDate.difference(lastDate).inDays;
        if (daysDiff == 1) {
          currentStreak++;
        } else if (daysDiff > 1) {
          currentStreak = 1;
        }
      }

      streakData.add(currentStreak);
      lastDate = sessionDate;
    }

    return streakData.take(30).toList(); // Last 30 days
  }

  List<Map<String, dynamic>> _calculateTopExercises(List<WorkoutSession> sessions) {
    final exerciseVolume = <String, double>{};

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final name = exercise.exercise.name;
        exerciseVolume[name] = (exerciseVolume[name] ?? 0) + exercise.totalVolume;
      }
    }

    final sorted = exerciseVolume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => {'name': e.key, 'volume': e.value}).toList();
  }
}

