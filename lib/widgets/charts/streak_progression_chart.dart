import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/workout_session.dart';

class StreakProgressionChart extends StatefulWidget {
  final List<WorkoutSession> workoutSessions;
  final bool isLoading;

  const StreakProgressionChart({
    super.key,
    required this.workoutSessions,
    this.isLoading = false,
  });

  @override
  State<StreakProgressionChart> createState() => _StreakProgressionChartState();
}

class _StreakProgressionChartState extends State<StreakProgressionChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    final streakData = _calculateStreakData();

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Streak Progression',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Current: ${streakData.isNotEmpty ? streakData.last : 0} days',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= streakData.length) return const Text('');
                              final day = streakData.length - value.toInt();
                              return Text(
                                '${day}d ago',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (streakData.length - 1).toDouble(),
                      minY: 0,
                      maxY: _getMaxStreak(streakData) * 1.2,
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final daysAgo = streakData.length - spot.x.toInt();
                              return LineTooltipItem(
                                '${daysAgo == 0 ? 'Today' : '$daysAgo days ago'}\n${spot.y.toInt()} day streak',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _buildSpots(streakData),
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.orange,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.3),
                                Colors.orange.withOpacity(0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Consecutive workout days over time',
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

  List<FlSpot> _buildSpots(List<int> streakData) {
    return List.generate(streakData.length, (index) {
      final progress = _animation.value;
      final actualIndex = (index * progress).toInt();
      if (actualIndex >= streakData.length) return FlSpot(index.toDouble(), 0);

      return FlSpot(
        index.toDouble(),
        streakData[actualIndex].toDouble(),
      );
    });
  }

  List<int> _calculateStreakData() {
    final completedSessions = widget.workoutSessions
        .where((s) => s.completed)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final streakData = <int>[];
    int currentStreak = 0;

    // Calculate for last 30 days
    final now = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      final checkDate = now.subtract(Duration(days: i));
      final hasWorkout = completedSessions.any((session) {
        final sessionDate = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        return sessionDate.isAtSameMomentAs(DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
        ));
      });

      if (hasWorkout) {
        currentStreak++;
      } else {
        currentStreak = 0;
      }

      streakData.add(currentStreak);
    }

    return streakData;
  }

  double _getMaxStreak(List<int> data) {
    if (data.isEmpty) return 10;
    return data.reduce((a, b) => a > b ? a : b).toDouble();
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
            Text('Loading streak data...'),
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
            SizedBox(height: 200, child: Center(child: Icon(Icons.timeline, size: 64, color: Colors.grey))),
            SizedBox(height: 16),
            Text('No workout data available'),
            SizedBox(height: 8),
            Text('Complete workouts to build your streak!', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
