import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import 'lottie_switch.dart';

class SettingsWorkoutPreferencesSection extends StatelessWidget {
  final AppSettings settings;
  final Function(TrainingPreferences) onTrainingPreferencesChanged;

  const SettingsWorkoutPreferencesSection({
    super.key,
    required this.settings,
    required this.onTrainingPreferencesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏋️ WORKOUT PREFERENCES',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Default Weight Unit
            _buildUnitSelector(
              context,
              'Default Weight Unit',
              ['⚖️ Kilograms', 'Pounds'],
              settings.training.defaultWeightUnit == 'kg' ? 0 : 1,
              (index) => _updateTrainingPreference('defaultWeightUnit', index == 0 ? 'kg' : 'lbs'),
            ),

            const SizedBox(height: 16),

            // Default Distance Unit
            _buildUnitSelector(
              context,
              'Default Distance Unit',
              ['📏 Kilometers', 'Miles'],
              settings.training.defaultDistanceUnit == 'km' ? 0 : 1,
              (index) => _updateTrainingPreference('defaultDistanceUnit', index == 0 ? 'km' : 'mi'),
            ),

            const SizedBox(height: 20),

            // Rest Timer Defaults
            Text(
              'Rest Timer Defaults',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            _buildRestTimerSetting(context, 'Strength', settings.training.strengthRestTimer),
            const SizedBox(height: 8),
            _buildRestTimerSetting(context, 'Hypertrophy', settings.training.hypertrophyRestTimer),
            const SizedBox(height: 8),
            _buildRestTimerSetting(context, 'Endurance', settings.training.enduranceRestTimer),

            const SizedBox(height: 16),

            // Auto-start Rest Timer
            _buildToggleSetting(
              context,
              'Auto-start Rest Timer',
              'Automatically start rest timer after each set',
              settings.training.autoStartRestTimer,
              (value) => _updateTrainingPreference('autoStartRestTimer', value),
            ),

            const SizedBox(height: 16),

            // Rest Timer Sound
            _buildToggleSetting(
              context,
              'Rest Timer Sound',
              'Alert when rest complete',
              settings.training.restTimerSound,
              (value) => _updateTrainingPreference('restTimerSound', value),
            ),

            const SizedBox(height: 16),

            // Vibration Feedback
            _buildToggleSetting(
              context,
              'Vibration Feedback',
              'Haptic feedback during workouts',
              settings.training.vibrationFeedback,
              (value) => _updateTrainingPreference('vibrationFeedback', value),
            ),

            const SizedBox(height: 16),

            // Voice Guidance
            _buildToggleSetting(
              context,
              'Voice Guidance',
              '"Next set", "Rest complete" announcements',
              settings.training.voiceGuidance,
              (value) => _updateTrainingPreference('voiceGuidance', value),
            ),

            const SizedBox(height: 16),

            // Keep Screen On
            _buildToggleSetting(
              context,
              'Keep Screen On During Workout',
              'Prevent screen from turning off',
              settings.training.keepScreenOn,
              (value) => _updateTrainingPreference('keepScreenOn', value),
            ),

            const SizedBox(height: 16),

            // Show Exercise Videos
            _buildToggleSetting(
              context,
              'Show Exercise Videos',
              'Auto-play demonstration videos',
              settings.training.showExerciseVideos,
              (value) => _updateTrainingPreference('showExerciseVideos', value),
            ),

            const SizedBox(height: 20),

            // Music Integration
            Text(
              'Workout Music Integration',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            _buildMusicService(context, 'Spotify', settings.training.connectedMusicServices.contains('spotify')),
            const SizedBox(height: 8),
            _buildMusicService(context, 'Apple Music', settings.training.connectedMusicServices.contains('apple_music')),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitSelector(BuildContext context, String title, List<String> options, int selectedIndex, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = index == selectedIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRestTimerSetting(BuildContext context, String type, Duration duration) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '• $type:',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            _formatDuration(duration),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => _showDurationPicker(context, type, duration),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
          ),
          child: Text(
            'Edit',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSetting(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        LottieSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMusicService(BuildContext context, String service, bool isConnected) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            service == 'Spotify' ? '🎵' : '🍎',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Connected',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: () => _connectMusicService(service),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Connect'),
            ),
        ],
      ),
    );
  }

  void _updateTrainingPreference(String field, dynamic value) {
    final updatedTraining = TrainingPreferences(
      defaultWeightUnit: field == 'defaultWeightUnit' ? value : settings.training.defaultWeightUnit,
      defaultDistanceUnit: field == 'defaultDistanceUnit' ? value : settings.training.defaultDistanceUnit,
      strengthRestTimer: settings.training.strengthRestTimer,
      hypertrophyRestTimer: settings.training.hypertrophyRestTimer,
      enduranceRestTimer: settings.training.enduranceRestTimer,
      autoStartRestTimer: field == 'autoStartRestTimer' ? value : settings.training.autoStartRestTimer,
      restTimerSound: field == 'restTimerSound' ? value : settings.training.restTimerSound,
      vibrationFeedback: field == 'vibrationFeedback' ? value : settings.training.vibrationFeedback,
      voiceGuidance: field == 'voiceGuidance' ? value : settings.training.voiceGuidance,
      keepScreenOn: field == 'keepScreenOn' ? value : settings.training.keepScreenOn,
      showExerciseVideos: field == 'showExerciseVideos' ? value : settings.training.showExerciseVideos,
      connectedMusicServices: settings.training.connectedMusicServices,
    );
    onTrainingPreferencesChanged(updatedTraining);
  }

  void _showDurationPicker(BuildContext context, String type, Duration currentDuration) async {
    final minutes = currentDuration.inMinutes;
    final seconds = currentDuration.inSeconds % 60;

    int selectedMinutes = minutes;
    int selectedSeconds = seconds;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set $type Rest Timer'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minutes
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Minutes'),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: selectedMinutes.toString(),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => selectedMinutes = int.tryParse(value) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            // Seconds
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Seconds'),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: selectedSeconds.toString(),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => selectedSeconds = int.tryParse(value) ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newDuration = Duration(minutes: selectedMinutes, seconds: selectedSeconds);
              // Update the specific timer based on type
              _updateRestTimer(type, newDuration);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateRestTimer(String type, Duration duration) {
    late TrainingPreferences updatedTraining;

    switch (type) {
      case 'Strength':
        updatedTraining = settings.training.copyWith(strengthRestTimer: duration);
        break;
      case 'Hypertrophy':
        updatedTraining = settings.training.copyWith(hypertrophyRestTimer: duration);
        break;
      case 'Endurance':
        updatedTraining = settings.training.copyWith(enduranceRestTimer: duration);
        break;
      default:
        return;
    }

    onTrainingPreferencesChanged(updatedTraining);
  }

  void _connectMusicService(String service) {
    final serviceId = service.toLowerCase().replaceAll(' ', '_');
    final updatedServices = List<String>.from(settings.training.connectedMusicServices);
    if (!updatedServices.contains(serviceId)) {
      updatedServices.add(serviceId);
      final updatedTraining = settings.training.copyWith(connectedMusicServices: updatedServices);
      onTrainingPreferencesChanged(updatedTraining);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} mins';
  }
}
