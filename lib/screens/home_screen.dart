import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider_firebase.dart';
import '../providers/workout_sessions_provider.dart';
import '../providers/ai_quote_provider.dart';
import '../providers/theme_provider.dart';
import 'workout_plans_screen.dart';
import 'log_session_screen.dart';
import 'progress_screen.dart';
import 'ai_insights_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final sessions = ref.watch(workoutSessionsProvider);
    final quoteAsync = ref.watch(aiQuoteProvider);
    final theme = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate all metrics once
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    
    final todaySessions = sessions.where((s) {
      final sDate = DateTime(s.date.year, s.date.month, s.date.day);
      return sDate == todayNormalized;
    }).toList();
    
    final todayDuration = todaySessions.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + s.duration,
    );

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekStartNormalized = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weeklySessions = sessions.where((s) => s.date.isAfter(weekStartNormalized.subtract(const Duration(days: 1))));
    final weeklyWorkouts = weeklySessions.length;

    final monthStart = DateTime(today.year, today.month, 1);
    final monthlySessions = sessions.where((s) => s.date.isAfter(monthStart.subtract(const Duration(days: 1))));
    final monthlyWorkouts = monthlySessions.length;

    // Use userProfileProvider as single source of truth for consistent data across all screens
    final streak = profile?.currentStreak ?? 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFAFAFA),
      appBar: _buildAppBar(context, isDark, theme),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(workoutSessionsProvider);
          ref.invalidate(userProfileProvider);
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildWelcomeHeader(context, profile?.name ?? 'Athlete', isDark),
            const SizedBox(height: 24),

            // Hero Card - Main Stats
            _buildHeroCard(context, todaySessions, todayDuration, streak, isDark, theme),
            const SizedBox(height: 20),

            // Weekly & Monthly Stats
            _buildWeeklyMonthlyStats(context, weeklyWorkouts, monthlyWorkouts, isDark),
            const SizedBox(height: 20),

            // Quick Actions Grid
            _buildQuickActionsGrid(context),
            const SizedBox(height: 20),

            // AI Quote Section
            _buildPremiumQuoteCard(context, quoteAsync, isDark),
            const SizedBox(height: 20),

            // Performance Overview
            _buildPerformanceOverview(context, profile, sessions, isDark),
            const SizedBox(height: 20),

            // Recent Activity
            _buildRecentActivity(context, todaySessions, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark, ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'AthletePro',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, String name, bool isDark) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 18) greeting = 'Good Afternoon';
    if (hour >= 18) greeting = 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Welcome back, $name 👋',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, List todaySessions, Duration todayDuration, int streak, bool isDark, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [theme.primaryColor.withOpacity(0.8), theme.primaryColor]
            : [theme.primaryColor.withOpacity(0.6), theme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Focus",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${todaySessions.length} Workouts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (todaySessions.length / 3).clamp(0, 1).toDouble(),
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(
                  Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroMetric('Duration', '${todayDuration.inMinutes}m', Icons.timer),
              _buildHeroMetric('Streak', '$streak days', Icons.local_fire_department),
              _buildHeroMetric('Goal', '${(todaySessions.length / 3 * 100).toStringAsFixed(0)}%', Icons.flag),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyMonthlyStats(BuildContext context, int weeklyWorkouts, int monthlyWorkouts, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            context,
            'This Week',
            weeklyWorkouts.toString(),
            'workouts',
            Colors.blue,
            Icons.calendar_view_week,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            context,
            'This Month',
            monthlyWorkouts.toString(),
            'workouts',
            Colors.purple,
            Icons.calendar_month,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String title, String value, String subtitle, Color color, IconData icon, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      ('Log Workout', Icons.add_circle, Colors.green, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LogSessionScreen()),
        );
      }),
      ('View Plans', Icons.fitness_center, Colors.blue, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const WorkoutPlansScreen()),
        );
      }),
      ('Progress', Icons.show_chart, Colors.orange, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProgressScreen()),
        );
      }),
      ('AI Insights', Icons.lightbulb, Colors.purple, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AiInsightsScreen()),
        );
      }),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        actions.length,
        (index) => _buildActionCard(
          context,
          actions[index].$1,
          actions[index].$2,
          actions[index].$3,
          actions[index].$4,
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumQuoteCard(BuildContext context, AsyncValue<String> quoteAsync, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [const Color(0xFF1A1A1A), const Color(0xFF252525)]
            : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            size: 40,
            color: const Color(0xFF667EEA).withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          quoteAsync.maybeWhen(
            data: (quote) => Text(
              '"$quote"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.6,
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, st) => Text(
              'Train hard, stay consistent!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            orElse: () => Text(
              'Loading inspiration...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview(BuildContext context, dynamic profile, List sessions, bool isDark) {
    final allTimeWorkouts = sessions.length;
    final avgSessionDuration = sessions.isEmpty 
      ? 0 
      : sessions.fold<double>(0.0, (sum, s) => sum + s.duration.inMinutes).toInt() ~/ sessions.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildPerformanceRow('Total Workouts', allTimeWorkouts.toString(), Colors.blue, isDark),
          const SizedBox(height: 12),
          _buildPerformanceRow('Avg. Duration', '${avgSessionDuration}m', Colors.green, isDark),
          const SizedBox(height: 12),
          _buildPerformanceRow('Total Volume', '${(profile?.totalVolume ?? 0).toStringAsFixed(0)} kg', Colors.orange, isDark),
          const SizedBox(height: 12),
          _buildPerformanceRow('Personal Best', '${(profile?.totalVolume ?? 0).toStringAsFixed(0)} kg', Colors.red, isDark),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value, Color color, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, List todaySessions, bool isDark) {
    if (todaySessions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: isDark ? Colors.white30 : Colors.black12,
            ),
            const SizedBox(height: 12),
            Text(
              'No Workouts Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start your first workout to see activity here',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            todaySessions.take(3).length,
            (index) {
              final session = todaySessions[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index < todaySessions.length - 1 ? 12 : 0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fitness_center, color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completed Session',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '${session.duration.inMinutes} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (todaySessions.length > 3) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                '+${todaySessions.length - 3} more',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF667EEA),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

}
