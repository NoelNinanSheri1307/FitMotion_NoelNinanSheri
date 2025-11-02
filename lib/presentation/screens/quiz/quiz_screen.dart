import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take a Quiz"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          "Quiz Screen (Coming Soon)",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}
