import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          "Profile Settings Screen (Coming Soon)",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}
