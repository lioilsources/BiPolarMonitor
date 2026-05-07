import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

enum TrendPeriod { week, month, quarter }

extension TrendPeriodExt on TrendPeriod {
  int get days => switch (this) {
        TrendPeriod.week => 7,
        TrendPeriod.month => 30,
        TrendPeriod.quarter => 90,
      };
  String get label => switch (this) {
        TrendPeriod.week => '7d',
        TrendPeriod.month => '30d',
        TrendPeriod.quarter => '90d',
      };
}

final trendPeriodProvider = StateProvider<TrendPeriod>((ref) => TrendPeriod.week);

class DashboardData {
  final double? todayComposite;
  final double? todayDeviation;
  final List<Map<String, dynamic>> trendPoints;
  final List<Map<String, dynamic>> recentMeasurements;
  final int streak;
  final int? daysSinceLast;
  final double? periodAvgComposite;

  const DashboardData({
    this.todayComposite,
    this.todayDeviation,
    this.trendPoints = const [],
    this.recentMeasurements = const [],
    this.streak = 0,
    this.daysSinceLast,
    this.periodAvgComposite,
  });
}

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final api = ref.read(apiClientProvider);
  final period = ref.watch(trendPeriodProvider);

  final resp = await api.get('/measurements/?limit=${period.days}');
  final measurements = (resp['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

  final recent = measurements.take(5).toList();

  // Trend points — oldest first for chart
  final trendPoints = measurements.reversed
      .map((m) => <String, dynamic>{
            'date': m['recorded_at'],
            'composite': (m['composite_zscore'] as num?)?.toDouble(),
          })
      .where((m) => m['composite'] != null)
      .toList()
      .cast<Map<String, dynamic>>();

  // Streak — count consecutive days from today backwards
  final streak = _computeStreak(measurements);

  // Days since last recording
  int? daysSinceLast;
  if (measurements.isNotEmpty) {
    final lastRaw = measurements.first['recorded_at'] as String?;
    if (lastRaw != null) {
      final last = DateTime.tryParse(lastRaw);
      if (last != null) {
        daysSinceLast = DateTime.now().toUtc().difference(last.toUtc()).inDays;
      }
    }
  }

  // Period average composite
  final validComposites = trendPoints
      .map((p) => p['composite'] as double?)
      .whereType<double>()
      .toList();
  final periodAvg = validComposites.isNotEmpty
      ? validComposites.reduce((a, b) => a + b) / validComposites.length
      : null;

  final today = measurements.isNotEmpty ? measurements.first : null;
  final baselineStd = (today?['baseline_std'] as num?)?.toDouble();
  final baselineMean = (today?['baseline_mean'] as num?)?.toDouble();
  final todayComposite = (today?['composite_zscore'] as num?)?.toDouble();

  return DashboardData(
    todayComposite: todayComposite,
    todayDeviation: todayComposite != null && baselineStd != null && baselineStd > 0 && baselineMean != null
        ? (todayComposite - baselineMean) / baselineStd
        : null,
    trendPoints: trendPoints,
    recentMeasurements: recent,
    streak: streak,
    daysSinceLast: daysSinceLast,
    periodAvgComposite: periodAvg,
  );
});

int _computeStreak(List<Map<String, dynamic>> measurements) {
  if (measurements.isEmpty) return 0;

  final today = DateTime.now().toUtc();
  int streak = 0;
  DateTime cursor = DateTime(today.year, today.month, today.day);

  for (final m in measurements) {
    final raw = m['recorded_at'] as String?;
    if (raw == null) continue;
    final dt = DateTime.tryParse(raw)?.toUtc();
    if (dt == null) continue;
    final day = DateTime(dt.year, dt.month, dt.day);

    if (day == cursor || day == cursor.subtract(const Duration(days: 1))) {
      streak++;
      cursor = day;
    } else {
      break;
    }
  }
  return streak;
}
