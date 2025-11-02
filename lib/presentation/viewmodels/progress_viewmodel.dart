import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StreamProvider for live daily progress updates
final dailyProgressProvider = StreamProvider<double>((ref) {
  final controller = StreamController<double>();
  double progress = 0.0;

  // Simulate real-time updates (like steps or calories)
  Timer.periodic(const Duration(seconds: 2), (timer) {
    progress += 0.05;
    if (progress > 1.0) progress = 1.0;
    controller.add(progress);

    // Stop when 100% reached
    if (progress >= 1.0) {
      timer.cancel();
      controller.close();
    }
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});
