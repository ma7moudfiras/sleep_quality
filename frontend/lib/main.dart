import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/theme/app_theme.dart';
import 'src/features/sleep/presentation/screens/home_shell.dart';

void main() {
  runApp(const ProviderScope(child: SleepEnergyApp()));
}

class SleepEnergyApp extends StatelessWidget {
  const SleepEnergyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sleep Energy',
      theme: AppTheme.light,
      home: const HomeShell(),
    );
  }
}
