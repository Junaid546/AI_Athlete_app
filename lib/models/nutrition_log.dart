enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  preWorkout,
  postWorkout,
}

class NutritionLog {
  final String id;
  final String userId;
  final DateTime date;
  final MealType mealType;
  final String foodName;
  final double? calories; // kcal
  final double? protein; // grams
  final double? carbs; // grams
  final double? fat; // grams
  final double? fiber; // grams
  final double? sugar; // grams
  final double? sodium; // mg
  final double? servingSize; // grams or ml
  final String? servingUnit;
  final int? servings;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;

  NutritionLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foodName,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.servingSize,
    this.servingUnit,
    this.servings,
    this.notes,
    this.photoUrl,
    required this.createdAt,
  });

  NutritionLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MealType? mealType,
    String? foodName,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    double? servingSize,
    String? servingUnit,
    int? servings,
    String? notes,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return NutritionLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      servings: servings ?? this.servings,
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
      'mealType': mealType.name,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'servings': servings,
      'notes': notes,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    return NutritionLog(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      mealType: MealType.values.firstWhere((e) => e.name == json['mealType']),
      foodName: json['foodName'],
      calories: json['calories']?.toDouble(),
      protein: json['protein']?.toDouble(),
      carbs: json['carbs']?.toDouble(),
      fat: json['fat']?.toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      servingSize: json['servingSize']?.toDouble(),
      servingUnit: json['servingUnit'],
      servings: json['servings'],
      notes: json['notes'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Helper methods
  double get totalCalories => (calories ?? 0) * (servings ?? 1);
  double get totalProtein => (protein ?? 0) * (servings ?? 1);
  double get totalCarbs => (carbs ?? 0) * (servings ?? 1);
  double get totalFat => (fat ?? 0) * (servings ?? 1);
  double get totalFiber => (fiber ?? 0) * (servings ?? 1);
  double get totalSugar => (sugar ?? 0) * (servings ?? 1);
  double get totalSodium => (sodium ?? 0) * (servings ?? 1);

  String get mealTypeDisplayName {
    switch (mealType) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
      case MealType.preWorkout: return 'Pre-workout';
      case MealType.postWorkout: return 'Post-workout';
    }
  }

  String get servingDisplay {
    if (servingSize == null) return '';
    final unit = servingUnit ?? 'g';
    final serv = servings ?? 1;
    if (serv == 1) {
      return '${servingSize!.toStringAsFixed(0)} $unit';
    } else {
      return '${servingSize!.toStringAsFixed(0)} $unit × $serv';
    }
  }
}
