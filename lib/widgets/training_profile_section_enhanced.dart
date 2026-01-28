import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

/// Enhanced Training Profile Section with improved slider interactions and better UI
class TrainingProfileSectionEnhanced extends StatefulWidget {
  final UserProfile userProfile;
  final Function(String, dynamic) onFieldEdit;
  final Function(UserRole) onRoleSwitch;

  const TrainingProfileSectionEnhanced({
    super.key,
    required this.userProfile,
    required this.onFieldEdit,
    required this.onRoleSwitch,
  });

  @override
  State<TrainingProfileSectionEnhanced> createState() => _TrainingProfileSectionEnhancedState();
}

class _TrainingProfileSectionEnhancedState extends State<TrainingProfileSectionEnhanced> {
  late List<String> selectedGoals;
  late List<String> selectedEquipment;
  late List<bool> trainingDays;
  late double experienceSliderValue;
  late double sessionDurationSliderValue;

  final List<String> availableGoals = [
    'Build Muscle',
    'Increase Strength',
    'Lose Fat',
    'Improve Endurance',
    'Flexibility',
    'Sport Performance',
    'General Fitness',
    'Rehabilitation',
  ];

  final List<String> availableEquipment = [
    'Full Gym',
    'Barbell',
    'Dumbbells',
    'Machines',
    'Resistance Bands',
    'Minimal/Bodyweight',
  ];

  final List<String> levelNames = ['Beginner', 'Novice', 'Intermediate', 'Advanced', 'Elite'];
  final List<String> durationNames = ['30 min', '45 min', '60 min', '90 min', '120 min'];

  @override
  void initState() {
    super.initState();
    selectedGoals = List.from(widget.userProfile.trainingGoals);
    selectedEquipment = List.from(widget.userProfile.availableEquipment);
    trainingDays = List.generate(7, (index) => _isTrainingDay(index));
    experienceSliderValue = ExperienceLevel.values.indexOf(widget.userProfile.experienceLevel).toDouble();
    sessionDurationSliderValue = 2.0; // Default 60 min
  }

  bool _isTrainingDay(int index) {
    return [0, 1, 3, 4, 5].contains(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fitness_center, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                'Training Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Experience Level with improved slider
          _buildExperienceLevelField(context, isDark),
          const SizedBox(height: 20),

          // Session Duration with improved slider
          _buildSessionDurationField(context, isDark),
          const SizedBox(height: 20),

          // Training Goals
          _buildTrainingGoalsField(context, isDark),
          const SizedBox(height: 20),

          // Training Days
          _buildTrainingDaysField(context, isDark),
          const SizedBox(height: 20),

          // Available Equipment
          _buildEquipmentField(context, isDark),
        ],
      ),
    );
  }

  Widget _buildExperienceLevelField(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Experience Level',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                levelNames[experienceSliderValue.toInt()],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Custom slider with better styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBackground : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Slider(
                value: experienceSliderValue,
                min: 0,
                max: 4,
                divisions: 4,
                activeColor: AppTheme.primaryColor,
                inactiveColor: isDark ? Colors.white10 : Colors.grey.shade300,
                onChanged: (value) {
                  setState(() {
                    experienceSliderValue = value;
                  });
                  final newLevel = ExperienceLevel.values[value.toInt()];
                  widget.onFieldEdit('experienceLevel', newLevel);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: levelNames.asMap().entries.map((entry) {
                    final isActive = entry.key == experienceSliderValue.toInt();
                    return Expanded(
                      child: Text(
                        entry.value,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isActive ? AppTheme.primaryColor : Colors.grey,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: isActive ? 12 : 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Info text
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${levelNames[experienceSliderValue.toInt()]} level: ${widget.userProfile.yearsTraining ?? 5} years of experience',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionDurationField(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preferred Session Duration',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                durationNames[sessionDurationSliderValue.toInt()],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Custom slider
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkBackground : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Slider(
                value: sessionDurationSliderValue,
                min: 0,
                max: 4,
                divisions: 4,
                activeColor: Colors.purple,
                inactiveColor: isDark ? Colors.white10 : Colors.grey.shade300,
                onChanged: (value) {
                  setState(() {
                    sessionDurationSliderValue = value;
                  });
                  widget.onFieldEdit('sessionDuration', value.toInt());
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: durationNames.asMap().entries.map((entry) {
                    final isActive = entry.key == sessionDurationSliderValue.toInt();
                    return Expanded(
                      child: Text(
                        entry.value,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isActive ? Colors.purple : Colors.grey,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: isActive ? 12 : 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              'Typically train for ${durationNames[sessionDurationSliderValue.toInt()]} per session',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingGoalsField(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Goals (Multi-select)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableGoals.map((goal) {
            final isSelected = selectedGoals.contains(goal);
            return FilterChip(
              label: Text(goal),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedGoals.add(goal);
                  } else {
                    selectedGoals.remove(goal);
                  }
                });
                widget.onFieldEdit('trainingGoals', selectedGoals);
              },
              backgroundColor: isDark ? AppTheme.darkBackground : Colors.grey.shade100,
              selectedColor: AppTheme.primaryColor.withOpacity(0.15),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTrainingDaysField(BuildContext context, bool isDark) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final selectedCount = trainingDays.where((day) => day).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Training Days',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$selectedCount days/week',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: 7,
          itemBuilder: (context, index) {
            final isSelected = trainingDays[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  trainingDays[index] = !trainingDays[index];
                });
                widget.onFieldEdit('trainingDays', trainingDays);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.withOpacity(0.2) : isDark ? AppTheme.darkBackground : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    dayLabels[index],
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEquipmentField(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Equipment',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableEquipment.map((equipment) {
            final isSelected = selectedEquipment.contains(equipment);
            return InputChip(
              label: Text(equipment),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedEquipment.add(equipment);
                  } else {
                    selectedEquipment.remove(equipment);
                  }
                });
                widget.onFieldEdit('availableEquipment', selectedEquipment);
              },
              backgroundColor: isDark ? AppTheme.darkBackground : Colors.blue.shade50,
              selectedColor: Colors.blue.withOpacity(0.15),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
              ),
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.blue : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
