import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FunFactsScreen extends StatefulWidget {
  const FunFactsScreen({super.key});

  @override
  State<FunFactsScreen> createState() => _FunFactsScreenState();
}

class _FunFactsScreenState extends State<FunFactsScreen> {
  final List<bool> _expandedStates = [false, false, false, false, false];

  final List<Map<String, String>> funFacts = [
    {
      "title": "Stay Hydrated, Perform Better",
      "image": "assets/images/funfacts/hydration.jpg",
      "text":
          "Even mild dehydration can reduce your physical performance by up to 20%. Always hydrate before, during, and after workouts to maintain stamina and mental clarity. Keeping your body well-hydrated also improves focus, skin health, and joint lubrication.",
    },
    {
      "title": "Recovery Starts with Sleep",
      "image": "assets/images/funfacts/sleep.jpg",
      "text":
          "Muscle recovery and growth occur primarily during deep sleep. Aim for 7–9 hours per night to optimize hormone balance, repair tissues, and improve overall energy levels. A proper sleep schedule is as vital as your training routine.",
    },
    {
      "title": "Flexibility is Power",
      "image": "assets/images/funfacts/stretch.jpg",
      "text":
          "Stretching enhances circulation, prevents injuries, and improves overall movement efficiency. Incorporating stretching or yoga into your weekly routine keeps muscles supple and posture aligned, supporting better athletic performance.",
    },
    {
      "title": "Eat for Energy, Not Just Calories",
      "image": "assets/images/funfacts/nutrition.jpg",
      "text":
          "Balanced meals rich in protein, complex carbs, and healthy fats fuel your workouts and recovery. Nutrition makes up 70% of fitness success, supporting both physical strength and mental focus. Prioritize whole foods for lasting energy.",
    },
    {
      "title": "Outdoor Workouts Boost Happiness",
      "image":
          "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80",
      "text":
          "Exercising outdoors increases serotonin levels, boosts Vitamin D, and reduces stress. Studies show people who train outdoors are more consistent and report higher happiness. So, take your next workout to the park or beach!",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(
          "Did you know?",
          style: GoogleFonts.satisfy(
            textStyle: const TextStyle(fontSize: 24, color: Colors.blueAccent),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.blueAccent.withOpacity(0.3),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: funFacts.length,
        itemBuilder: (context, index) {
          final fact = funFacts[index];
          final isExpanded = _expandedStates[index];

          return FadeInUp(
            duration: Duration(milliseconds: 400 + (index * 100)),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _expandedStates[index] = !_expandedStates[index];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 🖼️ Image Section (local or network)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: fact["image"]!.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: fact["image"]!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
                                color: Colors.black54,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.redAccent,
                                  size: 40,
                                ),
                              ),
                            )
                          : Image.asset(
                              fact["image"]!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),

                    // 🧠 Title + Expandable Text
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fact["title"]!,
                            style: const TextStyle(
                              fontFamily: 'Times New Roman',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF0EAD6), // ivory
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 500),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                fact["text"]!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFFF5F5DC),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
