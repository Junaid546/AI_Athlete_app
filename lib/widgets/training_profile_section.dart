import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class TrainingProfileSection extends StatefulWidget {
  final UserProfile userProfile;
  final Function(String, dynamic) onFieldEdit;
  final Function(UserRole) onRoleSwitch;

  const TrainingProfileSection({
    super.key,
    required this.userProfile,
    required this.onFieldEdit,
    required this.onRoleSwitch,
  });

  @override
  State<TrainingProfileSection> createState() => _TrainingProfileSectionState();
}

class _TrainingProfileSectionState extends State<TrainingProfileSection> {
  late List<String> selectedGoals;
  late List<String> selectedEquipment;
  late List<bool> trainingDays;

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

  @override
  void initState() {
    super.initState();
    selectedGoals = List.from(widget.userProfile.trainingGoals);
    selectedEquipment = List.from(widget.userProfile.availableEquipment);
    trainingDays = List.generate(7, (index) => _isTrainingDay(index));
  }

  bool _isTrainingDay(int index) {
    // For demo: Mon, Tue, Thu, Fri, Sat are training days
    return [0, 1, 3, 4, 5].contains(index);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏋️ TRAINING PROFILE',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Role
            _buildRoleField(context),

            const SizedBox(height: 16),

            // Primary Sport
            _buildPrimarySportField(context),

            const SizedBox(height: 16),

            // Secondary Sports
            _buildSecondarySportsField(context),

            const SizedBox(height: 16),

            // Experience Level
            _buildExperienceLevelField(context),

            const SizedBox(height: 16),

            // Training Goals
            _buildTrainingGoalsField(context),

            const SizedBox(height: 16),

            // Preferred Training Days
            _buildTrainingDaysField(context),

            const SizedBox(height: 16),

            // Session Duration
            _buildSessionDurationField(context),

            const SizedBox(height: 16),

            // Preferred Training Time
            _buildTrainingTimeField(context),

            const SizedBox(height: 16),

            // Available Equipment
            _buildEquipmentField(context),

            const SizedBox(height: 16),

            // Injuries/Limitations
            _buildInjuriesField(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.userProfile.role == UserRole.athlete
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.userProfile.role == UserRole.athlete
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎯'),
                    const SizedBox(width: 8),
                    Text(
                      'Athlete',
                      style: TextStyle(
                        color: widget.userProfile.role == UserRole.athlete
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {
                final newRole = widget.userProfile.role == UserRole.athlete
                    ? UserRole.coach
                    : UserRole.athlete;
                widget.onRoleSwitch(newRole);
              },
              child: Text(
                'Switch to ${widget.userProfile.role == UserRole.athlete ? 'Coach' : 'Athlete'} Mode',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimarySportField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Sport',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: widget.userProfile.primarySport ?? 'Powerlifting',
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: [
            'Powerlifting',
            'Bodybuilding',
            'CrossFit',
            'Weightlifting',
            'Strongman',
            'Running',
            'Cycling',
            'Swimming',
            'Basketball',
            'Football',
            'Tennis',
            'Boxing',
            'Martial Arts',
            'Yoga',
            'Pilates',
          ].map((sport) {
            return DropdownMenuItem(
              value: sport,
              child: Text(sport),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onFieldEdit('primarySport', value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSecondarySportsField(BuildContext context) {
    final secondarySports = widget.userProfile.secondarySports.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Secondary Sports',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  secondarySports.isEmpty ? 'Bodybuilding, CrossFit' : secondarySports,
                  style: TextStyle(
                    color: secondarySports.isEmpty ? Colors.grey.shade500 : Colors.black,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                // Open multi-select dialog
                _showSecondarySportsDialog(context);
              },
              icon: const Icon(Icons.edit, size: 20),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceLevelField(BuildContext context) {
    final experienceLevel = widget.userProfile.experienceLevel;
    final levelIndex = ExperienceLevel.values.indexOf(experienceLevel);
    final levelNames = ['Beginner', 'Novice', 'Intermediate', 'Advanced', 'Elite'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Level',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('━━━━━●━━━━', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(
              '${levelNames[levelIndex]} (${widget.userProfile.yearsTraining ?? 6} years)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: levelNames.map((level) {
            final isSelected = level == levelNames[levelIndex];
            return Text(
              level,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Slider(
          value: levelIndex.toDouble(),
          min: 0,
          max: 4,
          divisions: 4,
          onChanged: (value) {
            final newLevel = ExperienceLevel.values[value.toInt()];
            widget.onFieldEdit('experienceLevel', newLevel);
          },
        ),
      ],
    );
  }

  Widget _buildTrainingGoalsField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Goals (Multi-select)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
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
              backgroundColor: Colors.grey.shade100,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTrainingDaysField(BuildContext context) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final selectedCount = trainingDays.where((day) => day).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Training Days',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  trainingDays[index] = !trainingDays[index];
                });
                // Update training frequency based on selected days
                final frequency = _getTrainingFrequency(selectedCount);
                widget.onFieldEdit('trainingFrequency', frequency);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: trainingDays[index]
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      color: trainingDays[index] ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(7, (index) {
            return Expanded(
              child: Text(
                trainingDays[index] ? '✓' : '-',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: trainingDays[index]
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          '$selectedCount days per week',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionDurationField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Duration Preference',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<SessionDuration>(
          initialValue: widget.userProfile.sessionDuration,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: SessionDuration.values.map((duration) {
            return DropdownMenuItem(
              value: duration,
              child: Text(_getDurationDisplayName(duration)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onFieldEdit('sessionDuration', value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTrainingTimeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Training Time',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<PreferredTime>(
          initialValue: widget.userProfile.preferredTime,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: PreferredTime.values.map((time) {
            return DropdownMenuItem(
              value: time,
              child: Text(_getTimeDisplayName(time)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onFieldEdit('preferredTime', value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildEquipmentField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Equipment',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableEquipment.map((equipment) {
            final isSelected = selectedEquipment.contains(equipment);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getEquipmentIcon(equipment)),
                  const SizedBox(width: 4),
                  Text(equipment),
                ],
              ),
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
              backgroundColor: Colors.grey.shade100,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInjuriesField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Injuries/Limitations (Optional)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: widget.userProfile.injuriesLimitations.join('\n'),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Previous lower back injury, avoid heavy overhead pressing...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (value) {
            widget.onFieldEdit('injuriesLimitations', [value]);
          },
        ),
      ],
    );
  }

  void _showSecondarySportsDialog(BuildContext context) {
    final tempSelected = List<String>.from(widget.userProfile.secondarySports);
    final sports = [
      'Bodybuilding',
      'CrossFit',
      'Weightlifting',
      'Strongman',
      'Running',
      'Cycling',
      'Swimming',
      'Basketball',
      'Football',
      'Tennis',
      'Boxing',
      'Martial Arts',
      'Yoga',
      'Pilates',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Secondary Sports'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sports.map((sport) {
                final isSelected = tempSelected.contains(sport);
                return CheckboxListTile(
                  title: Text(sport),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        tempSelected.add(sport);
                      } else {
                        tempSelected.remove(sport);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onFieldEdit('secondarySports', tempSelected);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  TrainingFrequency _getTrainingFrequency(int days) {
    switch (days) {
      case 1:
        return TrainingFrequency.oneDay;
      case 2:
        return TrainingFrequency.twoDays;
      case 3:
        return TrainingFrequency.threeDays;
      case 4:
        return TrainingFrequency.fourDays;
      case 5:
        return TrainingFrequency.fiveDays;
      case 6:
        return TrainingFrequency.sixDays;
      case 7:
        return TrainingFrequency.sevenDays;
      default:
        return TrainingFrequency.threeDays;
    }
  }

  String _getDurationDisplayName(SessionDuration duration) {
    switch (duration) {
      case SessionDuration.thirtyMin:
        return '30 minutes';
      case SessionDuration.fortyFiveMin:
        return '45 minutes';
      case SessionDuration.sixtyMin:
        return '60 minutes';
      case SessionDuration.ninetyMin:
        return '90 minutes';
    }
  }

  String _getTimeDisplayName(PreferredTime time) {
    switch (time) {
      case PreferredTime.morning:
        return '🌅 Morning';
      case PreferredTime.afternoon:
        return '☀️ Afternoon';
      case PreferredTime.evening:
        return '🌙 Evening';
    }
  }

  String _getEquipmentIcon(String equipment) {
    switch (equipment) {
      case 'Full Gym':
        return '🏋️';
      case 'Barbell':
        return '🏋️';
      case 'Dumbbells':
        return '🏋️';
      case 'Machines':
        return '⚙️';
      case 'Resistance Bands':
        return '🔗';
      case 'Minimal/Bodyweight':
        return '💪';
      default:
        return '🏋️';
    }
  }
}
