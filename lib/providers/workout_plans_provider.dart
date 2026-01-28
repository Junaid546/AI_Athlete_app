import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_plan.dart';
import '../models/plan_filter.dart';

// Enhanced provider with filtering and pagination
class WorkoutPlansNotifier extends StateNotifier<AsyncValue<List<WorkoutPlan>>> {
  WorkoutPlansNotifier() : super(const AsyncValue.loading()) {
    _loadPlans();
  }

  List<WorkoutPlan> _allPlans = [];
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _pageSize = 20;

  static final _mockPlans = [
    WorkoutPlan(
      id: '1',
      name: 'Beginner Strength',
      description: 'Build foundational strength with compound movements',
      authorId: 'ai-coach',
      authorName: 'AI Coach',
      category: PlanCategory.beginner,
      type: PlanType.linear,
      weeks: 8,
      daysPerWeek: 3,
      difficulty: 1,
      targetGoals: ['Build muscle', 'Increase strength'],
      requiredEquipment: ['Dumbbells', 'Bench'],
      estimatedDuration: const Duration(minutes: 45),
      workoutDays: [],
      rating: 4,
      reviewCount: 127,
      createdAt: DateTime.now(),
      imageUrl: 'https://img.freepik.com/free-vector/brawny-caucasian-arm_1284-13546.jpg?semt=ais_hybrid&w=740&q=80',
    ),
    WorkoutPlan(
      id: '2',
      name: 'Endurance Builder',
      description: 'Improve cardiovascular endurance and stamina',
      authorId: 'ai-coach',
      authorName: 'AI Coach',
      category: PlanCategory.endurance,
      type: PlanType.linear,
      weeks: 6,
      daysPerWeek: 4,
      difficulty: 2,
      targetGoals: ['Improve endurance', 'Burn fat'],
      requiredEquipment: ['None'],
      estimatedDuration: const Duration(minutes: 30),
      workoutDays: [],
      rating: 5,
      reviewCount: 89,
      createdAt: DateTime.now(),
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/15888/15888479.png',
    ),
    WorkoutPlan(
      id: '3',
      name: 'Flexibility & Mobility',
      description: 'Enhance flexibility and joint mobility',
      authorId: 'ai-coach',
      authorName: 'AI Coach',
      category: PlanCategory.bodyweight,
      type: PlanType.linear,
      weeks: 4,
      daysPerWeek: 3,
      difficulty: 1,
      targetGoals: ['Improve flexibility', 'Reduce injury risk'],
      requiredEquipment: ['Yoga mat'],
      estimatedDuration: const Duration(minutes: 30),
      workoutDays: [],
      rating: 4,
      reviewCount: 56,
      createdAt: DateTime.now(),
      imageUrl: 'https://www.kindpng.com/picc/m/3-31751_stretching-silhouette-clip-art-stretching-clip-art-hd.png',
    ),
    // Add more mock plans for demonstration
    WorkoutPlan(
      id: '4',
      name: 'Advanced Powerlifting',
      description: 'Maximize strength gains with heavy compound lifts',
      authorId: 'coach-john',
      authorName: 'Coach John',
      category: PlanCategory.power,
      type: PlanType.periodized,
      weeks: 12,
      daysPerWeek: 4,
      difficulty: 5,
      targetGoals: ['Max strength', 'Power output'],
      requiredEquipment: ['Barbell', 'Power rack', 'Plates'],
      estimatedDuration: const Duration(minutes: 90),
      workoutDays: [],
      rating: 5,
      reviewCount: 203,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      imageUrl: 'https://static.vecteezy.com/system/resources/thumbnails/002/219/020/small/abstract-strong-man-lifting-weights-powerlifting-weightlifting-from-splash-of-watercolors-illustration-of-paints-vector.jpg',
    ),
    WorkoutPlan(
      id: '5',
      name: 'HIIT Cardio Blast',
      description: 'High-intensity interval training for fat loss',
      authorId: 'ai-coach',
      authorName: 'AI Coach',
      category: PlanCategory.endurance,
      type: PlanType.undulating,
      weeks: 8,
      daysPerWeek: 3,
      difficulty: 3,
      targetGoals: ['Fat loss', 'Cardio fitness'],
      requiredEquipment: ['None'],
      estimatedDuration: const Duration(minutes: 25),
      workoutDays: [],
      rating: 4,
      reviewCount: 145,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      imageUrl: 'https://media.istockphoto.com/id/1263376891/vector/hiit-high-intensity-interval-training-sport-icon.jpg?s=612x612&w=0&k=20&c=6oatupUqMcABu0-3Q1ua6Cg3DmZle4c39INvbEYUmlI=',
    ),
  ];

