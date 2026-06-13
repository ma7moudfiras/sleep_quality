import 'package:flutter/material.dart';

import '../widgets/app_section_card.dart';
import '../widgets/modern_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ScreenHeader(
          title: 'About Project',
          subtitle: 'A release-candidate overview of the app, stack, and main intelligent features.',
          icon: Icons.info_outline,
        ),
        AppSectionCard(
          title: 'Sleep Quality Analyzer and Daily Energy Predictor',
          subtitle: 'A practical ML-backed app for logging sleep patterns and predicting next-day energy.',
          icon: Icons.nightlight_round,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoBullet(text: 'Frontend: Flutter Web + Android with Riverpod, Dio, and fl_chart.'),
              InfoBullet(text: 'Backend: Python FastAPI with SQLite persistence.'),
              InfoBullet(text: 'ML: Random Forest classifier trained from seed data and user feedback.'),
              InfoBullet(text: 'Main loop: Log → Predict → Feedback → Retrain → Insights → What-if.'),
              InfoBullet(text: 'Release Candidate: prepared for local EXE packaging with stable data paths.'),
            ],
          ),
        ),
        AppSectionCard(
          title: 'User features',
          icon: Icons.auto_awesome_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoBullet(text: 'Daily sleep and lifestyle logging.'),
              InfoBullet(text: 'Prediction confidence and explainable prediction reasons.'),
              InfoBullet(text: 'Feedback buttons for Low / Medium / High actual energy.'),
              InfoBullet(text: 'Smart insights: consistency, sleep debt, streak, and recommendations.'),
              InfoBullet(text: 'What-if simulator for comparing possible sleep scenarios.'),
            ],
          ),
        ),
      ],
    );
  }
}
