enum RecoveryType {
  rest, // Complete rest day
  activeRecovery, // Light activity
  mobility, // Stretching/mobility work
  massage, // Self-massage or professional
  ice, // Cold therapy
  heat, // Heat therapy
  compression, // Compression garments
  elevation, // Elevation for swelling
  sleep, // Sleep/focused recovery
  nutrition, // Recovery nutrition
  sauna, // Sauna/heat exposure
  coldPlunge, // Cold water immersion
}

class RecoverySession {
  final String id;
  final String userId;
  final DateTime date;
  final RecoveryType type;
  final String name;
  final String description;
  final Duration duration;
  final int effectiveness; // 1-10 scale, how effective it was
  final String? notes;
  final List<String> bodyParts; // Areas targeted
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;

  RecoverySession({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.name,
    required this.description,
    required this.duration,
    this.effectiveness = 0,
    this.notes,
    this.bodyParts = const [],
    this.completed = false,
    this.completedAt,
    required this.createdAt,
  });

  RecoverySession copyWith({
    String? id,
    String? userId,
    DateTime? date,
    RecoveryType? type,
    String? name,
    String? description,
    Duration? duration,
    int? effectiveness,
    String? notes,
    List<String>? bodyParts,
    bool? completed,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return RecoverySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      effectiveness: effectiveness ?? this.effectiveness,
      notes: notes ?? this.notes,
      bodyParts: bodyParts ?? this.bodyParts,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'type': type.name,
      'name': name,
      'description': description,
      'duration': duration.inMinutes,
      'effectiveness': effectiveness,
      'notes': notes,
      'bodyParts': bodyParts,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecoverySession.fromJson(Map<String, dynamic> json) {
    return RecoverySession(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      type: RecoveryType.values.firstWhere((e) => e.name == json['type']),
      name: json['name'],
      description: json['description'],
      duration: Duration(minutes: json['duration'] ?? 0),
      effectiveness: json['effectiveness'],
      notes: json['notes'],
      bodyParts: List<String>.from(json['bodyParts'] ?? []),
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Helper methods
  String get typeDisplayName {
    switch (type) {
      case RecoveryType.rest: return 'Rest';
      case RecoveryType.activeRecovery: return 'Active Recovery';
      case RecoveryType.mobility: return 'Mobility Work';
      case RecoveryType.massage: return 'Massage';
      case RecoveryType.ice: return 'Ice Therapy';
      case RecoveryType.heat: return 'Heat Therapy';
      case RecoveryType.compression: return 'Compression';
      case RecoveryType.elevation: return 'Elevation';
      case RecoveryType.sleep: return 'Sleep Recovery';
      case RecoveryType.nutrition: return 'Nutrition';
      case RecoveryType.sauna: return 'Sauna';
      case RecoveryType.coldPlunge: return 'Cold Plunge';
    }
  }

  String get durationDisplay {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get effectivenessDisplay {
    if (effectiveness == 0) return 'Not rated';
    switch (effectiveness) {
      case 1: return 'Poor';
      case 2: return 'Below Average';
      case 3: return 'Average';
      case 4: return 'Good';
      case 5: return 'Very Good';
      case 6: return 'Excellent';
      case 7: return 'Outstanding';
      case 8: return 'Exceptional';
      case 9: return 'Incredible';
      case 10: return 'Perfect';
      default: return 'Unknown';
    }
  }
}
