import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('fitmotionBox');
  runApp(const ProviderScope(child: FitMotionApp()));
}

class FitMotionApp extends StatelessWidget {
  const FitMotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FitMotion',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
