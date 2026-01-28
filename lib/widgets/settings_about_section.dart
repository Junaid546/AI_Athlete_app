import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class SettingsAboutSection extends StatelessWidget {
  final AppSettings settings;

  const SettingsAboutSection({
    super.key,
    required this.settings,
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
              'ℹ️ ABOUT',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Add about content here
            Text('About the app placeholder'),
          ],
        ),
      ),
    );
  }
}
