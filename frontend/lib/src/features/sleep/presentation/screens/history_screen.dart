import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/sleep_log.dart';
import '../providers/sleep_providers.dart';
import '../widgets/app_section_card.dart';
import '../widgets/modern_widgets.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(logsProvider),
      child: logs.when(
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyHistory();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ScreenHeader(
                  title: 'Sleep History',
                  subtitle: '${items.length} daily entries available for feedback, trends, and retraining.',
                  icon: Icons.history,
                );
              }
              final item = items[index - 1];
              return _HistoryLogCard(log: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          children: [
            AppSectionCard(
              title: 'Could not load history',
              subtitle: error.toString(),
              icon: Icons.error_outline,
              child: FilledButton(
                onPressed: () => ref.invalidate(logsProvider),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryLogCard extends StatelessWidget {
  const _HistoryLogCard({required this.log});

  final SleepLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: theme.colorScheme.primary.withValues(alpha: 0.09),
                  ),
                  child: Icon(Icons.nights_stay, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.logDate,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bed ${_formatHour(log.bedtimeHour)} • Wake ${_formatHour(log.wakeHour)}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                EnergyBadge(label: log.predictedEnergyLevel ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MiniStat(label: 'Sleep', value: '${log.sleepHours.toStringAsFixed(1)}h', icon: Icons.bedtime),
                _MiniStat(label: 'Mood', value: '${log.mood}/5', icon: Icons.mood),
                _MiniStat(label: 'Activity', value: '${log.activityLevel}/5', icon: Icons.directions_walk),
                _MiniStat(label: 'Actual', value: log.actualEnergyLevel ?? 'Pending', icon: Icons.fact_check),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Actual energy feedback',
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            _FeedbackButtons(log: log),
          ],
        ),
      ),
    );
  }

  String _formatHour(double hour) {
    final h = hour.floor().clamp(0, 23).toInt();
    final m = ((hour - h) * 60).round().clamp(0, 59).toInt();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text('$label: ', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _FeedbackButtons extends ConsumerWidget {
  const _FeedbackButtons({required this.log});

  final SleepLog log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackState = ref.watch(feedbackControllerProvider);
    final isSaving = feedbackState.isLoading;
    const levels = ['Low', 'Medium', 'High'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: levels.map((level) {
            final selected = log.actualEnergyLevel == level;
            return ChoiceChip(
              avatar: Icon(energyIcon(level), size: 16, color: energyColor(level)),
              label: Text(level),
              selected: selected,
              onSelected: isSaving ? null : (_) => _saveFeedback(context, ref, level),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          log.actualEnergyLevel == null
              ? 'Choose the real next-day energy. The model will retrain automatically.'
              : 'Saved actual energy: ${log.actualEnergyLevel}. You can update it anytime.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
        if (isSaving) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Future<void> _saveFeedback(BuildContext context, WidgetRef ref, String level) async {
    try {
      final result = await ref.read(feedbackControllerProvider.notifier).saveFeedback(
            logId: log.id,
            actualEnergyLevel: level,
            autoRetrain: true,
          );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.retrained
                ? 'Feedback saved. Model retrained with ${result.retrainResult?.userTrainingRows ?? 0} user rows.'
                : 'Feedback saved.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ScreenHeader(
          title: 'Sleep History',
          subtitle: 'Your saved daily logs will appear here after the first entry.',
          icon: Icons.history,
        ),
        ModernEmptyState(
          title: 'No logs yet',
          subtitle: 'Add your first sleep log to start tracking sleep quality and model feedback.',
          icon: Icons.history,
        ),
      ],
    );
  }
}
