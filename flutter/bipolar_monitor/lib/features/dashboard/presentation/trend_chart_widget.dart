import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class TrendChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> points; // [{date, composite}, ...]

  const TrendChartWidget({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final spots = points.asMap().entries
        .where((e) => e.value['composite'] != null)
        .map((e) => FlSpot(e.key.toDouble(), (e.value['composite'] as double).clamp(-3.0, 3.0)))
        .toList();

    if (spots.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('14 dní', style: AppTypography.label),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: -3,
                maxY: 3,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 0.5),
                ),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.accent,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.accent,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.accent.withOpacity(0.08),
                    ),
                  ),
                ],
                // Zero line
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(y: 0, color: AppColors.divider, strokeWidth: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
