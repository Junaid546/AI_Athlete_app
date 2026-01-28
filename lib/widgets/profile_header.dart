import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_profile.dart';
import '../utils/animation_utils.dart';

class ProfileHeader extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback onProfilePhotoTap;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    required this.userProfile,
    required this.onProfilePhotoTap,
    required this.onEditProfile,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _streakAnimationController;
  late Animation<double> _streakPulseAnimation;

  @override
  void initState() {
    super.initState();
    _streakAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _streakPulseAnimation = AnimationUtils.createPulseAnimation(
      controller: _streakAnimationController,
      beginScale: 1.0,
      endScale: 1.1,
    );
  }

  @override
  void dispose() {
    _streakAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth < 360 ? 100.0 : 120.0;
    final avatarFontSize = 36 * (avatarSize / 120);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Profile Photo Section
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: widget.userProfile.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.userProfile.profileImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => _buildInitialsAvatar(avatarFontSize),
                        )
                      : _buildInitialsAvatar(avatarFontSize),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: widget.onProfilePhotoTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name and Handle
          Text(
            widget.userProfile.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '@${widget.userProfile.name.toLowerCase().replaceAll(' ', '_')}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏅', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  _getRoleDisplayName(widget.userProfile.role),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                '${widget.userProfile.totalWorkouts}',
                'Workouts',
                Icons.fitness_center,
              ),
              _buildStatItem(
                context,
                '${widget.userProfile.currentStreak}',
                '🔥 Streak',
                Icons.local_fire_department,
              ),
              _buildStatItem(
                context,
                '${widget.userProfile.points}',
                'Points',
                Icons.stars,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(double fontSize) {
    final initials = widget.userProfile.name
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');

    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    final isStreakItem = label.contains('🔥');

    return GestureDetector(
      onTap: () {
        // Navigate to detailed stats
      },
      child: AnimatedBuilder(
        animation: isStreakItem ? _streakPulseAnimation : AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: isStreakItem ? _streakPulseAnimation.value : 1.0,
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isStreakItem
                      ? Colors.orange.withOpacity(0.9)
                      : Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isStreakItem ? Colors.orange : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: isStreakItem
                        ? Colors.orange.withOpacity(0.8)
                        : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.athlete:
        return 'Elite Athlete';
      case UserRole.coach:
        return 'Certified Coach';
    }
  }
}
