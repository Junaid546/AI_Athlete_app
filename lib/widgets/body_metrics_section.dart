import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../providers/settings_provider.dart';

class BodyMetricsSection extends ConsumerWidget {
  final UserProfile userProfile;
  final VoidCallback onMeasurementTrack;
  final VoidCallback onViewHistory;

  const BodyMetricsSection({
    super.key,
    required this.userProfile,
    required this.onMeasurementTrack,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isMetric = settings.training.defaultWeightUnit == 'kg';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📏 BODY METRICS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Height
            _buildHeightField(context, isMetric),

            const SizedBox(height: 16),

            // Current Weight
            _buildCurrentWeightField(context, isMetric),

            const SizedBox(height: 16),

            // Target Weight
            _buildTargetWeightField(context, isMetric),

            const SizedBox(height: 16),

            // Body Fat Percentage
            _buildBodyFatField(context),

            const SizedBox(height: 16),

            // BMI
            _buildBMIField(context),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMeasurementTrack,
                    icon: const Icon(Icons.add),
                    label: const Text('TRACK NEW MEASUREMENT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewHistory,
                    icon: const Icon(Icons.history),
                    label: const Text('VIEW BODY COMPOSITION HISTORY'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightField(BuildContext context, bool isMetric) {
    final heightCm = userProfile.height ?? 0;
    final heightFt = heightCm / 30.48;
    final feet = heightFt.floor();
    final inches = ((heightFt - feet) * 12).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Height',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: isMetric ? heightCm.toStringAsFixed(1) : '$feet\'$inches"',
                decoration: InputDecoration(
                  hintText: isMetric ? '175.0' : '5\'9"',
                  suffixText: isMetric ? 'cm' : 'ft',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isMetric ? '${heightFt.toStringAsFixed(1)} ft' : '${heightCm.toStringAsFixed(1)} cm',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                // Toggle unit - would update settings
              },
              child: Text(
                'Toggle',
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

  Widget _buildCurrentWeightField(BuildContext context, bool isMetric) {
    final weightKg = userProfile.weight ?? 0;
    final weightLbs = weightKg * 2.20462;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Weight',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: isMetric ? weightKg.toStringAsFixed(1) : weightLbs.toStringAsFixed(1),
                decoration: InputDecoration(
                  hintText: isMetric ? '75.5' : '166.0',
                  suffixText: isMetric ? 'kg' : 'lb',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isMetric ? '${weightLbs.toStringAsFixed(1)} lb' : '${weightKg.toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                // Toggle unit - would update settings
              },
              child: Text(
                'Toggle',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Last updated: 2 days ago',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetWeightField(BuildContext context, bool isMetric) {
    const targetWeightKg = 80.0;
    const currentWeightKg = 75.5;
    final progress = (currentWeightKg / targetWeightKg).clamp(0.0, 1.0);
    final remaining = targetWeightKg - currentWeightKg;
    final targetWeightLbs = targetWeightKg * 2.20462;
    final remainingLbs = remaining * 2.20462;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Weight',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: isMetric ? targetWeightKg.toStringAsFixed(1) : targetWeightLbs.toStringAsFixed(1),
                decoration: InputDecoration(
                  hintText: isMetric ? '80.0' : '176.0',
                  suffixText: isMetric ? 'kg' : 'lb',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isMetric ? '${targetWeightLbs.toStringAsFixed(1)} lb' : '${targetWeightKg.toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                // Toggle unit - would update settings
              },
              child: Text(
                'Toggle',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Progress: ${'▰' * (progress * 10).round()}${'▱' * (10 - (progress * 10).round())} ${(progress * 100).round()}% (${isMetric ? remaining.toStringAsFixed(1) : remainingLbs.toStringAsFixed(1)}${isMetric ? 'kg' : 'lb'} left)',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBodyFatField(BuildContext context) {
    final bodyFat = userProfile.bodyFatPercentage ?? 15.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Body Fat Percentage',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: bodyFat.toStringAsFixed(1),
          decoration: InputDecoration(
            hintText: '15.2',
            suffixText: '%',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          keyboardType: TextInputType.number,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Estimated via calculation',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBMIField(BuildContext context) {
    final bmi = userProfile.calculatedBMI ?? 24.6;
    final bmiCategory = _getBMICategory(bmi);
    final bmiColor = _getBMIColor(bmi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BMI (Auto-calculated)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bmiColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: bmiColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: bmiColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '- $bmiCategory',
                style: TextStyle(
                  color: bmiColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _getBMIIcon(bmi),
                color: bmiColor,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  IconData _getBMIIcon(double bmi) {
    if (bmi < 18.5) return Icons.arrow_downward;
    if (bmi < 25) return Icons.check_circle;
    if (bmi < 30) return Icons.warning;
    return Icons.error;
  }
}
