import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import 'lottie_switch.dart';

class SettingsDataPrivacySection extends StatelessWidget {
  final AppSettings settings;
  final Function(bool) onDataSyncChanged;
  final Function(bool) onOfflineModeChanged;
  final Function(bool) onAnalyticsChanged;
  final Function(bool) onPersonalizedAIChanged;
  final VoidCallback onDownloadData;
  final VoidCallback onDeleteAccount;

  const SettingsDataPrivacySection({
    super.key,
    required this.settings,
    required this.onDataSyncChanged,
    required this.onOfflineModeChanged,
    required this.onAnalyticsChanged,
    required this.onPersonalizedAIChanged,
    required this.onDownloadData,
    required this.onDeleteAccount,
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
              '🔒 DATA & PRIVACY',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Data Sync
            _buildToggleSetting(
              context,
              'Data Sync',
              'Sync data across devices',
              settings.dataSync,
              onDataSyncChanged,
            ),

            if (settings.dataSync && settings.lastSyncTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last synced: ${_formatDateTime(settings.lastSyncTime!)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Offline Mode
            _buildToggleSetting(
              context,
              'Offline Mode',
              'Cache workouts for offline access',
              settings.offlineMode,
              onOfflineModeChanged,
            ),

            const SizedBox(height: 16),

            // Analytics
            _buildToggleSetting(
              context,
              'Analytics & Crash Reports',
              'Help improve the app',
              settings.analyticsEnabled,
              onAnalyticsChanged,
            ),

            const SizedBox(height: 16),

            // Personalized AI
            _buildToggleSetting(
              context,
              'Personalized AI Recommendations',
              'Use workout data for insights',
              settings.personalizedAI,
              onPersonalizedAIChanged,
            ),

            const SizedBox(height: 20),

            // Data Usage
            Text(
              'Data Usage',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            _buildDataUsageItem('Workouts', '45.2 MB'),
            const SizedBox(height: 8),
            _buildDataUsageItem('Photos', '128.5 MB'),
            const SizedBox(height: 8),
            _buildDataUsageItem('Cache', '23.1 MB'),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('CLEAR CACHE'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.storage),
                    label: const Text('OPTIMIZE STORAGE'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Download Data
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDownloadData,
                icon: const Icon(Icons.download),
                label: const Text('DOWNLOAD MY DATA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Export all data as JSON/CSV',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Delete Account
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This action is irreversible. All your data will be permanently deleted.',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onDeleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('DELETE MY ACCOUNT'),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildDataUsageItem(String category, String size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          category,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          size,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
