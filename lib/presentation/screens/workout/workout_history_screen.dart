// lib/presentation/screens/history/workout_history_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../viewmodels/workout_viewmodel.dart';
import '../../../data/models/workout_model.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen>
    with SingleTickerProviderStateMixin {
  bool showDeleteAnimation = false;
  bool showEmptyAfterDelete = false;

  // Use dynamic keys because Hive keys may be int/dynamic
  final Map<dynamic, bool> _expandedStates = {};

  // Deterministic icon choice for each workout (so it doesn't change on rebuild)
  IconData _iconForWorkout(WorkoutModel w) {
    final icons = [
      Icons.fitness_center, // dumbbell
      Icons.directions_run, // running
      Icons.self_improvement, // yoga/stretch
    ];
    final idx = (w.name.hashCode.abs() + w.type.hashCode.abs()) % icons.length;
    return icons[idx];
  }

  /// --- 🧮 Stats Summary Calculation ---
  Map<String, dynamic> _calculateStats(List<WorkoutModel> workouts) {
    if (workouts.isEmpty) {
      return {
        'totalWorkouts': 0,
        'totalCalories': 0,
        'totalMinutes': 0,
        'avgIntensity': 0.0,
      };
    }

    int totalCalories = workouts.fold(0, (sum, w) => sum + w.calories);
    int totalMinutes = workouts.fold(0, (sum, w) => sum + w.duration);
    double avgIntensity =
        workouts.fold(0.0, (sum, w) => sum + w.intensity) / workouts.length;

    return {
      'totalWorkouts': workouts.length,
      'totalCalories': totalCalories,
      'totalMinutes': totalMinutes,
      'avgIntensity': avgIntensity,
    };
  }

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(workoutListProvider);
    final sortedWorkouts = [...workouts]
      ..sort((a, b) => b.date.compareTo(a.date));

    final stats = _calculateStats(sortedWorkouts);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Workout History",
          style: GoogleFonts.satisfy(
            textStyle: const TextStyle(fontSize: 24, color: Colors.blueAccent),
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          if (sortedWorkouts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: () async {
                final confirmed = await showDialog<bool?>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Clear All Workouts"),
                    content: const Text(
                      "Are you sure you want to delete all your workout sessions?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  setState(() {
                    showDeleteAnimation = true;
                    showEmptyAfterDelete = false;
                  });

                  // allow delete animation to play
                  await Future.delayed(const Duration(seconds: 2));

                  await ref.read(workoutListProvider.notifier).clearAll();

                  // short delay, then fade in empty state
                  await Future.delayed(const Duration(seconds: 1));
                  setState(() {
                    showDeleteAnimation = false;
                    showEmptyAfterDelete = true;
                  });
                }
              },
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Default empty state (if no data and not in delete flow)
          if (sortedWorkouts.isEmpty &&
              !showEmptyAfterDelete &&
              !showDeleteAnimation)
            Center(
              child: Lottie.asset(
                'assets/animations/empty.json',
                height: 200,
                repeat: false,
              ),
            ),

          // Fade-in empty after deletion
          if (showEmptyAfterDelete)
            AnimatedOpacity(
              opacity: showEmptyAfterDelete ? 1 : 0,
              duration: const Duration(milliseconds: 700),
              child: Center(
                child: Lottie.asset(
                  'assets/animations/empty.json',
                  height: 200,
                  repeat: false,
                ),
              ),
            ),

          // Main content (stats + list) when not showing delete animation and when we have workouts
          if (!showDeleteAnimation && sortedWorkouts.isNotEmpty)
            AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- 🧩 Animated Stats Header ---
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Progress Summary",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard(
                              "Workouts",
                              stats['totalWorkouts'].toString(),
                            ),
                            _buildStatCard(
                              "Calories",
                              "${stats['totalCalories']} cal",
                            ),
                            _buildStatCard(
                              "Minutes",
                              "${stats['totalMinutes']} min",
                            ),
                            _buildStatCard(
                              "Avg Intensity",
                              stats['avgIntensity'].toStringAsFixed(1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- 🏋️‍♀️ Animated list of workouts ---
                  ...AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 400),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: sortedWorkouts.map((workout) {
                      final hiveKey = workout.key;
                      final isExpanded = _expandedStates[hiveKey] ?? false;
                      final workoutIcon = _iconForWorkout(workout);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedStates[hiveKey] = !isExpanded;
                          });
                        },
                        child: AnimatedScale(
                          scale: isExpanded ? 1.02 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Dismissible(
                                  key: ValueKey(hiveKey),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    color: Colors.redAccent,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    ref
                                        .read(workoutListProvider.notifier)
                                        .deleteWorkoutByKey(hiveKey);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '"${workout.name}" deleted',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      workoutIcon,
                                      color: Colors.blueAccent,
                                    ),
                                    title: Text(
                                      workout.name,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${workout.type} • ${workout.duration} min • ${workout.calories} cal\n"
                                      "${DateFormat.yMMMd().format(workout.date)}",
                                      style: GoogleFonts.poppins(fontSize: 13),
                                    ),
                                    trailing: Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                AnimatedCrossFade(
                                  firstChild: const SizedBox.shrink(),
                                  secondChild: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Intensity: ${workout.intensity.toStringAsFixed(1)}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Notes: ${workout.notes.isEmpty ? 'None' : workout.notes}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  crossFadeState: isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 300),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // 🔥 Delete animation overlay
          if (showDeleteAnimation)
            Container(
              color: Colors.black54,
              child: Center(
                child: Lottie.asset(
                  'assets/animations/delete.json',
                  width: 220,
                  repeat: false,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
