import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sleep_providers.dart';
import '../widgets/app_section_card.dart';
import '../widgets/modern_widgets.dart';

class PredictionScreen extends ConsumerWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(predictionProvider);
    final retrainState = ref.watch(retrainControllerProvider);

    return prediction.when(
      data: (result) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(predictionProvider),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            const ScreenHeader(
              title: 'Energy Predictor',
              subtitle: 'A confident, explainable prediction based on your latest daily entry.',
              icon: Icons.bolt,
            ),
            AppSectionCard(
              title: 'Next-day energy prediction',
              subtitle: 'Based on your latest sleep log and the current ML model.',
              icon: Icons.auto_awesome,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GradientPanel(
                    colors: [energyColor(result.prediction), const Color(0xFF111827)],
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                          ),
                          child: Icon(energyIcon(result.prediction), color: Colors.white, size: 42),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          result.prediction,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _ConfidenceBar(confidence: result.confidence),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _TipCard(text: result.tip),
                  const SizedBox(height: 20),
                  Text(
                    'Why this prediction?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  if (result.explanation.isEmpty)
                    const InfoBullet(text: 'No explanation factors returned yet.', icon: Icons.info_outline)
                  else
                    ...result.explanation.map((reason) => InfoBullet(text: reason)),
                  const SizedBox(height: 16),
                  Text(
                    'Model: ${result.modelStatus}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: retrainState.isLoading
                        ? null
                        : () => ref.read(retrainControllerProvider.notifier).retrain(),
                    icon: retrainState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.model_training),
                    label: const Text('Retrain model'),
                  ),
                  retrainState.when(
                    data: (retrainResult) => retrainResult == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Retrained with ${retrainResult.totalTrainingRows} rows '
                              '(${retrainResult.userTrainingRows} user feedback rows).',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error.toString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ListView(
        children: [
          const ScreenHeader(
            title: 'Energy Predictor',
            subtitle: 'Add a daily log first, then the model can generate a prediction.',
            icon: Icons.bolt,
          ),
          AppSectionCard(
            title: 'Prediction unavailable',
            subtitle: 'Add at least one sleep log, then retry.',
            icon: Icons.error_outline,
            child: FilledButton.icon(
              onPressed: () => ref.invalidate(predictionProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.confidence});

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).round();
    return Column(
      children: [
        Text(
          'Confidence $percentage%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: confidence.clamp(0.0, 1.0).toDouble(),
            minHeight: 10,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.tips_and_updates, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personalized tip', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
