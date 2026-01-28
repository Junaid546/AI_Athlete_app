import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requirement;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirement,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  double get progressPercentage => (currentProgress / requirement).clamp(0.0, 1.0);
}

class AchievementsSection extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onViewAll;

  const AchievementsSection({
    super.key,
    required this.userProfile,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final nextBadge = _getNextBadge(achievements);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🏆 ACHIEVEMENTS & BADGES',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('VIEW ALL'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Achievement Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: 8, // Show first 8 achievements
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return _buildAchievementBadge(context, achievement);
              },
            ),

            const SizedBox(height: 16),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Badges: $unlockedCount/${achievements.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (nextBadge != null)
                  Text(
                    'Next: ${nextBadge.name} (${nextBadge.currentProgress}/${nextBadge.requirement})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),

            if (nextBadge != null) ...[
              const SizedBox(height: 8),
              // Progress to next badge
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: nextBadge.progressPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(BuildContext context, Achievement achievement) {
    return GestureDetector(
      onTap: () => _showAchievementDetails(context, achievement),
      child: Container(
        decoration: BoxDecoration(
          color: achievement.isUnlocked
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.isUnlocked
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!achievement.isUnlocked && achievement.currentProgress > 0) ...[
              const SizedBox(height: 2),
              Text(
                '${achievement.currentProgress}/${achievement.requirement}',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(achievement.icon),
            const SizedBox(width: 8),
            Text(achievement.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            if (achievement.isUnlocked) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Unlocked',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (achievement.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Unlocked on ${_formatDate(achievement.unlockedAt!)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ] else ...[
              Text(
                'Progress: ${achievement.currentProgress}/${achievement.requirement}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: achievement.progressPercentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(achievement.progressPercentage * 100).round()}% complete',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (achievement.isUnlocked)
            TextButton.icon(
              onPressed: () {
                // Share achievement
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Achievement shared!')),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
        ],
      ),
    );
  }

  List<Achievement> _getAchievements() {
    return [
      Achievement(
        id: 'iron_warrior',
        name: 'Iron Warrior',
        description: 'Complete 100 workouts',
        icon: '🥇',
        requirement: 100,
        currentProgress: userProfile.totalWorkouts,
        isUnlocked: userProfile.totalWorkouts >= 100,
        unlockedAt: userProfile.totalWorkouts >= 100 ? DateTime.now().subtract(const Duration(days: 30)) : null,
      ),
      Achievement(
        id: 'streak_30',
        name: '30 Day Streak',
        description: 'Maintain a 30-day workout streak',
        icon: '🔥',
        requirement: 30,
        currentProgress: userProfile.currentStreak,
        isUnlocked: userProfile.currentStreak >= 30,
        unlockedAt: userProfile.currentStreak >= 30 ? DateTime.now().subtract(const Duration(days: 10)) : null,
      ),
      Achievement(
        id: 'workout_100',
        name: '100 Workout Club',
        description: 'Complete 100 total workouts',
        icon: '💪',
        requirement: 100,
        currentProgress: userProfile.totalWorkouts,
        isUnlocked: userProfile.totalWorkouts >= 100,
        unlockedAt: userProfile.totalWorkouts >= 100 ? DateTime.now().subtract(const Duration(days: 20)) : null,
      ),
      Achievement(
        id: 'elite_lifter',
        name: 'Elite Lifter',
        description: 'Reach 500kg total volume in a single workout',
        icon: '⭐',
        requirement: 500,
        currentProgress: 350, // Mock data
        isUnlocked: false,
      ),
      Achievement(
        id: 'consistency_king',
        name: 'Consistency King',
        description: 'Workout 365 days in a year',
        icon: '👑',
        requirement: 365,
        currentProgress: 245, // Mock data
        isUnlocked: false,
      ),
      Achievement(
        id: 'strength_master',
        name: 'Strength Master',
        description: 'Increase total strength by 50kg',
        icon: '🏆',
        requirement: 50,
        currentProgress: 25, // Mock data
        isUnlocked: false,
      ),
      Achievement(
        id: 'dedication',
        name: 'Dedication',
        description: 'Complete workouts for 6 months straight',
        icon: '🎖️',
        requirement: 180,
        currentProgress: 120, // Mock data
        isUnlocked: false,
      ),
      Achievement(
        id: 'transformation',
        name: 'Transformation',
        description: 'Lose 10kg of body fat',
        icon: '🔄',
        requirement: 10,
        currentProgress: 4, // Mock data
        isUnlocked: false,
      ),
    ];
  }

  Achievement? _getNextBadge(List<Achievement> achievements) {
    final lockedAchievements = achievements.where((a) => !a.isUnlocked).toList();
    if (lockedAchievements.isEmpty) return null;

    // Sort by progress percentage (closest to completion)
    lockedAchievements.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
    return lockedAchievements.first;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
