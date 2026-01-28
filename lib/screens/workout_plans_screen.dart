import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_plans_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/plan_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../screens/plan_detail_screen.dart';
import '../models/workout_plan.dart';

class WorkoutPlansScreen extends ConsumerStatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  ConsumerState<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends ConsumerState<WorkoutPlansScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _listenerSet = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(filterProvider.notifier).setSearchQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_listenerSet) {
      ref.listen(filterProvider, (previous, next) {
        ref.read(filteredWorkoutPlansProvider.notifier).applyFilters(next);
      });
      _listenerSet = true;
    }

    final recommendedPlans = ref.watch(recommendedPlansProvider);
    final myPlans = ref.watch(myPlansProvider);
    final popularTemplates = ref.watch(popularTemplatesProvider);
    final theme = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text(
          'Workout Plans',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: isDark ? Colors.white : Colors.black),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(filteredWorkoutPlansProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search plans...',
                    prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  cursorColor: theme.primaryColor,
                ),
              ),
            ),
            // Recommended section
            if (recommendedPlans.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader('Recommended for You', isDark),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recommendedPlans.length,
                    itemBuilder: (context, index) {
                      final plan = recommendedPlans[index];
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        child: PlanCard(
                          plan: plan,
                          onStart: () => _startPlan(plan),
                          onPreview: () => _previewPlan(plan),
                          onTap: () => _navigateToPlanDetail(plan),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            // My Plans section
            if (myPlans.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader('My Plans', isDark),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final plan = myPlans[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: PlanCard(
                        plan: plan,
                        onStart: () => _startPlan(plan),
                        onPreview: () => _previewPlan(plan),
                        onTap: () => _navigateToPlanDetail(plan),
                      ),
                    );
                  },
                  childCount: myPlans.length,
                ),
              ),
            ],
            // AI Generated section
            SliverToBoxAdapter(
              child: _buildAISection(isDark, theme),
            ),
            // Popular Templates section
            SliverToBoxAdapter(
              child: _buildSectionHeader('Popular Templates', isDark),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final plan = popularTemplates[index];
                    return PlanCard(
                      plan: plan,
                      onStart: () => _startPlan(plan),
                      onPreview: () => _previewPlan(plan),
                      onTap: () => _navigateToPlanDetail(plan),
                    );
                  },
                  childCount: popularTemplates.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 32),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAICreateDialog(context),
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAISection(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: theme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI-Generated Plans',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create a custom workout plan tailored to your goals',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAICreateDialog(context),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Create Custom Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
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
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const FilterBottomSheet(),
      ),
    );
  }

  void _showAICreateDialog(BuildContext context) {
    final theme = ref.read(themeProvider);
    final isDark = theme.brightness == Brightness.dark;
    String selectedGoal = 'Build muscle';
    String selectedSport = 'General';
    int duration = 8;
    List<String> selectedEquipment = [];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Create Custom Plan',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedGoal,
                  dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  items: ['Build muscle', 'Lose weight', 'Improve endurance', 'Increase strength']
                      .map((goal) => DropdownMenuItem(
                        value: goal,
                        child: Text(
                          goal,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedGoal = value!),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sport',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedSport,
                  dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  items: ['General', 'Running', 'Cycling', 'Swimming', 'Weightlifting']
                      .map((sport) => DropdownMenuItem(
                        value: sport,
                        child: Text(
                          sport,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedSport = value!),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Duration (weeks)',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: duration.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => duration = int.tryParse(value) ?? 8,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 16),
                Text(
                  'Equipment',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Dumbbells', 'Barbell', 'Bench', 'Yoga mat', 'None'].map((equipment) {
                    final isSelected = selectedEquipment.contains(equipment);
                    return FilterChip(
                      label: Text(
                        equipment,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                      selected: isSelected,
                      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
                      selectedColor: theme.primaryColor,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedEquipment.add(equipment);
                          } else {
                            selectedEquipment.remove(equipment);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Generate plan
                final plan = await ref.read(filteredWorkoutPlansProvider.notifier).generateAIPlan(
                  goals: selectedGoal,
                  sport: selectedSport,
                  duration: duration,
                  equipment: selectedEquipment,
                );
                if (plan != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Generated plan: ${plan.name} 🚀'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
              ),
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  void _startPlan(WorkoutPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${plan.name} 💪'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _previewPlan(WorkoutPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Previewing ${plan.name}'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToPlanDetail(WorkoutPlan plan) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PlanDetailScreen(plan: plan),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
