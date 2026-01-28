import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan_filter.dart';

class FilterNotifier extends StateNotifier<PlanFilter> {
  FilterNotifier() : super(const PlanFilter());

  void updateFilter(PlanFilter newFilter) {
    state = newFilter;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDurationRange(int minWeeks, int maxWeeks) {
    state = state.copyWith(
      minDurationWeeks: minWeeks,
      maxDurationWeeks: maxWeeks,
    );
  }

  void setDaysPerWeekRange(int minDays, int maxDays) {
    state = state.copyWith(
      minDaysPerWeek: minDays,
      maxDaysPerWeek: maxDays,
    );
  }

  void setDifficultyLevels(List<String> levels) {
    state = state.copyWith(difficultyLevels: levels);
  }

  void setEquipment(List<String> equipment) {
    state = state.copyWith(equipment: equipment);
  }

  void setGoals(List<String> goals) {
    state = state.copyWith(goals: goals);
  }

  void setSortBy(SortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void clearFilters() {
    state = const PlanFilter();
  }

  void toggleDifficulty(String level) {
    final current = state.difficultyLevels ?? [];
    final updated = current.contains(level)
        ? current.where((l) => l != level).toList()
        : [...current, level];
    state = state.copyWith(difficultyLevels: updated);
  }

  void toggleEquipment(String item) {
    final current = state.equipment ?? [];
    final updated = current.contains(item)
        ? current.where((e) => e != item).toList()
        : [...current, item];
    state = state.copyWith(equipment: updated);
  }

  void toggleGoal(String goal) {
    final current = state.goals ?? [];
    final updated = current.contains(goal)
        ? current.where((g) => g != goal).toList()
        : [...current, goal];
    state = state.copyWith(goals: updated);
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, PlanFilter>((ref) {
  return FilterNotifier();
});
