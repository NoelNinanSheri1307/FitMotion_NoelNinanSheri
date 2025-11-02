import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FunFactsScreen extends StatelessWidget {
  const FunFactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fun Fitness Facts"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          "Fun Facts Screen (Coming Soon)",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}
