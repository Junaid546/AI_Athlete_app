import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import 'lottie_switch.dart';

class SocialSection extends StatelessWidget {
  final UserProfile userProfile;
  final Function(String, dynamic) onFieldEdit;

  const SocialSection({
    super.key,
    required this.userProfile,
    required this.onFieldEdit,
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
              '🌐 SOCIAL & PRIVACY',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Profile Visibility
            _buildVisibilitySetting(context),

            const SizedBox(height: 16),

            // Show Stats on Profile
            _buildStatsVisibilitySetting(context),

            const SizedBox(height: 16),

            // Allow Friend Requests
            _buildFriendRequestsSetting(context),

            const SizedBox(height: 16),

            // Share Workouts Automatically
            _buildAutoShareSetting(context),

            const SizedBox(height: 24),

            // Connected Accounts
            Text(
              'Connected Accounts',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            _buildConnectedAccount(
              context,
              'Strava',
              'strava',
              isConnected: true,
              icon: '🏃',
            ),

            const SizedBox(height: 8),

            _buildConnectedAccount(
              context,
              'Apple Health',
              'apple_health',
              isConnected: false,
              icon: '🍎',
            ),

            const SizedBox(height: 8),

            _buildConnectedAccount(
              context,
              'Google Fit',
              'google_fit',
              isConnected: false,
              icon: '🔵',
            ),

            const SizedBox(height: 8),

            _buildConnectedAccount(
              context,
              'MyFitnessPal',
              'myfitnesspal',
              isConnected: false,
              icon: '📊',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilitySetting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Visibility',
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
            child: DropdownButton<String>(
              value: 'public',
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: 'public',
                  child: Row(
                    children: [
                      const Text('🌍'),
                      const SizedBox(width: 8),
                      Text(
                        'Public',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'friends',
                  child: Row(
                    children: [
                      const Text('👥'),
                      const SizedBox(width: 8),
                      Text(
                        'Friends Only',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'private',
                  child: Row(
                    children: [
                      const Text('🔒'),
                      const SizedBox(width: 8),
                      Text(
                        'Private',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                // Handle visibility change
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsVisibilitySetting(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Show Stats on Profile',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Display workout statistics to other users',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        LottieSwitch(
          value: true,
          onChanged: (value) {
            // Handle stats visibility toggle
          },
        ),
      ],
    );
  }

  Widget _buildFriendRequestsSetting(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Allow Friend Requests',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Let other users send you friend requests',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        LottieSwitch(
          value: true,
          onChanged: (value) {
            // Handle friend requests toggle
          },
        ),
      ],
    );
  }

  Widget _buildAutoShareSetting(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Workouts Automatically',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Auto-post completed workouts to your feed',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        LottieSwitch(
          value: false,
          onChanged: (value) {
            // Handle auto-share toggle
          },
        ),
      ],
    );
  }

  Widget _buildConnectedAccount(BuildContext context, String name, String id, {required bool isConnected, required String icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
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
              onPressed: () {
                // Handle connect
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Connect'),
            ),
          if (isConnected)
            TextButton(
              onPressed: () {
                // Handle disconnect
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Disconnect'),
            ),
        ],
      ),
    );
  }
}
