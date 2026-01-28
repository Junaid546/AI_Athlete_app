enum SortBy {
  popular,
  newest,
  highestRated,
  duration,
}

class PlanFilter {
  final int? minDurationWeeks;
  final int? maxDurationWeeks;
  final int? minDaysPerWeek;
  final int? maxDaysPerWeek;
  final List<String>? difficultyLevels; // Beginner, Intermediate, Advanced, Elite
  final List<String>? equipment;
  final List<String>? goals;
  final SortBy? sortBy;
  final String? searchQuery;

  const PlanFilter({
    this.minDurationWeeks,
    this.maxDurationWeeks,
    this.minDaysPerWeek,
    this.maxDaysPerWeek,
    this.difficultyLevels,
    this.equipment,
    this.goals,
    this.sortBy,
    this.searchQuery,
  });

  PlanFilter copyWith({
    int? minDurationWeeks,
    int? maxDurationWeeks,
    int? minDaysPerWeek,
    int? maxDaysPerWeek,
    List<String>? difficultyLevels,
    List<String>? equipment,
    List<String>? goals,
    SortBy? sortBy,
    String? searchQuery,
  }) {
    return PlanFilter(
      minDurationWeeks: minDurationWeeks ?? this.minDurationWeeks,
      maxDurationWeeks: maxDurationWeeks ?? this.maxDurationWeeks,
      minDaysPerWeek: minDaysPerWeek ?? this.minDaysPerWeek,
      maxDaysPerWeek: maxDaysPerWeek ?? this.maxDaysPerWeek,
      difficultyLevels: difficultyLevels ?? this.difficultyLevels,
      equipment: equipment ?? this.equipment,
      goals: goals ?? this.goals,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isEmpty =>
      minDurationWeeks == null &&
      maxDurationWeeks == null &&
      minDaysPerWeek == null &&
      maxDaysPerWeek == null &&
      (difficultyLevels?.isEmpty ?? true) &&
      (equipment?.isEmpty ?? true) &&
      (goals?.isEmpty ?? true) &&
      sortBy == null &&
      (searchQuery?.isEmpty ?? true);

  void clear() {
    // This would be used to reset the filter
  }

  Map<String, dynamic> toJson() {
    return {
      'minDurationWeeks': minDurationWeeks,
      'maxDurationWeeks': maxDurationWeeks,
      'minDaysPerWeek': minDaysPerWeek,
      'maxDaysPerWeek': maxDaysPerWeek,
      'difficultyLevels': difficultyLevels,
      'equipment': equipment,
      'goals': goals,
      'sortBy': sortBy?.name,
      'searchQuery': searchQuery,
    };
  }

  factory PlanFilter.fromJson(Map<String, dynamic> json) {
    return PlanFilter(
      minDurationWeeks: json['minDurationWeeks'],
      maxDurationWeeks: json['maxDurationWeeks'],
      minDaysPerWeek: json['minDaysPerWeek'],
      maxDaysPerWeek: json['maxDaysPerWeek'],
      difficultyLevels: json['difficultyLevels'] != null
          ? List<String>.from(json['difficultyLevels'])
          : null,
      equipment: json['equipment'] != null
          ? List<String>.from(json['equipment'])
          : null,
      goals: json['goals'] != null
          ? List<String>.from(json['goals'])
          : null,
      sortBy: json['sortBy'] != null
          ? SortBy.values.firstWhere((e) => e.name == json['sortBy'])
          : null,
      searchQuery: json['searchQuery'],
    );
  }
}
