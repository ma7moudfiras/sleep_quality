import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/sleep_log.dart';
import '../providers/sleep_providers.dart';
import '../widgets/app_section_card.dart';
import '../widgets/modern_widgets.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charts = ref.watch(chartsProvider);

    return charts.when(
      data: (data) {
        if (data.sleepTrend.isEmpty) {
          return ListView(
            children: const [
              ScreenHeader(
                title: 'Trend Charts',
                subtitle: 'Visual sleep and energy patterns will appear after your first logs.',
                icon: Icons.show_chart,
              ),
              ModernEmptyState(
                title: 'No chart data',
                subtitle: 'Add logs to show sleep, mood, activity, and energy trends.',
                icon: Icons.auto_graph,
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(chartsProvider),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              const ScreenHeader(
                title: 'Trend Charts',
                subtitle: 'Read the trend line, then adjust sleep consistency and feedback quality.',
                icon: Icons.show_chart,
              ),
              AppSectionCard(
                title: 'Sleep trend',
                subtitle: 'Daily sleep hours across your recent logs.',
                icon: Icons.nights_stay,
                accentColor: const Color(0xFF4F46E5),
                child: _LineChart(points: data.sleepTrend, maxY: 12, color: const Color(0xFF4F46E5)),
              ),
              AppSectionCard(
                title: 'Energy trend',
                subtitle: 'Low = 1, Medium = 2, High = 3.',
                icon: Icons.bolt,
                accentColor: const Color(0xFFF59E0B),
                child: _LineChart(points: data.energyTrend, maxY: 3, color: const Color(0xFFF59E0B)),
              ),
              AppSectionCard(
                title: 'Mood trend',
                subtitle: 'Daily mood score from 1 to 5.',
                icon: Icons.mood,
                accentColor: const Color(0xFF06B6D4),
                child: _LineChart(points: data.moodTrend, maxY: 5, color: const Color(0xFF06B6D4)),
              ),
              AppSectionCard(
                title: 'Activity trend',
                subtitle: 'Daily activity score from 1 to 5.',
                icon: Icons.directions_walk,
                accentColor: const Color(0xFF10B981),
                child: _LineChart(points: data.activityTrend, maxY: 5, color: const Color(0xFF10B981)),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ListView(
        children: [
          AppSectionCard(
            title: 'Could not load charts',
            subtitle: error.toString(),
            icon: Icons.error_outline,
            child: FilledButton(
              onPressed: () => ref.invalidate(chartsProvider),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.points, required this.maxY, required this.color});

  final List<ChartPointModel> points;
  final double maxY;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value),
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(6, 16, 14, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: points.length <= 1 ? 0.0 : (points.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.black.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      points[index].date.substring(5),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (items) => items
                  .map((item) => LineTooltipItem(
                        item.y.toStringAsFixed(1),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              barWidth: 4,
              color: color,
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.12)),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 3,
                  strokeColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
