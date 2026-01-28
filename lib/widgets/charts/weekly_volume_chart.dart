import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/progress_metric.dart';

class WeeklyVolumeChart extends StatefulWidget {
  final List<ProgressMetric> volumeMetrics;
  final bool isLoading;

  const WeeklyVolumeChart({
    super.key,
    required this.volumeMetrics,
    this.isLoading = false,
  });

  @override
  State<WeeklyVolumeChart> createState() => _WeeklyVolumeChartState();
}

class _WeeklyVolumeChartState extends State<WeeklyVolumeChart>
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

    if (widget.volumeMetrics.isEmpty) {
      return _buildEmptyState();
    }

    final weeklyData = _calculateWeeklyData();

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
                      'Weekly Volume',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${weeklyData.fold<double>(0, (sum, data) => sum + (data['volume'] as double)).toStringAsFixed(0)} kg',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxVolume(weeklyData) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${weeklyData[groupIndex]['day']}\n${rod.toY.toStringAsFixed(0)} kg',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= weeklyData.length) return const Text('');
                              return Text(
                                weeklyData[value.toInt()]['day'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getMaxVolume(weeklyData) / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(weeklyData),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Total volume lifted per day this week',
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

  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> weeklyData) {
    return List.generate(weeklyData.length, (index) {
      final data = weeklyData[index];
      final volume = data['volume'] as double;
      final animatedVolume = volume * _animation.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: animatedVolume,
            gradient: const LinearGradient(
              colors: [Colors.lightBlue, Colors.blue],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  List<Map<String, dynamic>> _calculateWeeklyData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = <Map<String, dynamic>>[];

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayMetrics = widget.volumeMetrics.where((metric) {
        final metricDate = metric.date;
        return metricDate.year == day.year &&
               metricDate.month == day.month &&
               metricDate.day == day.day;
      }).toList();

      final totalVolume = dayMetrics.fold<double>(0, (sum, metric) => sum + metric.value);

      weeklyData.add({
        'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
        'volume': totalVolume,
      });
    }

    return weeklyData;
  }

  double _getMaxVolume(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 100;
    return data.map((d) => d['volume'] as double).reduce((a, b) => a > b ? a : b);
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
            Text('Loading weekly volume data...'),
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
            SizedBox(height: 200, child: Center(child: Icon(Icons.bar_chart, size: 64, color: Colors.grey))),
            SizedBox(height: 16),
            Text('No volume data available'),
            SizedBox(height: 8),
            Text('Complete some workouts to see your progress!', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
