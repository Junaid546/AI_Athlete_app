import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class PersonalRecord {
  final String exercise;
  final double weight;
  final DateTime date;
  final int reps;
  final String unit;

  const PersonalRecord({
    required this.exercise,
    required this.weight,
    required this.date,
    required this.reps,
    this.unit = 'kg',
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).round()} weeks ago';
    if (difference < 365) return '${(difference / 30).round()} months ago';
    return '${(difference / 365).round()} years ago';
  }

  String get displayValue {
    if (reps == 1) {
      return '${weight.toStringAsFixed(1)}$unit';
    } else {
      return '${weight.toStringAsFixed(1)}$unit × $reps';
    }
  }
}

class PersonalRecordsSection extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onViewAll;
  final VoidCallback onViewHistory;

  const PersonalRecordsSection({
    super.key,
    required this.userProfile,
    required this.onViewAll,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final records = _getPersonalRecords();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '💪 PERSONAL RECORDS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: onViewHistory,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('GRAPH', style: TextStyle(fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: onViewAll,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('ALL', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Top 5 PRs
            ...records.take(5).map((record) => _buildRecordItem(context, record)),

            const SizedBox(height: 16),

            // Quick Stats
            _buildQuickStats(context, records),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, PersonalRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Exercise Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _getExerciseIcon(record.exercise),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Record Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.exercise,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  record.displayValue,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${record.date.day}/${record.date.month}/${record.date.year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          // Trophy Icon for recent PRs
          if (record.date.difference(DateTime.now()).inDays.abs() < 7)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.emoji_events,
                color: Colors.amber.shade600,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, List<PersonalRecord> records) {
    final totalPRs = records.length;
    final recentPRs = records.where((r) => r.date.difference(DateTime.now()).inDays < 30).length;
    final maxWeight = records.isNotEmpty ? records.map((r) => r.weight).reduce((a, b) => a > b ? a : b) : 0.0;
    final avgWeight = records.isNotEmpty ? records.map((r) => r.weight).reduce((a, b) => a + b) / records.length : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total PRs', totalPRs.toString(), Icons.track_changes),
              _buildStatItem('This Month', recentPRs.toString(), Icons.calendar_today),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Max Weight', '${maxWeight.toStringAsFixed(0)}kg', Icons.fitness_center),
              _buildStatItem('Avg Weight', '${avgWeight.toStringAsFixed(0)}kg', Icons.show_chart),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<PersonalRecord> _getPersonalRecords() {
    // Mock data based on user profile
    return [
      PersonalRecord(
        exercise: 'Bench Press',
        weight: 120,
        date: DateTime.now().subtract(const Duration(days: 5)),
        reps: 1,
      ),
      PersonalRecord(
        exercise: 'Squat',
        weight: 180,
        date: DateTime.now().subtract(const Duration(days: 12)),
        reps: 1,
      ),
      PersonalRecord(
        exercise: 'Deadlift',
        weight: 220,
        date: DateTime.now().subtract(const Duration(days: 8)),
        reps: 1,
      ),
      PersonalRecord(
        exercise: 'Overhead Press',
        weight: 75,
        date: DateTime.now().subtract(const Duration(days: 15)),
        reps: 1,
      ),
      PersonalRecord(
        exercise: 'Pull-ups',
        weight: 0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        reps: 25,
      ),
      PersonalRecord(
        exercise: 'Barbell Row',
        weight: 100,
        date: DateTime.now().subtract(const Duration(days: 20)),
        reps: 8,
      ),
      PersonalRecord(
        exercise: 'Dips',
        weight: 20,
        date: DateTime.now().subtract(const Duration(days: 25)),
        reps: 12,
      ),
    ]..sort((a, b) => b.date.compareTo(a.date)); // Sort by most recent
  }

  String _getExerciseIcon(String exercise) {
    final exerciseLower = exercise.toLowerCase();
    if (exerciseLower.contains('bench') || exerciseLower.contains('press')) return '🏋️';
    if (exerciseLower.contains('squat')) return '🦵';
    if (exerciseLower.contains('deadlift')) return '🏋️';
    if (exerciseLower.contains('pull')) return '💪';
    if (exerciseLower.contains('row')) return '🏋️';
    if (exerciseLower.contains('dip')) return '🏋️';
    return '💪';
  }
}
