import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'data/models/workout_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Hive
  await Hive.initFlutter();

  // ✅ Register all model adapters
  Hive.registerAdapter(WorkoutModelAdapter());

  // ✅ Open the main box where workouts will be stored
  await Hive.openBox<WorkoutModel>('workouts');

  // ✅ Load SharedPreferences for onboarding
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // ✅ Launch app
  runApp(
    ProviderScope(child: FitMotionApp(hasSeenOnboarding: hasSeenOnboarding)),
  );
}

class FitMotionApp extends ConsumerWidget {
  final bool hasSeenOnboarding;
  const FitMotionApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'FitMotion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: hasSeenOnboarding ? const AuthScreen() : const OnboardingScreen(),
    );
  }
}
