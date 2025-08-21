// studio_onboarding_page.dart
import 'package:flutter/material.dart';

class StudioOnboardingPage extends StatelessWidget {
  const StudioOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stüdyo Onboarding")),
      body: const Center(child: Text("Studio Profile Onboarding Page")),
    );
  }
}
