import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout History"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          "Workout History Screen (Coming Soon)",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}
