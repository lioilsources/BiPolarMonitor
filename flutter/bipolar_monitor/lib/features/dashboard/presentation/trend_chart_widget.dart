import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'dashboard_provider.dart';

class TrendChartWidget extends ConsumerWidget {
  final List<Map<String, dynamic>> points;

  const TrendChartWidget({super.key, required this.points});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(trendPeriodProvider);

    final spots = points.asMap().entries
        .where((e) => e.value['composite'] != null)
        .map((e) => FlSpot(e.key.toDouble(), (e.value['composite'] as double).clamp(-3.0, 3.0)))
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Trend', style: AppTypography.label)),
              _PeriodSelector(selected: period, onChanged: (p) {
                ref.read(trendPeriodProvider.notifier).state = p;
              }),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: spots.isEmpty
                ? Center(child: Text('Zatím žádná data', style: AppTypography.bodySm))
                : LineChart(_buildChartData(spots, points)),
          ),
          if (points.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAxisLabels(points),
          ],
        ],
      ),
    );
  }

  LineChartData _buildChartData(List<FlSpot> spots, List<Map<String, dynamic>> points) {
    return LineChartData(
      minY: -3,
      maxY: 3,
      clipData: FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (v) => FlLine(
          color: v == 0 ? AppColors.textSecondary.withOpacity(0.3) : AppColors.divider,
          strokeWidth: v == 0 ? 1.0 : 0.5,
          dashArray: v == 0 ? null : [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.accent,
          barWidth: 2,
          dotData: FlDotData(
            show: spots.length <= 14,
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
              radius: 2.5,
              color: _colorForValue(spot.y),
              strokeWidth: 0,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.accent.withOpacity(0.12),
                AppColors.accent.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
      // 2.5σ threshold lines
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(y: 2.5, color: AppColors.accentWarm.withOpacity(0.4), strokeWidth: 1, dashArray: [6, 4]),
          HorizontalLine(y: -2.5, color: AppColors.textSecondary.withOpacity(0.3), strokeWidth: 1, dashArray: [6, 4]),
        ],
      ),
    );
  }

  Color _colorForValue(double v) {
    if (v > 2.0) return AppColors.accentWarm;
    if (v < -2.0) return AppColors.textSecondary;
    return AppColors.accent;
  }

  Widget _buildAxisLabels(List<Map<String, dynamic>> points) {
    if (points.length < 2) return const SizedBox.shrink();
    final first = points.first['date'] as String?;
    final last = points.last['date'] as String?;
    String fmt(String? s) {
      if (s == null) return '';
      final dt = DateTime.tryParse(s);
      if (dt == null) return '';
      return DateFormat('d.M.', 'cs').format(dt.toLocal());
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(fmt(first), style: AppTypography.label.copyWith(fontSize: 10)),
        Text(fmt(last), style: AppTypography.label.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final TrendPeriod selected;
  final ValueChanged<TrendPeriod> onChanged;

  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: TrendPeriod.values.map((p) {
        final isSelected = p == selected;
        return GestureDetector(
          onTap: () => onChanged(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.divider,
                width: 1,
              ),
            ),
            child: Text(
              p.label,
              style: AppTypography.label.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
