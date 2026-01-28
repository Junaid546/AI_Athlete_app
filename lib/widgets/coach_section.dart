import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_profile.dart';

class Coach {
  final String id;
  final String name;
  final String title;
  final String avatarUrl;
  final int yearsExperience;
  final int clientsCount;
  final double rating;
  final List<String> specialties;
  final DateTime connectedSince;

  const Coach({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarUrl,
    required this.yearsExperience,
    required this.clientsCount,
    required this.rating,
    required this.specialties,
    required this.connectedSince,
  });

  String get connectedDuration {
    final months = DateTime.now().difference(connectedSince).inDays ~/ 30;
    if (months < 1) return 'Less than a month';
    if (months == 1) return '1 month';
    if (months < 12) return '$months months';
    final years = months ~/ 12;
    return years == 1 ? '1 year' : '$years years';
  }
}

class CoachSection extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onMessage;
  final VoidCallback onViewPlans;
  final VoidCallback onFindCoach;
  final VoidCallback onRequestChange;

  const CoachSection({
    super.key,
    required this.userProfile,
    required this.onMessage,
    required this.onViewPlans,
    required this.onFindCoach,
    required this.onRequestChange,
  });

  @override
  Widget build(BuildContext context) {
    final coach = _getCurrentCoach();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 MY COACH',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            if (coach != null) ...[
              // Coach Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    // Coach Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: CachedNetworkImageProvider(coach.avatarUrl),
                      onBackgroundImageError: (_, __) => const Icon(Icons.person),
                    ),
                    const SizedBox(width: 16),

                    // Coach Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coach.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            coach.title,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                              const SizedBox(width: 4),
                              Text(
                                coach.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.amber.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${coach.clientsCount} clients',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Training together: ${coach.connectedDuration}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMessage,
                      icon: const Icon(Icons.message),
                      label: const Text('MESSAGE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewPlans,
                      icon: const Icon(Icons.assignment),
                      label: const Text('VIEW ASSIGNED PLANS'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Request Change
              Center(
                child: TextButton.icon(
                  onPressed: onRequestChange,
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('REQUEST CHANGE'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                ),
              ),
            ] else ...[
              // No Coach State
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Coach Assigned',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect with a certified coach to get personalized training plans and expert guidance.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: onFindCoach,
                      icon: const Icon(Icons.search),
                      label: const Text('FIND A COACH'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Coach? _getCurrentCoach() {
    // Mock coach data - in real app this would come from userProfile.coachId
    return Coach(
      id: 'coach_1',
      name: 'Coach Mike Johnson',
      title: '🏅 Certified Strength Coach',
      avatarUrl: 'https://picsum.photos/100', // Placeholder
      yearsExperience: 8,
      clientsCount: 47,
      rating: 4.9,
      specialties: ['Powerlifting', 'Strength Training', 'Athletic Performance'],
      connectedSince: DateTime.now().subtract(const Duration(days: 180)), // 6 months
    );
  }
}

// Athlete Roster Section for Coach Mode
class AthleteRosterSection extends StatefulWidget {
  final Function(String) onViewProfile;
  final VoidCallback onAddAthlete;
  final VoidCallback onInviteByEmail;

  const AthleteRosterSection({
    super.key,
    required this.onViewProfile,
    required this.onAddAthlete,
    required this.onInviteByEmail,
  });

  @override
  State<AthleteRosterSection> createState() => _AthleteRosterSectionState();
}

class _AthleteRosterSectionState extends State<AthleteRosterSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final athletes = _getAthletes();
    final filteredAthletes = athletes.where((athlete) {
      return athlete.name.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👥 MY ATHLETES',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search athletes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Athletes List
            ...filteredAthletes.map((athlete) => _buildAthleteItem(context, athlete)),

            const SizedBox(height: 16),

            // Summary
            Text(
              '${athletes.length} athletes total',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onAddAthlete,
                    icon: const Icon(Icons.add),
                    label: const Text('ADD ATHLETE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onInviteByEmail,
                    icon: const Icon(Icons.email),
                    label: const Text('INVITE BY EMAIL'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthleteItem(BuildContext context, Athlete athlete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => widget.onViewProfile(athlete.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(athlete.avatarUrl),
                onBackgroundImageError: (_, __) => Text(athlete.name[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Last Session: ${athlete.lastSession}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Current Plan: ${athlete.currentPlan}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Athlete> _getAthletes() {
    return [
      Athlete(
        id: 'athlete_1',
        name: 'John Doe',
        avatarUrl: 'https://picsum.photos/100',
        lastSession: '1 day ago',
        currentPlan: 'Strength Builder',
      ),
      Athlete(
        id: 'athlete_2',
        name: 'Jane Smith',
        avatarUrl: 'https://picsum.photos/100',
        lastSession: '3 hours ago',
        currentPlan: 'Marathon Prep',
      ),
      Athlete(
        id: 'athlete_3',
        name: 'Mike Johnson',
        avatarUrl: 'https://picsum.photos/100',
        lastSession: '2 days ago',
        currentPlan: 'Powerlifting Fundamentals',
      ),
      Athlete(
        id: 'athlete_4',
        name: 'Sarah Wilson',
        avatarUrl: 'https://picsum.photos/100',
        lastSession: '1 week ago',
        currentPlan: 'Weight Loss Program',
      ),
      Athlete(
        id: 'athlete_5',
        name: 'Tom Brown',
        avatarUrl: 'https://picsum.photos/100',
        lastSession: '5 days ago',
        currentPlan: 'Muscle Gain',
      ),
    ];
  }
}

class Athlete {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastSession;
  final String currentPlan;

  const Athlete({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastSession,
    required this.currentPlan,
  });
}
