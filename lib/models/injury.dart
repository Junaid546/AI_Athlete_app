enum InjurySeverity {
  mild, // Minor strain/sprain, can train around
  moderate, // Significant injury, modify training
  severe, // Major injury, stop training affected area
  critical, // Medical emergency, seek immediate care
}

enum InjuryStatus {
  active, // Currently injured
  recovering, // In recovery phase
  resolved, // Fully healed
  chronic, // Long-term condition
}

class Injury {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String bodyPart;
  final InjurySeverity severity;
  final InjuryStatus status;
  final DateTime injuryDate;
  final DateTime? recoveryStartDate;
  final DateTime? resolvedDate;
  final String? medicalDiagnosis;
  final String? treatment;
  final List<String> restrictedExercises;
  final List<String> allowedExercises;
  final String? notes;
  final List<String> symptoms;
  final int painLevel; // 1-10 scale
  final String? doctorName;
  final String? followUpDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Injury({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.bodyPart,
    required this.severity,
    required this.status,
    required this.injuryDate,
    this.recoveryStartDate,
    this.resolvedDate,
    this.medicalDiagnosis,
    this.treatment,
    this.restrictedExercises = const [],
    this.allowedExercises = const [],
    this.notes,
    this.symptoms = const [],
    required this.painLevel,
    this.doctorName,
    this.followUpDate,
    required this.createdAt,
    this.updatedAt,
  });

  Injury copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? bodyPart,
    InjurySeverity? severity,
    InjuryStatus? status,
    DateTime? injuryDate,
    DateTime? recoveryStartDate,
    DateTime? resolvedDate,
    String? medicalDiagnosis,
    String? treatment,
    List<String>? restrictedExercises,
    List<String>? allowedExercises,
    String? notes,
    List<String>? symptoms,
    int? painLevel,
    String? doctorName,
    String? followUpDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Injury(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      bodyPart: bodyPart ?? this.bodyPart,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      injuryDate: injuryDate ?? this.injuryDate,
      recoveryStartDate: recoveryStartDate ?? this.recoveryStartDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
      medicalDiagnosis: medicalDiagnosis ?? this.medicalDiagnosis,
      treatment: treatment ?? this.treatment,
      restrictedExercises: restrictedExercises ?? this.restrictedExercises,
      allowedExercises: allowedExercises ?? this.allowedExercises,
      notes: notes ?? this.notes,
      symptoms: symptoms ?? this.symptoms,
      painLevel: painLevel ?? this.painLevel,
      doctorName: doctorName ?? this.doctorName,
      followUpDate: followUpDate ?? this.followUpDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'bodyPart': bodyPart,
      'severity': severity.name,
      'status': status.name,
      'injuryDate': injuryDate.toIso8601String(),
      'recoveryStartDate': recoveryStartDate?.toIso8601String(),
      'resolvedDate': resolvedDate?.toIso8601String(),
      'medicalDiagnosis': medicalDiagnosis,
      'treatment': treatment,
      'restrictedExercises': restrictedExercises,
      'allowedExercises': allowedExercises,
      'notes': notes,
      'symptoms': symptoms,
      'painLevel': painLevel,
      'doctorName': doctorName,
      'followUpDate': followUpDate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Injury.fromJson(Map<String, dynamic> json) {
    return Injury(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      bodyPart: json['bodyPart'],
      severity: InjurySeverity.values.firstWhere((e) => e.name == json['severity']),
      status: InjuryStatus.values.firstWhere((e) => e.name == json['status']),
      injuryDate: DateTime.parse(json['injuryDate']),
      recoveryStartDate: json['recoveryStartDate'] != null ? DateTime.parse(json['recoveryStartDate']) : null,
      resolvedDate: json['resolvedDate'] != null ? DateTime.parse(json['resolvedDate']) : null,
      medicalDiagnosis: json['medicalDiagnosis'],
      treatment: json['treatment'],
      restrictedExercises: List<String>.from(json['restrictedExercises'] ?? []),
      allowedExercises: List<String>.from(json['allowedExercises'] ?? []),
      notes: json['notes'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      painLevel: json['painLevel'] ?? 1,
      doctorName: json['doctorName'],
      followUpDate: json['followUpDate'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Helper methods
  int get daysSinceInjury => DateTime.now().difference(injuryDate).inDays;
  int get daysInRecovery => recoveryStartDate != null ? DateTime.now().difference(recoveryStartDate!).inDays : 0;

  bool get canTrain => status != InjuryStatus.active || severity != InjurySeverity.critical;

  String get severityColor {
    switch (severity) {
      case InjurySeverity.mild: return '#10B981'; // Green
      case InjurySeverity.moderate: return '#F59E0B'; // Yellow
      case InjurySeverity.severe: return '#EF4444'; // Red
      case InjurySeverity.critical: return '#7F1D1D'; // Dark red
    }
  }

  String get statusDisplayName {
    switch (status) {
      case InjuryStatus.active: return 'Active';
      case InjuryStatus.recovering: return 'Recovering';
      case InjuryStatus.resolved: return 'Resolved';
      case InjuryStatus.chronic: return 'Chronic';
    }
  }

  String get severityDisplayName {
    switch (severity) {
      case InjurySeverity.mild: return 'Mild';
      case InjurySeverity.moderate: return 'Moderate';
      case InjurySeverity.severe: return 'Severe';
      case InjurySeverity.critical: return 'Critical';
    }
  }
}
