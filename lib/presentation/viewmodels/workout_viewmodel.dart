import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/workout_model.dart';

final workoutListProvider =
    StateNotifierProvider<WorkoutNotifier, List<WorkoutModel>>((ref) {
      return WorkoutNotifier();
    });

class WorkoutNotifier extends StateNotifier<List<WorkoutModel>> {
  WorkoutNotifier() : super([]) {
    _loadWorkouts();
  }

  final _box = Hive.box<WorkoutModel>('workouts');

  void _loadWorkouts() {
    state = _box.values.toList();
  }

  Future<void> addWorkout(
    String name,
    int duration,
    int calories,
    String type,
    DateTime date,
    double intensity,
    String notes,
  ) async {
    final newWorkout = WorkoutModel(
      name: name,
      duration: duration,
      calories: calories,
      type: type,
      date: date,
      intensity: intensity,
      notes: notes,
    );

    await _box.add(newWorkout);
    _loadWorkouts();
  }

  /// Delete by hive key (recommended)
  Future<void> deleteWorkoutByKey(dynamic key) async {
    await _box.delete(key);
    _loadWorkouts();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _loadWorkouts();
  }
}
