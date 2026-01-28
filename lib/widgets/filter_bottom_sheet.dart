import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../models/plan_filter.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late PlanFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = ref.read(filterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(filterProvider.notifier).clearFilters();
                  Navigator.of(context).pop();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Duration range
          const Text('Duration (weeks)', style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: RangeValues(
              _currentFilter.minDurationWeeks?.toDouble() ?? 1,
              _currentFilter.maxDurationWeeks?.toDouble() ?? 52,
            ),
            min: 1,
            max: 52,
            divisions: 51,
            labels: RangeLabels(
              _currentFilter.minDurationWeeks?.toString() ?? '1',
              _currentFilter.maxDurationWeeks?.toString() ?? '52',
            ),
            onChanged: (values) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(
                  minDurationWeeks: values.start.toInt(),
                  maxDurationWeeks: values.end.toInt(),
                );
              });
            },
          ),
          const SizedBox(height: 16),
          // Days per week
          const Text('Days per week', style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: RangeValues(
              _currentFilter.minDaysPerWeek?.toDouble() ?? 1,
              _currentFilter.maxDaysPerWeek?.toDouble() ?? 7,
            ),
            min: 1,
            max: 7,
            divisions: 6,
            labels: RangeLabels(
              _currentFilter.minDaysPerWeek?.toString() ?? '1',
              _currentFilter.maxDaysPerWeek?.toString() ?? '7',
            ),
            onChanged: (values) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(
                  minDaysPerWeek: values.start.toInt(),
                  maxDaysPerWeek: values.end.toInt(),
                );
              });
            },
          ),
          const SizedBox(height: 16),
          // Difficulty
          const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: ['Beginner', 'Intermediate', 'Advanced', 'Elite'].map((level) {
              final isSelected = _currentFilter.difficultyLevels?.contains(level) ?? false;
              return FilterChip(
                label: Text(level),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final current = _currentFilter.difficultyLevels ?? [];
                    if (selected) {
                      _currentFilter = _currentFilter.copyWith(
                        difficultyLevels: [...current, level],
                      );
                    } else {
                      _currentFilter = _currentFilter.copyWith(
                        difficultyLevels: current.where((l) => l != level).toList(),
                      );
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Equipment
          const Text('Equipment', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: ['Dumbbells', 'Barbell', 'Bench', 'Yoga mat', 'None'].map((equipment) {
              final isSelected = _currentFilter.equipment?.contains(equipment) ?? false;
              return FilterChip(
                label: Text(equipment),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final current = _currentFilter.equipment ?? [];
                    if (selected) {
                      _currentFilter = _currentFilter.copyWith(
                        equipment: [...current, equipment],
                      );
                    } else {
                      _currentFilter = _currentFilter.copyWith(
                        equipment: current.where((e) => e != equipment).toList(),
                      );
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Goals
          const Text('Goals', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: ['Build muscle', 'Lose weight', 'Improve endurance', 'Increase strength'].map((goal) {
              final isSelected = _currentFilter.goals?.contains(goal) ?? false;
              return FilterChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final current = _currentFilter.goals ?? [];
                    if (selected) {
                      _currentFilter = _currentFilter.copyWith(
                        goals: [...current, goal],
                      );
                    } else {
                      _currentFilter = _currentFilter.copyWith(
                        goals: current.where((g) => g != goal).toList(),
                      );
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Sort by
          const Text('Sort by', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<SortBy>(
            value: _currentFilter.sortBy ?? SortBy.popular,
            items: SortBy.values.map((sort) {
              return DropdownMenuItem(
                value: sort,
                child: Text(sort.name.replaceAllMapped(
                  RegExp(r'([A-Z])'),
                  (match) => ' ${match.group(1)}',
                ).trim().replaceFirstMapped(
                  RegExp(r'^.'), (match) => match.group(0)!.toUpperCase()
                )),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _currentFilter = _currentFilter.copyWith(sortBy: value);
              });
            },
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(filterProvider.notifier).updateFilter(_currentFilter);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
