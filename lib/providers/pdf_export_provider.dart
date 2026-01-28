import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../services/pdf_export_service.dart';

/// PDF export state
class PDFExportState {
  final bool isGenerating;
  final String? error;
  final String? successMessage;

  PDFExportState({
    this.isGenerating = false,
    this.error,
    this.successMessage,
  });

  PDFExportState copyWith({
    bool? isGenerating,
    String? error,
    String? successMessage,
  }) {
    return PDFExportState(
      isGenerating: isGenerating ?? this.isGenerating,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// PDF export notifier
class PDFExportNotifier extends StateNotifier<PDFExportState> {
  final PDFExportService _pdfService = PDFExportService();

  PDFExportNotifier() : super(PDFExportState());

  /// Generate training summary PDF
  Future<void> generateTrainingSummary({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
    required dynamic streakData,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      state = state.copyWith(isGenerating: true, error: null, successMessage: null);

      await _pdfService.generateTrainingSummaryPDF(
        userProfile: userProfile,
        workoutSessions: workoutSessions,
        streakData: streakData,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isGenerating: false,
        successMessage: 'Training summary PDF generated successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate PDF: ${e.toString()}',
      );
    debugPrint('PDF generation error: $e');
    }
  }

  /// Generate workout log PDF
  Future<void> generateWorkoutLog({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
  }) async {
    try {
      state = state.copyWith(isGenerating: true, error: null, successMessage: null);

      await _pdfService.generateWorkoutLogPDF(
        userProfile: userProfile,
        workoutSessions: workoutSessions,
      );

      state = state.copyWith(
        isGenerating: false,
        successMessage: 'Workout log PDF generated successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate PDF: ${e.toString()}',
      );
    debugPrint('PDF generation error: $e');
    }
  }

  /// Generate progress graph PDF
  Future<void> generateProgressGraph({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
  }) async {
    try {
      state = state.copyWith(isGenerating: true, error: null, successMessage: null);

      await _pdfService.generateProgressGraphPDF(
        userProfile: userProfile,
        workoutSessions: workoutSessions,
      );

      state = state.copyWith(
        isGenerating: false,
        successMessage: 'Progress graph PDF generated successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate PDF: ${e.toString()}',
      );
    debugPrint('PDF generation error: $e');
    }
  }

  /// Generate CSV export
  Future<String?> generateCSVExport({
    required UserProfile userProfile,
    required List<WorkoutSession> workoutSessions,
  }) async {
    try {
      state = state.copyWith(isGenerating: true, error: null, successMessage: null);

      final csvContent = await _pdfService.generateCSVExport(
        userProfile: userProfile,
        workoutSessions: workoutSessions,
      );

      state = state.copyWith(
        isGenerating: false,
        successMessage: 'CSV export generated successfully!',
      );

      return csvContent;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate CSV: ${e.toString()}',
      );
    debugPrint('CSV generation error: $e');
      return null;
    }
  }

  /// Clear messages
  void clearMessages() {
    state = PDFExportState();
  }
}

/// Provider for PDF exports
final pdfExportProvider = StateNotifierProvider<PDFExportNotifier, PDFExportState>((ref) {
  return PDFExportNotifier();
});
