import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'charts_screen.dart';
import 'history_screen.dart';
import 'insights_screen.dart';
import 'log_screen.dart';
import 'prediction_screen.dart';
import 'system_status_screen.dart';
import 'what_if_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    LogScreen(),
    HistoryScreen(),
    InsightsScreen(),
    ChartsScreen(),
    PredictionScreen(),
    WhatIfScreen(),
    SystemStatusScreen(),
    AboutScreen(),
  ];

  final _destinations = const [
    NavigationDestination(icon: Icon(Icons.bedtime_outlined), selectedIcon: Icon(Icons.bedtime), label: 'Log'),
    NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
    NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insights'),
    NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: 'Charts'),
    NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: 'Predict'),
    NavigationDestination(icon: Icon(Icons.science_outlined), selectedIcon: Icon(Icons.science), label: 'What-if'),
    NavigationDestination(icon: Icon(Icons.monitor_heart_outlined), selectedIcon: Icon(Icons.monitor_heart), label: 'Status'),
    NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC), Color(0xFFF6F8FC)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 860;
              if (wide) {
                return Row(
                  children: [
                    _SideRail(
                      selectedIndex: _index,
                      onSelected: (value) => setState(() => _index = value),
                    ),
                    Expanded(child: _PageHost(child: _screens[_index])),
                  ],
                );
              }

              return _PageHost(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 86),
                  child: _screens[_index],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 860) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (value) => setState(() => _index = value),
                destinations: _destinations,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PageHost extends StatelessWidget {
  const _PageHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: child,
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        labelType: NavigationRailLabelType.all,
        leading: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
              ),
            ),
            child: const Icon(Icons.nightlight_round, color: Colors.white),
          ),
        ),
        destinations: const [
          NavigationRailDestination(icon: Icon(Icons.bedtime_outlined), selectedIcon: Icon(Icons.bedtime), label: Text('Log')),
          NavigationRailDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: Text('History')),
          NavigationRailDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: Text('Insights')),
          NavigationRailDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: Text('Charts')),
          NavigationRailDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: Text('Predict')),
          NavigationRailDestination(icon: Icon(Icons.science_outlined), selectedIcon: Icon(Icons.science), label: Text('What-if')),
          NavigationRailDestination(icon: Icon(Icons.monitor_heart_outlined), selectedIcon: Icon(Icons.monitor_heart), label: Text('Status')),
          NavigationRailDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: Text('About')),
        ],
      ),
    );
  }
}
