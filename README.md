FitMotion — Animated Fitness Tracker

Developer: Noel Ninan Sheri
Submission: Frontend Developer Upskilling Task
Deadline: November 2, 2025
Framework: Flutter
Architecture: Clean Architecture (MVVM)
State Management: Riverpod

Project Overview

FitMotion is a Flutter-based fitness tracking application that enables users to track their workouts, view activity history, monitor progress, and set daily reminders.
The focus of the project is on clean architecture, advanced animations, efficient state management, and performance optimization using Flutter DevTools.

Core Objectives

Implement a modular, scalable architecture using the Clean Architecture and MVVM pattern.

Demonstrate advanced Flutter animations (Lottie, AnimatedBuilder, implicit/explicit transitions).

Utilize Riverpod for efficient state management and performance.

Ensure smooth UI transitions and consistent responsiveness across devices.

Optimize performance with widget caching, proper rebuild management, and Flutter DevTools profiling.

Architecture Overview
lib/
├── core/
│ ├── theme/ # Theme data, colors, and typography
│ ├── routing/ # Route definitions (Navigator 2.0 / GoRouter)
│ └── constants/ # Application-wide constants
│
├── data/
│ ├── models/ # Data models (Workout, UserProfile, etc.)
│ └── services/ # Local storage, notification, and data layer
│
├── presentation/
│ ├── screens/
│ │ ├── onboarding/ # Animated onboarding slides
│ │ ├── auth/ # Login and registration screens
│ │ ├── home/ # Dashboard with activity stats
│ │ ├── history/ # Workout history list with animations
│ │ ├── add_workout/ # Add workout form and validation
│ │ ├── profile/ # Profile settings and notifications
│ │ └── achievements/ # Weekly challenges and animated rewards
│ │
│ └── widgets/ # Reusable UI components
│
├── viewmodels/ # Riverpod providers and controllers
│
└── main.dart # Application entry point

Core Screens
Screen Description Features
Onboarding Flow Introductory slides explaining app features Smooth page transitions
Authentication Login and registration Animated input validation
Home Dashboard Displays live stats Animated progress bars and quick actions
Workout History Shows past workouts Filterable, animated cards
Add Workout Add workout sessions Validation with animation feedback
Profile Settings Manage user profile Edit info, password, theme, notifications
Achievements/Quizzes User challenges Animated achievements and rewards
Animation Techniques

Lottie animations for success, logout, and loading states.

AnimatedBuilder for shake animation during password error input.

AnimatedContainer and AnimatedOpacity for smooth transitions.

Custom PageRouteBuilder for fade and slide screen transitions.

Theme and Preferences

Dynamic light/dark theme toggle using Riverpod.

Notification scheduling using flutter_local_notifications.

Local persistence through Hive and SharedPreferences.

Logout animation with fade transition to authentication screen.

State Management (Riverpod)

themeProvider: Handles theme mode toggling.

authProvider: Tracks authentication state.

workoutProvider: Manages user workouts.

historyProvider: Streams workout history data.

Providers are scoped and disposed properly to prevent memory leaks.

Performance Optimization

Use of ListView.builder for dynamic lists.

Cached images using cached_network_image.

Repaint boundaries applied to complex animated widgets.

Reduced rebuilds through isolated providers.

Performance profiling via Flutter DevTools (FPS, memory, rebuild counts).

Testing

Widget tests for animation triggers and Riverpod state updates.

Verified layout responsiveness across multiple screen sizes.

Manual and automated testing for navigation and performance stability.

Local Storage

Hive for storing user profile information.

SharedPreferences for theme and notification settings.

flutter_local_notifications for local reminder scheduling.

Tech Stack
Category Technology
Framework Flutter (latest stable)
Language Dart
State Management Riverpod
Architecture MVVM / Clean Architecture
Routing GoRouter / Navigator 2.0
Database Hive
Animations Lottie, AnimatedBuilder, AnimatedContainer
Notifications flutter_local_notifications
Tools Flutter DevTools, SharedPreferences
Performance Profiling Report

Average FPS maintained between 58–60 during animations.

No observable memory leaks (confirmed via DevTools).

Rebuild counts minimized using const widgets and isolated providers.

RepaintBoundary applied for expensive widget trees.

Cached images improved load efficiency by approximately 70%.

Creator Information

Developer: Noel Ninan Sheri
Date: November 2 2025

Setup Instructions
Prerequisites

Flutter SDK (latest stable)

Android Studio or VS Code

Android/iOS emulator

Git installed and configured

1. Clone the Repository
   git clone https://github.com/<your-username>/FitMotion_Noel.git
   cd FitMotion_Noel

2. Install Dependencies
   flutter pub get

3. Hive Setup (if applicable)
   flutter packages pub run build_runner build

4. Run the App
   flutter run

5. Build for Release
   flutter build apk --release

Demo Features Checklist

Onboarding animation

Authentication with animated transitions

Home dashboard with live stats

Workout history list with filters and animations

Add workout screen with validation

Profile settings with editable info and notifications

Logout animation and About screen

Dark/light theme toggle

Future Improvements

Integration with Google Fit or Apple Health
Cloud synchronization for workouts
Community leaderboard
AI-based workout suggestions

Submission Summary
Deliverable Status
7+ Functional Screens Completed
Riverpod State Management Completed
Clean Architecture Completed
Multiple Animation Techniques Completed
Performance Optimized Completed
README + Profiling Report Completed
