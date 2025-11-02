import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  bool _isLoading = true;
  bool _alreadyTakenToday = false;

  final GlobalKey _trophyKey = GlobalKey();
  late Box _quizBox;

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "What’s the best time to work out?",
      "options": ["Morning", "Evening", "Whenever consistent", "Night"],
      "answer": "Whenever consistent",
    },
    {
      "question": "Which nutrient helps repair muscles?",
      "options": ["Protein", "Carbs", "Fats", "Vitamins"],
      "answer": "Protein",
    },
    {
      "question": "How much water should you drink daily?",
      "options": ["1L", "2L+", "500ml", "4L+"],
      "answer": "2L+",
    },
    {
      "question": "Stretching improves?",
      "options": ["Balance", "Flexibility", "Endurance", "Speed"],
      "answer": "Flexibility",
    },
    {
      "question": "What is BMI short for?",
      "options": [
        "Body Mass Index",
        "Basic Metabolic Intake",
        "Body Motion Indicator",
        "None",
      ],
      "answer": "Body Mass Index",
    },
    {
      "question": "Sleep helps with muscle recovery.",
      "options": ["True", "False"],
      "answer": "True",
    },
    {
      "question": "How many main macronutrients exist?",
      "options": ["2", "3", "4", "5"],
      "answer": "3",
    },
    {
      "question": "Cardio helps mainly with?",
      "options": ["Flexibility", "Endurance", "Muscle Gain", "Posture"],
      "answer": "Endurance",
    },
    {
      "question": "Hydration affects mental performance.",
      "options": ["True", "False"],
      "answer": "True",
    },
    {
      "question": "Best post-workout meal includes?",
      "options": ["Pizza", "Protein & Carbs", "Ice Cream", "Just Water"],
      "answer": "Protein & Carbs",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _quizBox = await Hive.openBox('quizHistory');
    _checkTodayStatus();
  }

  void _checkTodayStatus() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastEntry = _quizBox.get('lastQuizDate');
    if (lastEntry == today) {
      setState(() => _alreadyTakenToday = true);
    }
    setState(() => _isLoading = false);
  }

  void _answerQuestion(String selected) {
    final correctAnswer = _questions[_currentQuestionIndex]['answer'];
    if (selected == correctAnswer) _score++;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    setState(() => _quizCompleted = true);

    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    await _quizBox.add({
      'score': _score,
      'total': _questions.length,
      'datetime': formatted,
    });
    await _quizBox.put('lastQuizDate', DateFormat('yyyy-MM-dd').format(now));
  }

  // 📸 Capture screenshot and share
  Future<void> _captureAndShareScreenshot() async {
    try {
      final boundary =
          _trophyKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await XFile.fromData(
        pngBytes,
        name: 'quiz_trophy.png',
        mimeType: 'image/png',
      );

      await Share.shareXFiles(
        [tempDir],
        text:
            'I just scored $_score/${_questions.length} in today’s Fitness Quiz!  #DailyFitnessQuiz',
      );
    } catch (e) {
      debugPrint('Error capturing screenshot: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture screenshot')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(
          "Daily Fitness Quiz",
          style: GoogleFonts.satisfy(
            textStyle: const TextStyle(fontSize: 24, color: Colors.blueAccent),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: _alreadyTakenToday
          ? _buildHistorySection()
          : _quizCompleted
          ? _buildTrophyScreen() // stays here until user leaves
          : _buildQuizQuestion(),
    );
  }

  // 🧠 Quiz question UI
  Widget _buildQuizQuestion() {
    final question = _questions[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.blueAccent),
          ),
          const SizedBox(height: 20),
          Text(
            question["question"],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
          ...question["options"].map<Widget>((opt) {
            return GestureDetector(
              onTap: () => _answerQuestion(opt),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  opt,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 🏆 Trophy animation + Share option
  Widget _buildTrophyScreen() {
    return Center(
      child: RepaintBoundary(
        key: _trophyKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/trophy.json',
              height: 260,
              repeat: true, // keeps looping forever
            ),
            const SizedBox(height: 24),
            Text(
              "You scored $_score / ${_questions.length}!",
              style: GoogleFonts.poppins(
                color: Colors.blueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Keep learning and grow stronger!",
              style: GoogleFonts.poppins(
                color: Colors.greenAccent,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _captureAndShareScreenshot,
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                "Share My Achievement",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Back",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📜 History view
  Widget _buildHistorySection() {
    final history = _quizBox.values
        .where((entry) => entry is Map)
        .toList()
        .reversed
        .take(10)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          Text(
            "Past Quiz Results",
            style: GoogleFonts.poppins(
              color: Colors.blueAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Center(
              child: Text(
                "No quizzes taken yet.",
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            ...history.map((h) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${h['score']} / ${h['total']}",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      h['datetime'],
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
