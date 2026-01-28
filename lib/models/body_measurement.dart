class BodyMeasurement {
  final String id;
  final String userId;
  final DateTime date;
  final double? weight; // in kg
  final double? bodyFatPercentage;
  final double? muscleMass; // in kg
  final double? bmi;
  final double? chest; // in cm
  final double? waist; // in cm
  final double? hips; // in cm
  final double? leftArm; // in cm
  final double? rightArm; // in cm
  final double? leftThigh; // in cm
  final double? rightThigh; // in cm
  final double? leftCalf; // in cm
  final double? rightCalf; // in cm
  final String? notes;
  final String? photoUrl; // Progress photo
  final DateTime createdAt;

  BodyMeasurement({
    required this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.bodyFatPercentage,
    this.muscleMass,
    this.bmi,
    this.chest,
    this.waist,
    this.hips,
    this.leftArm,
    this.rightArm,
    this.leftThigh,
    this.rightThigh,
    this.leftCalf,
    this.rightCalf,
    this.notes,
    this.photoUrl,
    required this.createdAt,
  });

  BodyMeasurement copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? weight,
    double? bodyFatPercentage,
    double? muscleMass,
    double? bmi,
    double? chest,
    double? waist,
    double? hips,
    double? leftArm,
    double? rightArm,
    double? leftThigh,
    double? rightThigh,
    double? leftCalf,
    double? rightCalf,
    String? notes,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMass: muscleMass ?? this.muscleMass,
      bmi: bmi ?? this.bmi,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      leftArm: leftArm ?? this.leftArm,
      rightArm: rightArm ?? this.rightArm,
      leftThigh: leftThigh ?? this.leftThigh,
      rightThigh: rightThigh ?? this.rightThigh,
      leftCalf: leftCalf ?? this.leftCalf,
      rightCalf: rightCalf ?? this.rightCalf,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'weight': weight,
      'bodyFatPercentage': bodyFatPercentage,
      'muscleMass': muscleMass,
      'bmi': bmi,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'leftArm': leftArm,
      'rightArm': rightArm,
      'leftThigh': leftThigh,
      'rightThigh': rightThigh,
      'leftCalf': leftCalf,
      'rightCalf': rightCalf,
      'notes': notes,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      weight: json['weight']?.toDouble(),
      bodyFatPercentage: json['bodyFatPercentage']?.toDouble(),
      muscleMass: json['muscleMass']?.toDouble(),
      bmi: json['bmi']?.toDouble(),
      chest: json['chest']?.toDouble(),
      waist: json['waist']?.toDouble(),
      hips: json['hips']?.toDouble(),
      leftArm: json['leftArm']?.toDouble(),
      rightArm: json['rightArm']?.toDouble(),
      leftThigh: json['leftThigh']?.toDouble(),
      rightThigh: json['rightThigh']?.toDouble(),
      leftCalf: json['leftCalf']?.toDouble(),
      rightCalf: json['rightCalf']?.toDouble(),
      notes: json['notes'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Helper methods
  double? get averageArm => (leftArm != null && rightArm != null) ? (leftArm! + rightArm!) / 2 : null;
  double? get averageThigh => (leftThigh != null && rightThigh != null) ? (leftThigh! + rightThigh!) / 2 : null;
  double? get averageCalf => (leftCalf != null && rightCalf != null) ? (leftCalf! + rightCalf!) / 2 : null;

  bool get hasMeasurements => [
    weight,
    bodyFatPercentage,
    muscleMass,
    chest,
    waist,
    hips,
    leftArm,
    rightArm,
    leftThigh,
    rightThigh,
    leftCalf,
    rightCalf,
  ].any((measurement) => measurement != null);
}
