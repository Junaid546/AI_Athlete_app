import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/user_profile.dart';

class BodyMetricsChart extends StatefulWidget {
  final UserProfile userProfile;
  final bool isLoading;

  const BodyMetricsChart({
    super.key,
    required this.userProfile,
    this.isLoading = false,
  });

  @override
  State<BodyMetricsChart> createState() => _BodyMetricsChartState();
}

class _BodyMetricsChartState extends State<BodyMetricsChart>
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

    // For demo purposes, we'll create sample data
    // In real app, this would come from body measurement history
    final metricsData = _generateSampleMetricsData();

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
                      'Body Metrics Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _buildLegendItem('Weight', Colors.blue),
                        const SizedBox(width: 16),
                        _buildLegendItem('Body Fat', Colors.orange),
                      ],
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
                              if (value.toInt() >= metricsData.length) return const Text('');
                              final date = metricsData[value.toInt()]['date'] as DateTime;
                              return Text(
                                '${date.month}/${date.day}',
                                style: const TextStyle(fontSize: 10),
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
                                style: const TextStyle(fontSize: 10, color: Colors.blue),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(fontSize: 10, color: Colors.orange),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (metricsData.length - 1).toDouble(),
                      minY: 0,
                      maxY: 100, // Weight in kg
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final data = metricsData[spot.x.toInt()];
                              final date = data['date'] as DateTime;
                              if (spot.barIndex == 0) {
                                return LineTooltipItem(
                                  '${date.month}/${date.day}\nWeight: ${spot.y.toStringAsFixed(1)} kg',
                                  const TextStyle(color: Colors.white),
                                );
                              } else {
                                return LineTooltipItem(
                                  '${date.month}/${date.day}\nBody Fat: ${spot.y.toStringAsFixed(1)}%',
                                  const TextStyle(color: Colors.white),
                                );
                              }
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        // Weight line
                        LineChartBarData(
                          spots: _buildWeightSpots(metricsData),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.blue,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        ),
                        // Body fat line
                        LineChartBarData(
                          spots: _buildBodyFatSpots(metricsData),
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
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current: ${widget.userProfile.weight?.toStringAsFixed(1) ?? '--'} kg, ${widget.userProfile.bodyFatPercentage?.toStringAsFixed(1) ?? '--'}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    _buildTrendIndicator(metricsData),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildWeightSpots(List<Map<String, dynamic>> data) {
    return List.generate(data.length, (index) {
      final progress = _animation.value;
      final actualIndex = (index * progress).toInt();
      if (actualIndex >= data.length) return FlSpot(index.toDouble(), 0);

      return FlSpot(
        index.toDouble(),
        data[actualIndex]['weight'] as double,
      );
    });
  }

  List<FlSpot> _buildBodyFatSpots(List<Map<String, dynamic>> data) {
    return List.generate(data.length, (index) {
      final progress = _animation.value;
      final actualIndex = (index * progress).toInt();
      if (actualIndex >= data.length) return FlSpot(index.toDouble(), 0);

      return FlSpot(
        index.toDouble(),
        data[actualIndex]['bodyFat'] as double,
      );
    });
  }

  List<Map<String, dynamic>> _generateSampleMetricsData() {
    // Generate sample data for the last 12 weeks
    final data = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final baseWeight = widget.userProfile.weight ?? 70.0;
    final baseBodyFat = widget.userProfile.bodyFatPercentage ?? 15.0;

    for (int i = 11; i >= 0; i--) {
      final date = now.subtract(Duration(days: i * 7));
      // Simulate gradual changes
      final weightVariation = (i - 6) * 0.2; // Losing weight over time
      final bodyFatVariation = (i - 6) * -0.1; // Body fat decreasing

      data.add({
        'date': date,
        'weight': baseWeight + weightVariation,
        'bodyFat': baseBodyFat + bodyFatVariation,
      });
    }

    return data;
  }

  Widget _buildTrendIndicator(List<Map<String, dynamic>> data) {
    if (data.length < 2) return const SizedBox.shrink();

    final firstWeight = data.first['weight'] as double;
    final lastWeight = data.last['weight'] as double;
    final weightChange = lastWeight - firstWeight;

    final firstBodyFat = data.first['bodyFat'] as double;
    final lastBodyFat = data.last['bodyFat'] as double;
    final bodyFatChange = lastBodyFat - firstBodyFat;

    return Row(
      children: [
        Icon(
          weightChange < 0 ? Icons.trending_down : Icons.trending_up,
          size: 16,
          color: weightChange < 0 ? Colors.green : Colors.red,
        ),
        Text(
          '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)}kg',
          style: TextStyle(
            fontSize: 12,
            color: weightChange < 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          bodyFatChange < 0 ? Icons.trending_down : Icons.trending_up,
          size: 16,
          color: bodyFatChange < 0 ? Colors.green : Colors.red,
        ),
        Text(
          '${bodyFatChange >= 0 ? '+' : ''}${bodyFatChange.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: bodyFatChange < 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
            Text('Loading body metrics...'),
          ],
        ),
      ),
    );
  }

  // Empty state widget - preserved for future use
  /*
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
            SizedBox(height: 200, child: Center(child: Icon(Icons.monitor_weight, size: 64, color: Colors.grey))),
            SizedBox(height: 16),
            Text('No body metrics data available'),
            SizedBox(height: 8),
            Text('Track your weight and body fat over time!', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
  */
}
