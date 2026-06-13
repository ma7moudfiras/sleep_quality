import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/sleep_log.dart';
import '../providers/sleep_providers.dart';
import '../widgets/app_section_card.dart';
import '../widgets/modern_widgets.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sleepHoursController = TextEditingController(text: '7.5');
  DateTime _date = DateTime.now();
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  double _mood = 3;
  double _activity = 3;

  @override
  void dispose() {
    _sleepHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(logSubmitControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sleep log saved. Your insights are refreshed.')),
            );
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    final submitState = ref.watch(logSubmitControllerProvider);
    final warnings = _dataWarnings();

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        const ScreenHeader(
          title: 'Daily Sleep Log',
          subtitle: 'Capture tonight\'s sleep, mood, and activity to personalize tomorrow\'s prediction.',
          icon: Icons.bedtime,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MetricTile(
                label: 'Sleep target',
                value: '${_sleepHoursController.text}h',
                icon: Icons.nights_stay,
                accentColor: const Color(0xFF4F46E5),
              ),
              MetricTile(
                label: 'Mood input',
                value: '${_mood.round()}/5',
                icon: Icons.mood,
                accentColor: const Color(0xFF06B6D4),
              ),
              MetricTile(
                label: 'Activity input',
                value: '${_activity.round()}/5',
                icon: Icons.directions_walk,
                accentColor: const Color(0xFF10B981),
              ),
            ],
          ),
        ),
        AppSectionCard(
          title: 'Today\'s entry',
          subtitle: 'One clear daily entry keeps the ML data clean and easy to retrain.',
          icon: Icons.edit_calendar,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActionTileButton(
                  icon: Icons.calendar_today,
                  label: 'Log date',
                  value: DateFormat('yyyy-MM-dd').format(_date),
                  onPressed: _pickDate,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _sleepHoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Sleep hours',
                    prefixIcon: Icon(Icons.nights_stay),
                    helperText: 'Example: 7.5 means seven and a half hours.',
                  ),
                  onChanged: (_) => setState(() {}),
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
                      child: _ActionTileButton(
                        icon: Icons.bed,
                        label: 'Bedtime',
                        value: _bedtime.format(context),
                        onPressed: () => _pickTime(isBedtime: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionTileButton(
                        icon: Icons.wb_sunny,
                        label: 'Wake time',
                        value: _wakeTime.format(context),
                        onPressed: () => _pickTime(isBedtime: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SliderField(
                  label: 'Mood',
                  icon: Icons.mood,
                  value: _mood,
                  lowLabel: 'Low',
                  highLabel: 'Great',
                  onChanged: (value) => setState(() => _mood = value),
                ),
                _SliderField(
                  label: 'Activity level',
                  icon: Icons.directions_walk,
                  value: _activity,
                  lowLabel: 'Light',
                  highLabel: 'Active',
                  onChanged: (value) => setState(() => _activity = value),
                ),
                if (warnings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _WarningPanel(warnings: warnings),
                ],
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: submitState is AsyncLoading ? null : _submit,
                  icon: submitState is AsyncLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: const Text('Save sleep log'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
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

  List<String> _dataWarnings() {
    final sleep = double.tryParse(_sleepHoursController.text);
    final warnings = <String>[];
    if (sleep != null && sleep < 4.5) {
      warnings.add('Sleep duration is very low; confirm the value before saving.');
    }
    if (sleep != null && sleep > 10.5) {
      warnings.add('Sleep duration is unusually high; confirm the value before saving.');
    }
    final bedtime = _toHour(_bedtime);
    if (bedtime >= 1 && bedtime <= 5) {
      warnings.add('Bedtime is very late; wake time will be treated as next-day wake-up.');
    }
    return warnings;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final input = SleepLogInput(
      logDate: DateFormat('yyyy-MM-dd').format(_date),
      sleepHours: double.parse(_sleepHoursController.text),
      bedtimeHour: _toHour(_bedtime),
      wakeHour: _toHour(_wakeTime),
      mood: _mood.round(),
      activityLevel: _activity.round(),
    );

    ref.read(logSubmitControllerProvider.notifier).submit(input);
  }

  double _toHour(TimeOfDay time) => time.hour + (time.minute / 60.0);
}

class _WarningPanel extends StatelessWidget {
  const _WarningPanel({required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text('Data quality notice', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          for (final warning in warnings) InfoBullet(text: warning, icon: Icons.info_outline),
        ],
      ),
    );
  }
}

class _ActionTileButton extends StatelessWidget {
  const _ActionTileButton({
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
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.icon,
    required this.value,
    required this.lowLabel,
    required this.highLabel,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final double value;
  final String lowLabel;
  final String highLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lowLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
              Text(highLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}
