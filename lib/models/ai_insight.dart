enum InsightType {
  trainingOptimization,
  injuryPrevention,
  performanceAnalysis,
  nutritionGuidance,
  recoveryWellness,
  nextMesocycle,
}

enum InsightPriority { low, medium, high, critical }

class AiInsight {
  final String id;
  final String userId;
  final InsightType type;
  final String title;
  final String description;
  final List<String> recommendations;
  final InsightPriority priority;
  final double? riskScore; // For injury prevention insights
  final Map<String, dynamic>? metrics; // Additional data like percentages, scores
  final DateTime createdAt;
  final bool isRead;
  final bool isArchived;

  AiInsight({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.recommendations,
    this.priority = InsightPriority.medium,
    this.riskScore,
    this.metrics,
    required this.createdAt,
    this.isRead = false,
    this.isArchived = false,
  });

  AiInsight copyWith({
    String? id,
    String? userId,
    InsightType? type,
    String? title,
    String? description,
    List<String>? recommendations,
    InsightPriority? priority,
    double? riskScore,
    Map<String, dynamic>? metrics,
    DateTime? createdAt,
    bool? isRead,
    bool? isArchived,
  }) {
    return AiInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      recommendations: recommendations ?? this.recommendations,
      priority: priority ?? this.priority,
      riskScore: riskScore ?? this.riskScore,
      metrics: metrics ?? this.metrics,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'recommendations': recommendations,
      'priority': priority.name,
      'riskScore': riskScore,
      'metrics': metrics,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'isArchived': isArchived,
    };
  }

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      id: json['id'],
      userId: json['userId'],
      type: InsightType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      description: json['description'],
      recommendations: List<String>.from(json['recommendations'] ?? []),
      priority: InsightPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => InsightPriority.medium,
      ),
      riskScore: json['riskScore']?.toDouble(),
      metrics: json['metrics'] != null ? Map<String, dynamic>.from(json['metrics']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      isArchived: json['isArchived'] ?? false,
    );
  }

  // Helper methods
  String get typeDisplayName {
    switch (type) {
      case InsightType.trainingOptimization:
        return 'Training Optimization';
      case InsightType.injuryPrevention:
        return 'Injury Prevention';
      case InsightType.performanceAnalysis:
        return 'Performance Analysis';
      case InsightType.nutritionGuidance:
        return 'Nutrition Guidance';
      case InsightType.recoveryWellness:
        return 'Recovery & Wellness';
      case InsightType.nextMesocycle:
        return 'Next Mesocycle';
    }
  }

  String get priorityColor {
    switch (priority) {
      case InsightPriority.low:
        return '#4CAF50'; // Green
      case InsightPriority.medium:
        return '#FF9800'; // Orange
      case InsightPriority.high:
        return '#FF5722'; // Deep Orange
      case InsightPriority.critical:
        return '#F44336'; // Red
    }
  }

  String get iconName {
    switch (type) {
      case InsightType.trainingOptimization:
        return '💪';
      case InsightType.injuryPrevention:
        return '🛡️';
      case InsightType.performanceAnalysis:
        return '📊';
      case InsightType.nutritionGuidance:
        return '🍎';
      case InsightType.recoveryWellness:
        return '🧘';
      case InsightType.nextMesocycle:
        return '🎯';
    }
  }
}
