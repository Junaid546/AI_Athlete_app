import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../providers/user_profile_provider_firebase.dart';
import '../providers/progress_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/workout_sessions_provider.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TimePeriod _selectedPeriod = TimePeriod.weekly;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final theme = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text(
          'Progress Analytics',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: PopupMenuButton<TimePeriod>(
                onSelected: (value) {
                  setState(() => _selectedPeriod = value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: TimePeriod.daily,
                    child: Row(
                      children: [
                        const Icon(Icons.today, size: 20),
                        const SizedBox(width: 8),
                        const Text('Daily'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TimePeriod.weekly,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_view_week, size: 20),
                        const SizedBox(width: 8),
                        const Text('Weekly'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TimePeriod.monthly,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 20),
                        const SizedBox(width: 8),
                        const Text('Monthly'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TimePeriod.yearly,
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, size: 20),
                        const SizedBox(width: 8),
                        const Text('Yearly'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primaryColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getPeriodLabel(_selectedPeriod),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.expand_more, color: theme.primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'Volume'),
            Tab(icon: Icon(Icons.local_fire_department), text: 'Calories'),
            Tab(icon: Icon(Icons.schedule), text: 'Duration'),
            Tab(icon: Icon(Icons.trending_up), text: 'Exercises'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workoutSessionsProvider);
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Statistics Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildStatisticsCards(context, userProfile, isDark, theme),
              ),
              
              // Tab Content
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVolumeChart(context, isDark, theme),
                    _buildCaloriesChart(context, isDark, theme),
                    _buildDurationChart(context, isDark, theme),
                    _buildExercisesChart(context, isDark, theme),
                  ],
                ),
              ),
              
              // Detailed Metrics
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildDetailedMetrics(context, userProfile, isDark, theme),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.daily:
        return 'Daily';
      case TimePeriod.weekly:
        return 'Weekly';
      case TimePeriod.monthly:
        return 'Monthly';
      case TimePeriod.yearly:
        return 'Yearly';
      case TimePeriod.allTime:
        return 'All Time';
    }
  }

  Widget _buildStatisticsCards(BuildContext context, dynamic userProfile, bool isDark, ThemeData theme) {
    try {
      // Use userProfileProvider as single source of truth for consistent data across all screens
      int totalWorkouts = userProfile?.totalWorkouts ?? 0;
      int currentStreak = userProfile?.currentStreak ?? 0;
      int longestStreak = userProfile?.longestStreak ?? 0;
      double totalVolume = userProfile?.totalVolume ?? 0.0;
      
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _StatCard(
            title: 'Total Workouts',
            value: totalWorkouts.toString(),
            icon: Icons.fitness_center,
            color: Colors.blue,
            isDark: isDark,
            theme: theme,
          ),
          _StatCard(
            title: 'Current Streak',
            value: '$currentStreak days',
            icon: Icons.local_fire_department,
            color: Colors.orange,
            isDark: isDark,
            theme: theme,
          ),
          _StatCard(
            title: 'Total Volume',
            value: '${totalVolume.toStringAsFixed(0)} kg',
            icon: Icons.show_chart,
            color: Colors.purple,
            isDark: isDark,
            theme: theme,
          ),
          _StatCard(
            title: 'Longest Streak',
            value: '$longestStreak days',
            icon: Icons.trending_up,
            color: Colors.green,
            isDark: isDark,
            theme: theme,
          ),
        ],
      );
    } catch (e) {
      // Fallback UI if there's an error
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: List.generate(4, (index) => _StatCard(
          title: 'Workout',
          value: '0',
          icon: Icons.fitness_center,
          color: Colors.grey,
          isDark: isDark,
          theme: theme,
        )),
      );
    }
  }

  Widget _buildVolumeChart(BuildContext context, bool isDark, ThemeData theme) {
    final sessions = ref.watch(workoutSessionsProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: _buildLineChart(sessions, isDark, theme, 'Volume'),
    );
  }

  Widget _buildCaloriesChart(BuildContext context, bool isDark, ThemeData theme) {
    final sessions = ref.watch(workoutSessionsProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: _buildBarChart(sessions, isDark, theme),
    );
  }

  Widget _buildDurationChart(BuildContext context, bool isDark, ThemeData theme) {
    final sessions = ref.watch(workoutSessionsProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: _buildPieChart(sessions, isDark, theme),
    );
  }

  Widget _buildExercisesChart(BuildContext context, bool isDark, ThemeData theme) {
    try {
      final sessions = ref.watch(workoutSessionsProvider);
      final exerciseMap = <String, int>{};
      
      for (final session in sessions) {
        for (final exercise in session.exercises) {
          try {
            final exerciseName = exercise.exercise.name;
            exerciseMap[exerciseName] = (exerciseMap[exerciseName] ?? 0) + 1;
          } catch (e) {
            // Skip malformed exercises
          }
        }
      }
      
      if (exerciseMap.isEmpty) {
        return Center(
          child: Text(
            'No exercises logged yet',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          ),
        );
      }
      
      return Container(
        padding: const EdgeInsets.all(16),
        child: _buildRadarChart(exerciseMap, isDark, theme),
      );
    } catch (e) {
      return Center(
        child: Text(
          'Unable to load exercises',
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }
  }

  Widget _buildLineChart(List<dynamic> sessions, bool isDark, ThemeData theme, String type) {
    try {
      if (sessions.isEmpty) {
        return Center(
          child: Text(
            'No data available',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          ),
        );
      }

      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < titles.length) {
                    return Text(titles[value.toInt()],
                        style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}',
                      style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                min(sessions.length, 7),
                (index) => FlSpot(index.toDouble(), (index * 10).toDouble()),
              ),
              isCurved: true,
              color: theme.primaryColor,
              barWidth: 2,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      );
    } catch (e) {
      return Center(
        child: Text(
          'Unable to load chart',
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }
  }

  Widget _buildBarChart(List<dynamic> sessions, bool isDark, ThemeData theme) {
    try {
      return BarChart(
        BarChartData(
          barGroups: List.generate(
            7,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (index * 100).toDouble(),
                  color: theme.primaryColor,
                ),
              ],
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Text(titles[value.toInt()], style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
        ),
      );
    } catch (e) {
      return Center(
        child: Text(
          'Unable to load chart',
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
        ),
      );
    }
  }

  Widget _buildPieChart(List<dynamic> sessions, bool isDark, ThemeData theme) {
    final colors = [
      theme.primaryColor,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];

    return PieChart(
      PieChartData(
        sections: List.generate(
          5,
          (index) => PieChartSectionData(
            color: colors[index],
            value: ((index + 1) * 20).toDouble(),
            title: '${((index + 1) * 20).toInt()}%',
            radius: 50,
          ),
        ),
      ),
    );
  }

  Widget _buildRadarChart(Map<String, int> exerciseMap, bool isDark, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Top Exercises'),
          const SizedBox(height: 16),
          ...exerciseMap.entries.take(5).map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${entry.key}: '),
                Container(
                  width: (entry.value * 20).toDouble(),
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics(BuildContext context, dynamic userProfile, bool isDark, ThemeData theme) {
    try {
      // Use userProfileProvider as single source of truth for consistent data
      int totalWorkouts = userProfile?.totalWorkouts ?? 0;
      int currentStreak = userProfile?.currentStreak ?? 0;
      int longestStreak = userProfile?.longestStreak ?? 0;
      double totalVolume = userProfile?.totalVolume ?? 0.0;
      
      final sessions = ref.watch(workoutSessionsProvider);
      
      DateTime? lastWorkoutDate = userProfile?.lastWorkoutDate;
      if (lastWorkoutDate == null && sessions.isNotEmpty) {
        lastWorkoutDate = sessions.map((s) => s.date).reduce((a, b) => a.isAfter(b) ? a : b);
      }
      
      return Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detailed Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildMetricRow('Last Workout', 
                lastWorkoutDate != null 
                  ? DateFormat('MMM dd, yyyy').format(lastWorkoutDate)
                  : 'Never',
                isDark, theme),
              _buildMetricRow('Total Workouts', '$totalWorkouts', isDark, theme),
              _buildMetricRow('Current Streak', '$currentStreak days', isDark, theme),
              _buildMetricRow('Longest Streak', '$longestStreak days', isDark, theme),
              _buildMetricRow('Total Volume', '${totalVolume.toStringAsFixed(1)} kg', isDark, theme),
            ],
          ),
        ),
      );
    } catch (e) {
      return Card(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unable to load metrics',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildMetricRow(String label, String value, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final ThemeData theme;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
