import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sleep_providers.dart';
import '../widgets/app_section_card.dart';
import '../widgets/modern_widgets.dart';

class SystemStatusScreen extends ConsumerWidget {
  const SystemStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(systemStatusProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(systemStatusProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const ScreenHeader(
            title: 'System Status',
            subtitle: 'Check backend connectivity, model readiness, and local release paths before packaging.',
            icon: Icons.monitor_heart_outlined,
          ),
          status.when(
            data: (data) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      MetricTile(
                        label: 'API',
                        value: data.apiRunning ? 'Running' : 'Down',
                        icon: Icons.cloud_done_outlined,
                        accentColor: data.apiRunning ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                      MetricTile(
                        label: 'Logs',
                        value: '${data.logsCount}',
                        icon: Icons.list_alt_outlined,
                      ),
                      MetricTile(
                        label: 'Training rows',
                        value: '${data.userTrainingRows}',
                        icon: Icons.model_training_outlined,
                      ),
                      MetricTile(
                        label: 'Model',
                        value: data.modelExists ? 'Ready' : 'Missing',
                        icon: Icons.psychology_outlined,
                        accentColor: data.modelExists ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ],
                  ),
                ),
                AppSectionCard(
                  title: 'Release readiness',
                  subtitle: 'Local paths are shown here to help diagnose EXE packaging issues.',
                  icon: Icons.verified_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoBullet(text: 'Prediction ready: ${data.readyForPrediction ? 'Yes' : 'No'}'),
                      InfoBullet(text: 'Database ready: ${data.databaseExists ? 'Yes' : 'No'}'),
                      InfoBullet(text: 'Latest log: ${data.latestLogId == null ? 'No log yet' : '#${data.latestLogId} · ${data.latestLogDate}'}'),
                      InfoBullet(text: 'Latest prediction: ${data.latestPrediction ?? 'Not available'}'),
                      InfoBullet(text: 'Latest feedback: ${data.latestActualEnergy ?? 'Pending'}'),
                      const SizedBox(height: 10),
                      _PathBlock(label: 'Data directory', value: data.dataDir),
                      const SizedBox(height: 10),
                      _PathBlock(label: 'Runtime base', value: data.runtimeBaseDir),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (error, _) => ModernEmptyState(
              title: 'Backend unavailable',
              subtitle: error.toString(),
              icon: Icons.cloud_off_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathBlock extends StatelessWidget {
  const _PathBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          SelectableText(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
