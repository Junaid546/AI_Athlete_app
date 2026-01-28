import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../theme/app_theme.dart';
import '../providers/progress_provider.dart';

class ProgressAnalyticsScreen extends ConsumerStatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  ConsumerState<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends ConsumerState<ProgressAnalyticsScreen>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        title: Text(
          'Progress Analytics',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: PopupMenuButton(
                onSelected: (value) {
                  setState(() => _selectedPeriod = value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: TimePeriod.daily,
                    child: Row(
                      children: [
                        const Icon(Icons.today),
                        const SizedBox(width: 8),
                        const Text('Daily'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TimePeriod.weekly,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_view_week),
                        const SizedBox(width: 8),
                        const Text('Weekly'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TimePeriod.monthly,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 8),
                        const Text('Monthly'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: TimePeriod.yearly,
                    child: Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 8),
                        const Text('Yearly'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getPeriodLabel(_selectedPeriod),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more, color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'Volume'),
            Tab(icon: Icon(Icons.fire_truck), text: 'Calories'),
            Tab(icon: Icon(Icons.schedule), text: 'Duration'),
            Tab(icon: Icon(Icons.trending_up), text: 'Exercises'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Statistics Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildStatisticsCards(context, isDark),
              ),
              
              // Tab Content
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVolumeChart(context, isDark),
                    _buildCaloriesChart(context, isDark),
                    _buildDurationChart(context, isDark),
                    _buildExercisesChart(context, isDark),
                  ],
                ),
              ),
              
              // Download PDF Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildDownloadButton(context, isDark),
              ),
              
              // Detailed Metrics
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildDetailedMetrics(context, isDark),
              ),
              
              // Achievement Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildAchievements(context, isDark),
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

  Widget _buildStatisticsCards(BuildContext context, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _StatCard(
          title: 'Total Workouts',
          value: '24',
          icon: Icons.fitness_center,
          color: Colors.blue,
          isDark: isDark,
        ),
        _StatCard(
          title: 'Total Volume',
          value: '45,230 kg',
          icon: Icons.show_chart,
          color: Colors.purple,
          isDark: isDark,
        ),
        _StatCard(
          title: 'Calories Burned',
          value: '8,540',
          icon: Icons.local_fire_department,
          color: Colors.orange,
          isDark: isDark,
        ),
        _StatCard(
          title: 'Current Streak',
          value: '12 days',
          icon: Icons.local_fire_department,
          color: Colors.red,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildVolumeChart(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1000,
            verticalInterval: 1,
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
                interval: 1000,
                getTitlesWidget: (value, meta) {
                  return Text('${(value / 1000).toStringAsFixed(0)}k',
                      style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
              left: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 5000,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 1500),
                FlSpot(1, 1800),
                FlSpot(2, 2100),
                FlSpot(3, 2500),
                FlSpot(4, 2200),
                FlSpot(5, 2800),
                FlSpot(6, 3200),
              ],
              isCurved: true,
              gradient: const LinearGradient(
                colors: [AppTheme.primaryStart, AppTheme.primaryEnd],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryStart.withOpacity(0.3),
                    AppTheme.primaryEnd.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1000,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(toY: 400, color: Colors.orange, width: 15),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: 550, color: Colors.orange, width: 15),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(toY: 480, color: Colors.orange, width: 15),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(toY: 620, color: Colors.orange, width: 15),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(toY: 520, color: Colors.orange, width: 15),
            ]),
            BarChartGroupData(x: 5, barRods: [
              BarChartRodData(toY: 680, color: Colors.orange, width: 15),
            ]),
            BarChartGroupData(x: 6, barRods: [
              BarChartRodData(toY: 750, color: Colors.orange, width: 15),
            ]),
          ],
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildDurationChart(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: LineChart(
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
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() < titles.length) {
                    return Text(titles[value.toInt()], style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}m', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 45),
                FlSpot(1, 50),
                FlSpot(2, 48),
                FlSpot(3, 60),
                FlSpot(4, 55),
                FlSpot(5, 65),
                FlSpot(6, 70),
              ],
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.3),
                    const Color(0xFF059669).withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesChart(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.blue,
              value: 30,
              title: 'Chest',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              color: Colors.purple,
              value: 25,
              title: 'Back',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: 20,
              title: 'Legs',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              color: Colors.green,
              value: 15,
              title: 'Arms',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            PieChartSectionData(
              color: Colors.red,
              value: 10,
              title: 'Core',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _generateAndDownloadPDF(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Download Progress Report (PDF)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetrics(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Metrics',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        _MetricRow(
          label: 'Average Session Duration',
          value: '52 minutes',
          icon: Icons.schedule,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Favorite Exercise',
          value: 'Bench Press',
          icon: Icons.fitness_center,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Best Month Volume',
          value: '89,450 kg',
          icon: Icons.trending_up,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Weekly Average',
          value: '4.2 sessions',
          icon: Icons.calendar_view_week,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildAchievements(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements & Milestones',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _AchievementBadge(
                icon: Icons.emoji_events,
                label: '100 Workouts',
                color: Colors.amber,
                isDark: isDark,
              ),
              _AchievementBadge(
                icon: Icons.local_fire_department,
                label: '10K Calories',
                color: Colors.orange,
                isDark: isDark,
              ),
              _AchievementBadge(
                icon: Icons.trending_up,
                label: 'Personal Records',
                color: Colors.blue,
                isDark: isDark,
              ),
              _AchievementBadge(
                icon: Icons.bolt,
                label: '7-Day Streak',
                color: Colors.purple,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndDownloadPDF(BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Progress Analytics Report',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Summary Statistics'),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Workouts')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('24')),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Volume')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('45,230 kg')),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Calories Burned')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('8,540')),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Current Streak')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('12 days')),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Progress report downloaded successfully!'),
              ],
            ),
            backgroundColor: AppTheme.secondaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
