import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FitMotion Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Just to test navigation back to onboarding for now
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logout coming soon!")),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome to FitMotion 🎯", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
