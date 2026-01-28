import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

class AchievementsBadgesSection extends ConsumerWidget {
  const AchievementsBadgesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    try {
      final userProfile = ref.watch(userProfileProvider);

      if (userProfile == null) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
          ),
          child: Center(
            child: Text(
              'Loading achievements...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(12),
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
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emoji_events, color: Colors.amber),
                ),
                const SizedBox(width: 8),
                Text(
                  'Achievements & Badges',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Badge Grid
            if (userProfile.badges.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = (constraints.maxWidth / 80).floor().clamp(2, 5);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: userProfile.badges.length,
                    itemBuilder: (context, index) {
                      final badgeName = userProfile.badges[index];
                      return _BadgeItem(
                        badgeName: badgeName,
                        index: index,
                        isDark: isDark,
                      );
                    },
                  );
                },
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock,
                        size: 48,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No badges earned yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badges Earned',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${userProfile.badges.length}/12',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${((userProfile.badges.length / 12) * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (userProfile.badges.length / 12).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // View All Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAchievementDetails(context, isDark);
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View All Achievements'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.dangerColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading achievements',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.dangerColor,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showAchievementDetails(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'All Achievements',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._getAchievementsList(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getAchievementsList(BuildContext context, bool isDark) {
    final achievements = [
      ('🏆', 'First Workout', 'Complete your first workout', true),
      ('💪', 'Strong Start', 'Reach 5 workouts', true),
      ('🔥', 'On Fire', 'Reach 7-day streak', false),
      ('⚡', 'Lightning Fast', 'Complete 100 workouts', false),
      ('📈', 'Progress Master', 'Increase lift by 50%', true),
      ('🎯', 'Goal Achiever', 'Reach 5 personal records', false),
      ('💯', 'Perfect Week', 'Complete all 7 days', false),
      ('🌟', 'Consistency King', 'Maintain 30-day streak', false),
      ('🏅', 'Elite Athlete', 'Total volume 100k kg', false),
      ('🚀', 'Growth Mindset', 'Improve all metrics', false),
      ('⭐', 'Champion', 'Earn 10 badges', false),
      ('👑', 'Legend', 'Earn all badges', false),
    ];

    return achievements.map((achievement) {
      final (emoji, name, description, earned) = achievement;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: earned ? Colors.amber.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: earned ? Colors.amber.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: earned ? Colors.amber : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (earned)
              const Icon(Icons.check_circle, color: Colors.amber)
            else
              const Icon(Icons.lock_outline, color: Colors.grey),
          ],
        ),
      );
    }).toList();
  }
}

class _BadgeItem extends StatelessWidget {
  final String badgeName;
  final int index;
  final bool isDark;

  const _BadgeItem({
    required this.badgeName,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final emojis = ['🏆', '💪', '🔥', '⚡', '📈', '🎯', '💯', '🌟', '🏅', '🚀', '⭐', '👑'];
    final emoji = emojis[index % emojis.length];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$emoji $badgeName earned!'),
              backgroundColor: Colors.amber,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                badgeName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
