import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/sleep_log.dart';
import '../providers/sleep_providers.dart';
import '../widgets/app_section_card.dart';
import '../widgets/modern_widgets.dart';

class WhatIfScreen extends ConsumerStatefulWidget {
  const WhatIfScreen({super.key});

  @override
  ConsumerState<WhatIfScreen> createState() => _WhatIfScreenState();
}

class _WhatIfScreenState extends ConsumerState<WhatIfScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sleepHoursController = TextEditingController(text: '8');
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  double _mood = 4;
  double _activity = 3;

  @override
  void dispose() {
    _sleepHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whatIfControllerProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const ScreenHeader(
          title: 'What-if Simulator',
          subtitle: 'Simulate better sleep, earlier bedtime, or higher activity before changing habits.',
          icon: Icons.science,
        ),
        AppSectionCard(
          title: 'Scenario builder',
          subtitle: 'Adjust values and let the model estimate the likely energy outcome.',
          icon: Icons.tune,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _sleepHoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Scenario sleep hours',
                    prefixIcon: Icon(Icons.nights_stay),
                  ),
                  validator: (value) {
                    final number = double.tryParse(value ?? '');
                    if (number == null || number <= 0 || number > 24) {
                      return 'Enter a value between 0 and 24.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _TimeScenarioButton(
                        icon: Icons.bed,
                        label: 'Bed',
                        value: _bedtime.format(context),
                        onPressed: () => _pickTime(isBedtime: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeScenarioButton(
                        icon: Icons.wb_sunny,
                        label: 'Wake',
                        value: _wakeTime.format(context),
                        onPressed: () => _pickTime(isBedtime: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SliderField(
                  label: 'Mood',
                  value: _mood,
                  icon: Icons.mood,
                  onChanged: (value) => setState(() => _mood = value),
                ),
                _SliderField(
                  label: 'Activity level',
                  value: _activity,
                  icon: Icons.directions_walk,
                  onChanged: (value) => setState(() => _activity = value),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: state.isLoading ? null : _runScenario,
                  icon: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.science),
                  label: const Text('Run scenario'),
                ),
              ],
            ),
          ),
        ),
        state.when(
          data: (result) => result == null
              ? const SizedBox.shrink()
              : AppSectionCard(
                  title: 'Scenario Result',
                  subtitle: result.baseline == null
                      ? 'No baseline log found yet.'
                      : 'Baseline: ${result.baseline!.prediction} (${(result.baseline!.confidence * 100).round()}%).',
                  icon: Icons.bolt,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GradientPanel(
                        colors: [energyColor(result.scenarioPrediction), const Color(0xFF111827)],
                        child: Column(
                          children: [
                            EnergyBadge(label: result.scenarioPrediction),
                            const SizedBox(height: 14),
                            Text(
                              result.scenarioPrediction,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Confidence: ${(result.scenarioConfidence * 100).round()}%',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _ResultSection(title: 'Tip', icon: Icons.tips_and_updates, text: result.tip),
                      const SizedBox(height: 18),
                      Text(
                        'Why?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      ...result.explanation.map((reason) => InfoBullet(text: reason)),
                    ],
                  ),
                ),
          loading: () => const SizedBox.shrink(),
          error: (error, _) => AppSectionCard(
            title: 'Scenario failed',
            subtitle: error.toString(),
            icon: Icons.error_outline,
            child: FilledButton(
              onPressed: _runScenario,
              child: const Text('Retry'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime({required bool isBedtime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeTime,
    );

    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  void _runScenario() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final input = WhatIfInput(
      sleepHours: double.parse(_sleepHoursController.text),
      bedtimeHour: _toHour(_bedtime),
      wakeHour: _toHour(_wakeTime),
      mood: _mood.round(),
      activityLevel: _activity.round(),
    );

    ref.read(whatIfControllerProvider.notifier).run(input);
  }

  double _toHour(TimeOfDay time) => time.hour + (time.minute / 60.0);
}

class _TimeScenarioButton extends StatelessWidget {
  const _TimeScenarioButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final double value;
  final IconData icon;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900))),
              Text('${value.round()}/5', style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.title, required this.icon, required this.text});

  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
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
