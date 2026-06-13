import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sleep_providers.dart';
import '../widgets/app_section_card.dart';
import '../widgets/modern_widgets.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);
    final weekly = ref.watch(weeklyReportProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(insightsProvider);
        ref.invalidate(weeklyReportProvider);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const ScreenHeader(
            title: 'Smart Insights',
            subtitle: 'Consistency, sleep debt, streaks, and model personalization in one clean view.',
            icon: Icons.insights,
          ),
          insights.when(
            data: (data) => AppSectionCard(
              title: 'Personal analytics',
              subtitle: 'Current behavior signals extracted from your logs.',
              icon: Icons.psychology,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      MetricTile(
                        label: 'Consistency',
                        value: '${data.sleepConsistencyScore}%',
                        icon: Icons.timeline,
                        accentColor: const Color(0xFF4F46E5),
                      ),
                      MetricTile(
                        label: 'Sleep debt',
                        value: '${data.sleepDebtThisWeek.toStringAsFixed(1)}h',
                        icon: Icons.hourglass_bottom,
                        accentColor: const Color(0xFFF59E0B),
                      ),
                      MetricTile(
                        label: 'Streak',
                        value: '${data.streakDays} days',
                        icon: Icons.local_fire_department,
                        accentColor: const Color(0xFFEF4444),
                      ),
                      MetricTile(
                        label: 'Personalization',
                        value: data.personalizationLevel,
                        icon: Icons.auto_awesome,
                        accentColor: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _RecommendationPanel(text: data.recommendation),
                  const SizedBox(height: 22),
                  _SectionLabel(title: 'Data quality', icon: Icons.verified_outlined),
                  const SizedBox(height: 8),
                  if (data.dataQualityWarnings.isEmpty)
                    const InfoBullet(text: 'No data quality warnings. Your logs look clean.')
                  else
                    ...data.dataQualityWarnings.map(
                      (warning) => InfoBullet(text: warning, icon: Icons.info_outline),
                    ),
                  const SizedBox(height: 18),
                  _SectionLabel(title: 'Latest prediction factors', icon: Icons.manage_search),
                  const SizedBox(height: 8),
                  if (data.latestExplanation.isEmpty)
                    const InfoBullet(text: 'Add a log to generate explanation factors.', icon: Icons.add_circle_outline)
                  else
                    ...data.latestExplanation.map((reason) => InfoBullet(text: reason)),
                  const SizedBox(height: 14),
                  Text(
                    'Model: ${data.modelStatus}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            loading: () => const AppSectionCard(
              title: 'Personal analytics',
              icon: Icons.psychology,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => AppSectionCard(
              title: 'Could not load insights',
              subtitle: error.toString(),
              icon: Icons.error_outline,
              child: FilledButton(
                onPressed: () => ref.invalidate(insightsProvider),
                child: const Text('Retry'),
              ),
            ),
          ),
          weekly.when(
            data: (report) => AppSectionCard(
              title: 'Weekly Report',
              subtitle: 'A compact summary of your latest 7-day window.',
              icon: Icons.calendar_month,
              accentColor: const Color(0xFF06B6D4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      MetricTile(label: 'Days logged', value: report.daysCount.toString(), icon: Icons.calendar_month),
                      MetricTile(label: 'Avg sleep', value: '${report.averageSleep.toStringAsFixed(1)}h', icon: Icons.nightlight),
                      MetricTile(label: 'Avg mood', value: report.averageMood.toStringAsFixed(1), icon: Icons.mood),
                      MetricTile(label: 'Avg activity', value: report.averageActivity.toStringAsFixed(1), icon: Icons.directions_walk),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SmallFact(label: 'Most common energy', value: report.mostCommonEnergy ?? 'N/A'),
                  _SmallFact(label: 'Best sleep day', value: report.bestSleepDay ?? 'N/A'),
                  _SmallFact(label: 'Worst sleep day', value: report.worstSleepDay ?? 'N/A'),
                  _SmallFact(label: 'Weekly sleep debt', value: '${report.sleepDebt.toStringAsFixed(1)}h'),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _RecommendationPanel extends StatelessWidget {
  const _RecommendationPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GradientPanel(
      colors: const [Color(0xFF0F172A), Color(0xFF4F46E5)],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tips_and_updates, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _SmallFact extends StatelessWidget {
  const _SmallFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