  Future<void> _loadPlans() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    _allPlans = _mockPlans;
    _applyFilters();
  }

  void _applyFilters([PlanFilter? filter]) {
    List<WorkoutPlan> filteredPlans = _allPlans;

    if (filter != null && !filter.isEmpty) {
      // Apply search query
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        filteredPlans = filteredPlans.where((plan) =>
          plan.name.toLowerCase().contains(query) ||
          plan.description.toLowerCase().contains(query)
        ).toList();
      }

      // Apply duration filters
      if (filter.minDurationWeeks != null) {
        filteredPlans = filteredPlans.where((plan) => plan.weeks >= filter.minDurationWeeks!).toList();
      }
      if (filter.maxDurationWeeks != null) {
        filteredPlans = filteredPlans.where((plan) => plan.weeks <= filter.maxDurationWeeks!).toList();
      }

      // Apply days per week filters
      if (filter.minDaysPerWeek != null) {
        filteredPlans = filteredPlans.where((plan) => plan.daysPerWeek >= filter.minDaysPerWeek!).toList();
      }
      if (filter.maxDaysPerWeek != null) {
        filteredPlans = filteredPlans.where((plan) => plan.daysPerWeek <= filter.maxDaysPerWeek!).toList();
      }

      // Apply difficulty filters
      if (filter.difficultyLevels != null && filter.difficultyLevels!.isNotEmpty) {
        filteredPlans = filteredPlans.where((plan) => filter.difficultyLevels!.contains(plan.difficultyText)).toList();
      }

      // Apply equipment filters
      if (filter.equipment != null && filter.equipment!.isNotEmpty) {
        filteredPlans = filteredPlans.where((plan) =>
          filter.equipment!.any((eq) => plan.requiredEquipment.contains(eq))
        ).toList();
      }

      // Apply goals filters
      if (filter.goals != null && filter.goals!.isNotEmpty) {
        filteredPlans = filteredPlans.where((plan) =>
          filter.goals!.any((goal) => plan.targetGoals.contains(goal))
        ).toList();
      }

      // Apply sorting
      if (filter.sortBy != null) {
        switch (filter.sortBy!) {
          case SortBy.popular:
            filteredPlans.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
            break;
          case SortBy.newest:
            filteredPlans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            break;
          case SortBy.highestRated:
            filteredPlans.sort((a, b) => b.rating.compareTo(a.rating));
            break;
          case SortBy.duration:
            filteredPlans.sort((a, b) => a.estimatedDuration.compareTo(b.estimatedDuration));
            break;
        }
      }
    }

    final paginatedPlans = filteredPlans.skip(_currentPage * _pageSize).take(_pageSize).toList();
    state = AsyncValue.data(paginatedPlans);
  }

  Future<void> loadMore() async {
    if (_isLoading) return;
    _isLoading = true;

    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    _currentPage++;
    _applyFilters();
    _isLoading = false;
  }

  Future<void> refresh() async {
    _currentPage = 0;
    await _loadPlans();
  }

  void addPlan(WorkoutPlan plan) {
    _allPlans = [plan, ..._allPlans];
    _applyFilters();
  }

  Future<WorkoutPlan?> generateAIPlan({
    required String goals,
    required String sport,
    required int duration,
    required List<String> equipment,
  }) async {
    state = const AsyncValue.loading();

    // Simulate AI generation
    await Future.delayed(const Duration(seconds: 3));

    final newPlan = WorkoutPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'AI Generated: $goals Plan',
      description: 'Custom plan generated for $goals in $sport',
      authorId: 'ai-coach',
      authorName: 'AI Coach',
      category: PlanCategory.custom,
      type: PlanType.custom,
      weeks: duration,
      daysPerWeek: 4,
      difficulty: 3,
      targetGoals: [goals],
      requiredEquipment: equipment,
      estimatedDuration: const Duration(minutes: 45),
      workoutDays: [],
      rating: 0,
      reviewCount: 0,
      createdAt: DateTime.now(),
      imageUrl: 'https://example.com/ai-generated.jpg',
    );

    addPlan(newPlan);
    return newPlan;
  }

  List<WorkoutPlan> getRecommendedPlans() {
    // Mock AI recommendation logic
    return _allPlans.where((plan) => plan.rating >= 4).take(3).toList();
  }

  List<WorkoutPlan> getMyPlans() {
    // Mock user's saved/active plans
    return _allPlans.take(2).toList();
  }

  List<WorkoutPlan> getPopularTemplates() {
    return _allPlans.where((plan) => plan.isPublic).toList();
  }

  void applyFilters(PlanFilter filter) {
    _currentPage = 0;
    _applyFilters(filter);
  }
}

// Filtered plans provider that combines workout plans with filters
final filteredWorkoutPlansProvider = StateNotifierProvider<WorkoutPlansNotifier, AsyncValue<List<WorkoutPlan>>>((ref) {
  return WorkoutPlansNotifier();
});

// Separate providers for different sections
final recommendedPlansProvider = Provider<List<WorkoutPlan>>((ref) {
  final plansAsync = ref.watch(filteredWorkoutPlansProvider);
  return plansAsync.maybeWhen(
    data: (plans) => plans.where((plan) => plan.rating >= 4).take(3).toList(),
    orElse: () => [],
  );
});

final myPlansProvider = Provider<List<WorkoutPlan>>((ref) {
  // Mock user's plans - in real app, this would come from user data
  final plansAsync = ref.watch(filteredWorkoutPlansProvider);
  return plansAsync.maybeWhen(
    data: (plans) => plans.take(2).toList(),
    orElse: () => [],
  );
});

final popularTemplatesProvider = Provider<List<WorkoutPlan>>((ref) {
  final plansAsync = ref.watch(filteredWorkoutPlansProvider);
  return plansAsync.maybeWhen(
    data: (plans) => plans.where((plan) => plan.isPublic).toList(),
    orElse: () => [],
  );
});

// Keep the original provider for backward compatibility
final workoutPlansProvider = StateNotifierProvider<WorkoutPlansNotifier, AsyncValue<List<WorkoutPlan>>>((ref) {
  return WorkoutPlansNotifier();
});
