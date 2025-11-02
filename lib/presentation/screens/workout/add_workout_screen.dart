import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddWorkoutScreen extends StatelessWidget {
  const AddWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          "Add Workout Screen (Coming Soon)",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}
