import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_session.dart';

class WorkoutSessionsNotifier extends StateNotifier<List<WorkoutSession>> {
  WorkoutSessionsNotifier() : super([]);

  void addSession(WorkoutSession session) {
    state = [...state, session];
  }

  void removeSession(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final workoutSessionsProvider = StateNotifierProvider<WorkoutSessionsNotifier, List<WorkoutSession>>((ref) {
  return WorkoutSessionsNotifier();
});
