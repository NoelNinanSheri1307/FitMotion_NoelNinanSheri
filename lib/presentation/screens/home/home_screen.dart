import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/progress_viewmodel.dart';
import 'package:lottie/lottie.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this in pubspec.yaml
import '../workout/add_workout_screen.dart';
import '../workout/workout_history_screen.dart';
import '../quiz/quiz_screen.dart';
import '../funfacts/fun_facts_screen.dart';
import '../profile/profile_settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int _quoteIndex = 0;
  late Timer _quoteTimer;
  double _progress = 0.68; // Example progress value (68%)

  final List<String> _quotes = [
    "Push yourself, because no one else is going to do it for you.",
    "The body achieves what the mind believes.",
    "Don’t stop when you’re tired. Stop when you’re done.",
    "Your only limit is you.",
    "Sweat is just fat crying.",
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % _quotes.length;
      });
    });
  }

  void _navigateWithSlide(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide from right
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _quoteTimer.cancel();
    super.dispose();
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ?? Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning, Noel!";
    if (hour < 17) return "Good Afternoon, Noel!";
    if (hour < 20) return "Good Evening, Noel!";
    return "Good Night, Noel!";
  }

  Widget _buildProgressRing() {
    final progressAsync = ref.watch(dailyProgressProvider);

    return progressAsync.when(
      data: (progress) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(seconds: 1),
          builder: (context, value, _) => Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blueAccent,
                ),
              ),
              Text(
                "${(value * 100).toInt()}%",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, _) => Text("Error: $err"),
    );
  }

  Widget _buildActivityGraph() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, _) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 30),
          child: SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 5),
                      FlSpot(2, 3),
                      FlSpot(3, 7),
                      FlSpot(4, 6),
                      FlSpot(5, 8),
                      FlSpot(6, 5),
                    ],
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withOpacity(0.2),
                    ),
                    color: Colors.blueAccent,
                    dotData: FlDotData(show: false),
                    barWidth: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FitMotion Dashboard",
          style: GoogleFonts.satisfy(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.blueAccent),
            onPressed: () =>
                _navigateWithSlide(context, const ProfileSettingsScreen()),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _greeting(),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Daily Progress Ring
                Center(child: _buildProgressRing()),

                const SizedBox(height: 30),

                // Animated Activity Graph
                Text(
                  "Weekly Activity",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),
                _buildActivityGraph(),

                const SizedBox(height: 30),

                // Grid Sections
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildSectionCard(
                      icon: Icons.fitness_center,
                      title: "Add Workout",
                      onTap: () =>
                          _navigateWithSlide(context, const AddWorkoutScreen()),
                    ),
                    _buildSectionCard(
                      icon: Icons.history,
                      title: "Workout History",
                      onTap: () => _navigateWithSlide(
                        context,
                        const WorkoutHistoryScreen(),
                      ),
                    ),
                    _buildSectionCard(
                      icon: Icons.quiz,
                      title: "Take Quiz",
                      onTap: () =>
                          _navigateWithSlide(context, const QuizScreen()),
                    ),
                    _buildSectionCard(
                      icon: Icons.lightbulb_outline,
                      title: "Fun Facts",
                      onTap: () =>
                          _navigateWithSlide(context, const FunFactsScreen()),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Animated Motivational Quote
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    _quotes[_quoteIndex],
                    key: ValueKey(_quoteIndex),
                    style: GoogleFonts.satisfy(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(221, 235, 243, 165),
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  "Stay consistent. Progress comes one rep at a time.",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
