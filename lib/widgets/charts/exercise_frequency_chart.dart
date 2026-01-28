import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/workout_session.dart';

class ExerciseFrequencyChart extends StatefulWidget {
  final List<WorkoutSession> workoutSessions;
  final bool isLoading;

  const ExerciseFrequencyChart({
    super.key,
    required this.workoutSessions,
    this.isLoading = false,
  });

  @override
  State<ExerciseFrequencyChart> createState() => _ExerciseFrequencyChartState();
}

class _ExerciseFrequencyChartState extends State<ExerciseFrequencyChart>
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

    final frequencyData = _calculateExerciseFrequency();

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
                  'Exercise Frequency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(frequencyData),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          startDegreeOffset: 180,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: frequencyData.map((data) {
                          final index = frequencyData.indexOf(data);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getColor(index),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    data['exercise'] as String,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${data['count']}x',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Top 5 exercises by workout frequency',
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

  List<PieChartSectionData> _buildPieSections(List<Map<String, dynamic>> data) {
    return List.generate(data.length, (index) {
      final item = data[index];
      final count = item['count'] as int;
      final total = data.fold<int>(0, (sum, item) => sum + (item['count'] as int));
      final percentage = total > 0 ? (count / total) * 100 : 0;

      return PieChartSectionData(
        color: _getColor(index),
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60 + (_animation.value * 20),
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _animation.value > 0.5 ? Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getColor(index),
              ),
            ),
          ),
        ) : null,
        badgePositionPercentageOffset: 1.2,
      );
    });
  }

  Color _getColor(int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  List<Map<String, dynamic>> _calculateExerciseFrequency() {
    final exerciseCount = <String, int>{};

    for (final session in widget.workoutSessions) {
      for (final exercise in session.exercises) {
        final name = exercise.exercise.name;
        exerciseCount[name] = (exerciseCount[name] ?? 0) + 1;
      }
    }

    final sorted = exerciseCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => {'exercise': e.key, 'count': e.value}).toList();
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
            Text('Loading exercise frequency...'),
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
            SizedBox(height: 200, child: Center(child: Icon(Icons.pie_chart, size: 64, color: Colors.grey))),
            SizedBox(height: 16),
            Text('No exercise data available'),
            SizedBox(height: 8),
            Text('Complete workouts to see exercise frequency!', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
