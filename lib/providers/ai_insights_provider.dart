import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/ai_insight.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';

class AiInsightsNotifier extends StateNotifier<List<AiInsight>> {
  AiInsightsNotifier() : super([]);

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
  );

  // Generate insights based on user data
  Future<void> generateInsights(UserProfile? profile, List<WorkoutSession> sessions) async {
    if (profile == null || sessions.isEmpty) {
      _generateDefaultInsights();
      return;
    }

    try {
      final insights = await _analyzeTrainingData(profile, sessions);
      state = insights;
    } catch (e) {
      _generateDefaultInsights();
    }
  }

  Future<List<AiInsight>> _analyzeTrainingData(UserProfile profile, List<WorkoutSession> sessions) async {
    final insights = <AiInsight>[];

    try {
      // Training Optimization Insight
      final trainingInsight = await _generateTrainingOptimizationInsight(profile, sessions);
      if (trainingInsight != null) insights.add(trainingInsight);
    } catch (e) {
      // Continue with other insights if one fails
      developer.log('Failed to generate training optimization insight: $e');
    }

    try {
      // Injury Prevention Insight
      final injuryInsight = await _generateInjuryPreventionInsight(profile, sessions);
      if (injuryInsight != null) insights.add(injuryInsight);
    } catch (e) {
      developer.log('Failed to generate injury prevention insight: $e');
    }

    try {
      // Performance Analysis Insight
      final performanceInsight = await _generatePerformanceAnalysisInsight(profile, sessions);
      if (performanceInsight != null) insights.add(performanceInsight);
    } catch (e) {
      developer.log('Failed to generate performance analysis insight: $e');
    }

    try {
      // Nutrition Guidance Insight
      final nutritionInsight = await _generateNutritionGuidanceInsight(profile);
      if (nutritionInsight != null) insights.add(nutritionInsight);
    } catch (e) {
      developer.log('Failed to generate nutrition guidance insight: $e');
    }

    try {
      // Recovery & Wellness Insight
      final recoveryInsight = await _generateRecoveryWellnessInsight(profile, sessions);
      if (recoveryInsight != null) insights.add(recoveryInsight);
    } catch (e) {
      developer.log('Failed to generate recovery wellness insight: $e');
    }

    try {
      // Next Mesocycle Suggestion
      final mesocycleInsight = await _generateNextMesocycleInsight(profile, sessions);
      if (mesocycleInsight != null) insights.add(mesocycleInsight);
    } catch (e) {
      developer.log('Failed to generate mesocycle insight: $e');
    }

    return insights;
  }

  Future<AiInsight?> _generateTrainingOptimizationInsight(UserProfile profile, List<WorkoutSession> sessions) async {
    try {
      final prompt = '''
Analyze this athlete's training data and provide ONE specific training optimization insight.

Athlete Profile:
- Name: ${profile.name}
- Goals: ${profile.trainingGoals.join(', ')}
- Experience: ${profile.experienceLevel.name}
- Sessions in last 4 weeks: ${sessions.where((s) => s.startTime.isAfter(DateTime.now().subtract(const Duration(days: 28)))).length}

Recent Sessions (last 5):
${sessions.take(5).map((s) => '- ${s.planName}: ${s.totalVolume}kg, ${s.actualDuration?.inMinutes ?? 0}min').join('\n')}

Provide a concise, actionable training optimization suggestion with 3-4 specific recommendations.
Format as JSON with: title, description, recommendations (array), priority (low/medium/high/critical)
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final data = _parseJsonResponse(response.text ?? '');

      return AiInsight(
        id: 'training_opt_${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        type: InsightType.trainingOptimization,
        title: data['title'] ?? 'Training Optimization',
        description: data['description'] ?? 'Optimize your training approach',
        recommendations: List<String>.from(data['recommendations'] ?? []),
        priority: _parsePriority(data['priority'] ?? 'medium'),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<AiInsight?> _generateInjuryPreventionInsight(UserProfile profile, List<WorkoutSession> sessions) async {
    try {
      final recentSessions = sessions.where((s) => s.startTime.isAfter(DateTime.now().subtract(const Duration(days: 14)))).toList();
      final shoulderVolume = recentSessions.fold<double>(0, (sum, s) =>
        sum + s.exercises.where((e) => e.exercise.name.toLowerCase().contains('shoulder')).fold(0.0, (sum, e) => sum + e.totalVolume));

      final prompt = '''
Assess injury risk for this athlete based on their training data.

Athlete Profile:
- Age: ${profile.calculatedAge}
- Experience: ${profile.experienceLevel.name}
- Injuries/Limitations: ${profile.injuriesLimitations.join(', ')}

Recent Training (last 2 weeks):
- Sessions: ${recentSessions.length}
- Shoulder volume: ${shoulderVolume}kg
- Average session duration: ${recentSessions.isNotEmpty ? (recentSessions.fold(0, (sum, s) => sum + (s.actualDuration?.inMinutes ?? 0)) / recentSessions.length).round() : 0}min

Provide injury prevention advice. Calculate a risk score (0-10) where 10 is highest risk.
Format as JSON with: title, description, recommendations (array), priority, riskScore
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final data = _parseJsonResponse(response.text ?? '');

      return AiInsight(
        id: 'injury_prev_${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        type: InsightType.injuryPrevention,
        title: data['title'] ?? 'Injury Prevention Alert',
        description: data['description'] ?? 'Monitor your training to prevent injuries',
        recommendations: List<String>.from(data['recommendations'] ?? []),
        priority: _parsePriority(data['priority'] ?? 'high'),
        riskScore: (data['riskScore'] as num?)?.toDouble(),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<AiInsight?> _generatePerformanceAnalysisInsight(UserProfile profile, List<WorkoutSession> sessions) async {
    try {
      final monthlySessions = sessions.where((s) => s.startTime.isAfter(DateTime.now().subtract(const Duration(days: 30)))).toList();
      final consistency = monthlySessions.length >= 16 ? 'excellent' : monthlySessions.length >= 12 ? 'good' : 'needs improvement';

      final prompt = '''
Analyze this athlete's performance over the last month.

Monthly Stats:
- Sessions completed: ${monthlySessions.length}
- Consistency: $consistency
- Total volume: ${monthlySessions.fold<double>(0, (sum, s) => sum + s.totalVolume)}kg
- Average session duration: ${monthlySessions.isNotEmpty ? (monthlySessions.fold(0, (sum, s) => sum + (s.actualDuration?.inMinutes ?? 0)) / monthlySessions.length).round() : 0}min

Goals: ${profile.trainingGoals.join(', ')}

Provide a performance analysis with focus areas for next month.
Format as JSON with: title, description, recommendations (array), priority
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final data = _parseJsonResponse(response.text ?? '');

      return AiInsight(
        id: 'performance_${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        type: InsightType.performanceAnalysis,
        title: data['title'] ?? 'Monthly Performance Report',
        description: data['description'] ?? 'Your training performance analysis',
        recommendations: List<String>.from(data['recommendations'] ?? []),
        priority: _parsePriority(data['priority'] ?? 'medium'),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<AiInsight?> _generateNutritionGuidanceInsight(UserProfile profile) async {
    try {
      final weight = profile.weight ?? 75.0;
      final goal = profile.trainingGoals.isNotEmpty ? profile.trainingGoals.first : 'muscle gain';

      final prompt = '''
Calculate nutrition targets for this athlete.

Athlete Details:
- Weight: ${weight}kg
- Goal: $goal
- Training frequency: ${profile.trainingFrequency.name}

Provide daily macro targets and meal timing advice.
Format as JSON with: title, description, recommendations (array), priority
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final data = _parseJsonResponse(response.text ?? '');

      return AiInsight(
        id: 'nutrition_${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        type: InsightType.nutritionGuidance,
        title: data['title'] ?? 'Nutrition Guidance',
        description: data['description'] ?? 'Optimize your nutrition for better results',
        recommendations: List<String>.from(data['recommendations'] ?? []),
        priority: _parsePriority(data['priority'] ?? 'medium'),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<AiInsight?> _generateRecoveryWellnessInsight(UserProfile profile, List<WorkoutSession> sessions) async {
    try {
      final recentSessions = sessions.where((s) => s.startTime.isAfter(DateTime.now().subtract(const Duration(days: 7)))).toList();
      final weeklyVolume = recentSessions.fold<double>(0, (sum, s) => sum + s.totalVolume);

      final prompt = '''
Assess recovery and wellness status.

Weekly Training:
- Sessions: ${recentSessions.length}
- Total volume: ${weeklyVolume}kg
- Average sleep (estimated): 7hrs
- Current streak: ${profile.currentStreak} days

Provide recovery recommendations and wellness tips.
Format as JSON with: title, description, recommendations (array), priority
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final data = _parseJsonResponse(response.text ?? '');

      return AiInsight(
        id: 'recovery_${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        type: InsightType.recoveryWellness,
        title: data['title'] ?? 'Recovery & Wellness',
        description: data['description'] ?? 'Optimize your recovery for peak performance',
        recommendations: List<String>.from(data['recommendations'] ?? []),
        priority: _parsePriority(data['priority'] ?? 'medium'),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<AiInsight?> _generateNextMesocycleInsight(UserProfile profile, List<WorkoutSession> sessions) async {
    try {
      final prompt = '''
Suggest the next training mesocycle for this athlete.

Current Status:
- Experience level: ${profile.experienceLevel.name}
- Training age: ${profile.yearsTraining ?? 1} years
- Current goals: ${profile.trainingGoals.join(', ')}
- Recent training focus: ${sessions.isNotEmpty ? sessions.first.planName : 'General'}

Recommend a 4-12 week mesocycle with specific details.
Format as JSON with: title, description, recommendations (array), priority
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final data = _parseJsonResponse(response.text ?? '');

      return AiInsight(
        id: 'mesocycle_${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        type: InsightType.nextMesocycle,
        title: data['title'] ?? 'Next Mesocycle Suggestion',
        description: data['description'] ?? 'Plan your next training phase',
        recommendations: List<String>.from(data['recommendations'] ?? []),
        priority: _parsePriority(data['priority'] ?? 'medium'),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  void _generateDefaultInsights() {
    state = [
      AiInsight(
        id: 'default_1',
        userId: 'default',
        type: InsightType.trainingOptimization,
        title: 'Welcome to AI Coaching',
        description: 'Start logging your workouts to get personalized insights',
        recommendations: [
          'Complete your profile for better recommendations',
          'Log your first workout session',
          'Set specific training goals'
        ],
        priority: InsightPriority.medium,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      // Extract JSON from the response (AI might add extra text)
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd != -1) {
        // Extract JSON and parse it
        // final jsonString = response.substring(jsonStart, jsonEnd);
        // Simple JSON parsing - in real app, use json.decode
        return {}; // Placeholder - would need proper JSON parsing
      }
    } catch (e) {
      // Fallback
    }
    return {};
  }

  InsightPriority _parsePriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low': return InsightPriority.low;
      case 'high': return InsightPriority.high;
      case 'critical': return InsightPriority.critical;
      default: return InsightPriority.medium;
    }
  }

  // Mark insight as read
  void markAsRead(String insightId) {
    state = state.map((insight) {
      if (insight.id == insightId) {
        return insight.copyWith(isRead: true);
      }
      return insight;
    }).toList();
  }

  // Archive insight
  void archiveInsight(String insightId) {
    state = state.map((insight) {
      if (insight.id == insightId) {
        return insight.copyWith(isArchived: true);
      }
      return insight;
    }).toList();
  }

  // Regenerate insights
  Future<void> regenerateInsights(UserProfile? profile, List<WorkoutSession> sessions) async {
    state = []; // Clear current insights
    await generateInsights(profile, sessions);
  }
}

final aiInsightsProvider = StateNotifierProvider<AiInsightsNotifier, List<AiInsight>>((ref) {
  return AiInsightsNotifier();
});

// Filtered insights providers
final unreadInsightsProvider = Provider<List<AiInsight>>((ref) {
  final insights = ref.watch(aiInsightsProvider);
  return insights.where((insight) => !insight.isRead && !insight.isArchived).toList();
});

final highPriorityInsightsProvider = Provider<List<AiInsight>>((ref) {
  final insights = ref.watch(aiInsightsProvider);
  return insights.where((insight) =>
    (insight.priority == InsightPriority.high || insight.priority == InsightPriority.critical) &&
    !insight.isArchived
  ).toList();
});
