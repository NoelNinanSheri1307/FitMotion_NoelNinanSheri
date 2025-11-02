class OnboardingPageModel {
  final String title;
  final String subtitle;
  final String animationPath;

  OnboardingPageModel({
    required this.title,
    required this.subtitle,
    required this.animationPath,
  });
}

final onboardingPages = [
  OnboardingPageModel(
    title: "Track Your Workouts",
    subtitle: "Stay on top of your fitness goals with live progress updates.",
    animationPath: "assets/animations/onboarding1.json",
  ),
  OnboardingPageModel(
    title: "Visualize Your Progress",
    subtitle:
        "Beautiful charts and summaries help you understand your journey.",
    animationPath: "assets/animations/onboarding2.json",
  ),
  OnboardingPageModel(
    title: "Achieve More Every Week",
    subtitle: "Unlock achievements and challenges as you improve.",
    animationPath: "assets/animations/onboarding3.json",
  ),
];
