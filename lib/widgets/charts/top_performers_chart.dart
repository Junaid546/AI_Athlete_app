import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/workout_session.dart';

class TopPerformersChart extends StatefulWidget {
  final List<WorkoutSession> workoutSessions;
  final bool isLoading;

  const TopPerformersChart({
    super.key,
    required this.workoutSessions,
    this.isLoading = false,
  });

  @override
  State<TopPerformersChart> createState() => _TopPerformersChartState();
}

class _TopPerformersChartState extends State<TopPerformersChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.workoutSessions.isEmpty) {
      return _buildEmptyState();
    }

    final topExercises = _calculateTopExercises();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Performers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxVolume(topExercises) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final exercise = topExercises[groupIndex];
                            return BarTooltipItem(
                              '${exercise['name']}\n${rod.toY.toStringAsFixed(0)} kg total',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 80,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= topExercises.length) return const Text('');
                              final exercise = topExercises[value.toInt()];
                              final name = exercise['name'] as String;
                              // Truncate long names
                              final displayName = name.length > 10 ? '${name.substring(0, 10)}...' : name;
                              return RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  displayName,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getMaxVolume(topExercises) / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(topExercises),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Exercises ranked by total volume lifted',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> exercises) {
    return List.generate(exercises.length, (index) {
      final exercise = exercises[index];
      final volume = exercise['volume'] as double;
      final animatedVolume = volume * _animation.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: animatedVolume,
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.8),
                Colors.blue.withOpacity(0.8),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  List<Map<String, dynamic>> _calculateTopExercises() {
    final exerciseVolume = <String, double>{};

    for (final session in widget.workoutSessions) {
      for (final exercise in session.exercises) {
        final name = exercise.exercise.name;
        exerciseVolume[name] = (exerciseVolume[name] ?? 0) + exercise.totalVolume;
      }
    }

    final sorted = exerciseVolume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(10).map((e) => {'name': e.key, 'volume': e.value}).toList();
  }

  double _getMaxVolume(List<Map<String, dynamic>> exercises) {
    if (exercises.isEmpty) return 1000;
    return exercises.map((e) => e['volume'] as double).reduce((a, b) => a > b ? a : b);
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
            SizedBox(height: 16),
            Text('Loading top performers...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 200, child: Center(child: Icon(Icons.leaderboard, size: 64, color: Colors.grey))),
            SizedBox(height: 16),
            Text('No exercise data available'),
            SizedBox(height: 8),
            Text('Complete workouts to see your top performers!', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
