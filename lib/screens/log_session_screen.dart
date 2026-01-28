import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_session.dart';
import '../providers/workout_sessions_provider.dart';
import '../providers/workout_plans_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider_firebase.dart';
import '../utils/app_utils.dart';

class LogSessionScreen extends ConsumerStatefulWidget {
  const LogSessionScreen({super.key});

  @override
  ConsumerState<LogSessionScreen> createState() => _LogSessionScreenState();
}

class _LogSessionScreenState extends ConsumerState<LogSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPlan;
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  final _caloriesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _submitSession() async {
    if (!_formKey.currentState!.validate() || _selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final plansAsync = ref.read(workoutPlansProvider);
      await plansAsync.maybeWhen(
        data: (plans) async {
          final plan = plans.firstWhere((p) => p.id == _selectedPlan);
          final session = WorkoutSession(
            id: DateTime.now().toString(),
            userId: 'current-user',
            startTime: DateTime.now(),
            planId: plan.id,
            planName: plan.name,
            exercises: [],
            actualDuration: Duration(minutes: int.parse(_durationController.text)),
            notes: _notesController.text,
            caloriesBurned: (int.tryParse(_caloriesController.text) ?? 0).toDouble(),
            createdAt: DateTime.now(),
          );

          ref.read(workoutSessionsProvider.notifier).addSession(session);

          // Update profile with streak and workout stats
          final updatedSessions = ref.read(workoutSessionsProvider);
          final currentStreak = calculateCurrentStreak(updatedSessions);
          final longestStreak = calculateLongestStreak(updatedSessions);
          
          // Calculate total volume from all sessions
          double totalVolume = 0;
          for (final s in updatedSessions) {
            for (final exercise in s.exercises) {
              for (final set in exercise.sets) {
                final weight = set.weight ?? 0;
                final reps = set.reps ?? 0;
                totalVolume += (weight * reps).toDouble();
              }
            }
          }

          final currentProfile = ref.read(userProfileProvider);
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(
              currentStreak: currentStreak,
              longestStreak: longestStreak,
              totalWorkouts: updatedSessions.length,
              totalVolume: totalVolume,
              lastWorkoutDate: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await ref.read(userProfileProvider.notifier).updateProfile(updatedProfile);
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session logged successfully! 🎉'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.of(context).pop();
          }
        },
        orElse: () async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Plans not loaded yet. Please wait.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(workoutPlansProvider);
    final theme = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Training Session'),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      body: plans.when(
        data: (data) => Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Workout Plan Dropdown
                  Text(
                    'Select Workout Plan *',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPlan,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        hintText: 'Choose a plan',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      items: data.map((plan) {
                        return DropdownMenuItem(
                          value: plan.id,
                          child: Text(
                            plan.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPlan = value);
                      },
                      validator: (value) => value == null ? 'Please select a plan' : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Duration Input
                  Text(
                    'Duration (minutes) *',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g., 60',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
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
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.schedule),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter duration';
                      final duration = int.tryParse(value);
                      if (duration == null || duration <= 0) return 'Please enter a valid duration';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Calories Input
                  Text(
                    'Calories Burned (optional)',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g., 350',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
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
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.local_fire_department),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 20),

                  // Notes Input
                  Text(
                    'Notes (optional)',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'How did the session go? Any notes?',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
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
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitSession,
                      icon: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primaryColor,
                                ),
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: Text(
                        _isSubmitting ? 'Logging Session...' : 'Log Session',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: theme.primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.primaryColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading plans: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(workoutPlansProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
