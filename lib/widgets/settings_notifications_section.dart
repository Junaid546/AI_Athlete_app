import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import 'lottie_switch.dart';

class SettingsNotificationsSection extends StatelessWidget {
  final AppSettings settings;
  final Function(NotificationSettings) onNotificationsChanged;

  const SettingsNotificationsSection({
    super.key,
    required this.settings,
    required this.onNotificationsChanged,
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
              '🔔 NOTIFICATIONS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Push Notifications
            _buildToggleSetting(
              context,
              'Push Notifications',
              'Receive push notifications on your device',
              settings.notifications.pushNotifications,
              (value) => _updateNotification('pushNotifications', value),
            ),

            const SizedBox(height: 16),

            // Workout Reminders
            _buildTimeSetting(
              context,
              'Workout Reminders',
              'Get reminded to start your workouts',
              settings.notifications.workoutReminders,
              settings.notifications.workoutReminderTime,
              (value) => _updateNotification('workoutReminders', value),
              (time) => _updateWorkoutReminderTime(time),
            ),

            const SizedBox(height: 16),

            // Streak Alerts
            _buildToggleSetting(
              context,
              'Streak Alerts',
              'Notify when your workout streak is at risk',
              settings.notifications.streakAlerts,
              (value) => _updateNotification('streakAlerts', value),
            ),

            const SizedBox(height: 16),

            // AI Insights
            _buildToggleSetting(
              context,
              'AI Insights',
              'Daily personalized training tips and insights',
              settings.notifications.aiInsights,
              (value) => _updateNotification('aiInsights', value),
            ),

            const SizedBox(height: 16),

            // Achievement Unlocks
            _buildToggleSetting(
              context,
              'Achievement Unlocks',
              'Celebrate when you unlock new badges',
              settings.notifications.achievementUnlocks,
              (value) => _updateNotification('achievementUnlocks', value),
            ),

            const SizedBox(height: 16),

            // Coach Messages
            _buildToggleSetting(
              context,
              'Coach Messages',
              'Notifications for messages from your coach',
              settings.notifications.coachMessages,
              (value) => _updateNotification('coachMessages', value),
            ),

            const SizedBox(height: 16),

            // PR Celebrations
            _buildToggleSetting(
              context,
              'PR Celebrations',
              'Confetti animation on personal records',
              settings.notifications.prCelebrations,
              (value) => _updateNotification('prCelebrations', value),
            ),

            const SizedBox(height: 16),

            // Social Updates
            _buildToggleSetting(
              context,
              'Social Updates',
              'Friend workouts, comments, and mentions',
              settings.notifications.socialUpdates,
              (value) => _updateNotification('socialUpdates', value),
            ),

            const SizedBox(height: 16),

            // Email Notifications
            _buildToggleSetting(
              context,
              'Email Notifications',
              'Weekly summary reports via email',
              settings.notifications.emailNotifications,
              (value) => _updateNotification('emailNotifications', value),
            ),

            const SizedBox(height: 20),

            // Notification Sound
            _buildSoundSelector(context),

            const SizedBox(height: 16),

            // Do Not Disturb
            _buildDoNotDisturbSetting(context),
          ],
        ),
      ),
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

  Widget _buildTimeSetting(
    BuildContext context,
    String title,
    String subtitle,
    bool enabled,
    TimeOfDay time,
    Function(bool) onToggleChanged,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              value: enabled,
              onChanged: onToggleChanged,
            ),
          ],
        ),
        if (enabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Time:',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (pickedTime != null) {
                    onTimeChanged(pickedTime);
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  _formatTime(time),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSoundSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Sound',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<NotificationSound>(
              value: settings.notifications.notificationSound,
              isExpanded: true,
              items: NotificationSound.values.map((sound) {
                return DropdownMenuItem(
                  value: sound,
                  child: Text(
                    _getSoundDisplayName(sound),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateNotificationSound(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoNotDisturbSetting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Do Not Disturb',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.nightlight_round, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_formatTime(settings.notifications.doNotDisturbStart)} - ${_formatTime(settings.notifications.doNotDisturbEnd)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showDoNotDisturbDialog(context),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateNotification(String field, dynamic value) {

    // In a real implementation, you'd use reflection or a switch statement
    // For now, we'll create a new instance with the updated field
    onNotificationsChanged(
      NotificationSettings(
        pushNotifications: field == 'pushNotifications' ? value : settings.notifications.pushNotifications,
        workoutReminders: field == 'workoutReminders' ? value : settings.notifications.workoutReminders,
        workoutReminderTime: settings.notifications.workoutReminderTime,
        streakAlerts: field == 'streakAlerts' ? value : settings.notifications.streakAlerts,
        aiInsights: field == 'aiInsights' ? value : settings.notifications.aiInsights,
        achievementUnlocks: field == 'achievementUnlocks' ? value : settings.notifications.achievementUnlocks,
        coachMessages: field == 'coachMessages' ? value : settings.notifications.coachMessages,
        prCelebrations: field == 'prCelebrations' ? value : settings.notifications.prCelebrations,
        socialUpdates: field == 'socialUpdates' ? value : settings.notifications.socialUpdates,
        emailNotifications: field == 'emailNotifications' ? value : settings.notifications.emailNotifications,
        notificationSound: settings.notifications.notificationSound,
        doNotDisturbStart: settings.notifications.doNotDisturbStart,
        doNotDisturbEnd: settings.notifications.doNotDisturbEnd,
      ),
    );
  }

  void _updateWorkoutReminderTime(TimeOfDay time) {
    final updatedNotifications = settings.notifications.copyWith(workoutReminderTime: time);
    onNotificationsChanged(updatedNotifications);
  }

  void _updateNotificationSound(NotificationSound sound) {
    final updatedNotifications = settings.notifications.copyWith(notificationSound: sound);
    onNotificationsChanged(updatedNotifications);
  }

  void _showDoNotDisturbDialog(BuildContext context) async {
    TimeOfDay startTime = settings.notifications.doNotDisturbStart;
    TimeOfDay endTime = settings.notifications.doNotDisturbEnd;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Do Not Disturb Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Time'),
              trailing: Text(_formatTime(startTime)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (picked != null) {
                  startTime = picked;
                  (context as Element).markNeedsBuild();
                }
              },
            ),
            ListTile(
              title: const Text('End Time'),
              trailing: Text(_formatTime(endTime)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: endTime,
                );
                if (picked != null) {
                  endTime = picked;
                  (context as Element).markNeedsBuild();
                }
              },
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
              final updatedNotifications = settings.notifications.copyWith(
                doNotDisturbStart: startTime,
                doNotDisturbEnd: endTime,
              );
              onNotificationsChanged(updatedNotifications);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getSoundDisplayName(NotificationSound sound) {
    switch (sound) {
      case NotificationSound.defaultSound:
        return 'Default';
      case NotificationSound.none:
        return 'None';
    }
  }
}
