enum MuscleGroup {
  chest,
  back,
  shoulders,
  arms,
  legs,
  core,
  cardio,
  fullBody,
}

enum Equipment {
  bodyweight,
  dumbbells,
  barbell,
  machine,
  cable,
  kettlebell,
  resistanceBand,
  medicineBall,
  pullUpBar,
  bench,
  none,
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;
  final Equipment equipment;
  final String? videoUrl;
  final String? imageUrl;
  final List<String> instructions;
  final List<String> tips;
  final bool isCompound;
  final int difficulty; // 1-5

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    this.videoUrl,
    this.imageUrl,
    required this.instructions,
    required this.tips,
    required this.isCompound,
    required this.difficulty,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    List<MuscleGroup>? primaryMuscles,
    List<MuscleGroup>? secondaryMuscles,
    Equipment? equipment,
    String? videoUrl,
    String? imageUrl,
    List<String>? instructions,
    List<String>? tips,
    bool? isCompound,
    int? difficulty,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      isCompound: isCompound ?? this.isCompound,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primaryMuscles': primaryMuscles.map((m) => m.name).toList(),
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
      'equipment': equipment.name,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'instructions': instructions,
      'tips': tips,
      'isCompound': isCompound,
      'difficulty': difficulty,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      primaryMuscles: (json['primaryMuscles'] as List<dynamic>?)
          ?.map((m) => MuscleGroup.values.firstWhere((e) => e.name == m))
          .toList() ?? [],
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
          ?.map((m) => MuscleGroup.values.firstWhere((e) => e.name == m))
          .toList() ?? [],
      equipment: Equipment.values.firstWhere((e) => e.name == json['equipment']),
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
      instructions: List<String>.from(json['instructions'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
      isCompound: json['isCompound'] ?? false,
      difficulty: json['difficulty'] ?? 1,
    );
  }

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, description: $description, primaryMuscles: $primaryMuscles, secondaryMuscles: $secondaryMuscles, equipment: $equipment, videoUrl: $videoUrl, imageUrl: $imageUrl, instructions: $instructions, tips: $tips, isCompound: $isCompound, difficulty: $difficulty)';
  }
}
