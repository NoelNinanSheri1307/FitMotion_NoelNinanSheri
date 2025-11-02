import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    ],
  );
}
