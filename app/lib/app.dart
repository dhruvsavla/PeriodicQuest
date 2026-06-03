import 'package:flutter/material.dart';

import 'features/landing/presentation/landing_screen.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const LandingPage();
  }
}

class PeriodicQuestApp extends StatelessWidget {
  const PeriodicQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEntry();
  }
}
