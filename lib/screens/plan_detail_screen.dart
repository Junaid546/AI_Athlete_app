import 'package:flutter/material.dart';
import '../models/workout_plan.dart';

class PlanDetailScreen extends StatelessWidget {
  final WorkoutPlan plan;

  const PlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image with parallax
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(plan.name),
              background: Image.network(
                plan.imageUrl ?? 'https://picsum.photos/400/250',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 100),
                ),
              ),
            ),
          ),
          // Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text('${plan.weeks} weeks'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: 8),
                      Text('${plan.daysPerWeek} days per week'),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center),
                      const SizedBox(width: 8),
                      Text(plan.difficultyText),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Equipment:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    children: plan.requiredEquipment.map((e) => Chip(label: Text(e))).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Goals:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    children: plan.targetGoals.map((g) => Chip(label: Text(g))).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Weekly structure
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Weekly Structure',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final week = index + 1;
                return ExpansionTile(
                  title: Text('Week $week'),
                  children: [
                    // For each day in the week
                    for (int day = 1; day <= plan.daysPerWeek; day++)
                      ListTile(
                        title: Text('Day $day'),
                        subtitle: const Text('Workout details coming soon'),
                      ),
                  ],
                );
              },
              childCount: plan.weeks,
            ),
          ),
          // Reviews
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < plan.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${plan.rating}.0 (${plan.reviewCount})'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Sample reviews
                  const Text('Sample review 1'),
                  const Text('Sample review 2'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Start plan
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Starting ${plan.name}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Start This Plan'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  // Save
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan saved')),
                  );
                },
                icon: const Icon(Icons.bookmark_border),
                tooltip: 'Save Plan',
              ),
              IconButton(
                onPressed: () {
                  // Share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan shared')),
                  );
                },
                icon: const Icon(Icons.share),
                tooltip: 'Share Plan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
