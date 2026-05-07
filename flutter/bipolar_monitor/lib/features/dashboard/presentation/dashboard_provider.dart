import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class DashboardData {
  final double? todayComposite;
  final double? todayDeviation;
  final List<Map<String, dynamic>> trend14d;
  final List<Map<String, dynamic>> recentMeasurements;

  const DashboardData({
    this.todayComposite,
    this.todayDeviation,
    this.trend14d = const [],
    this.recentMeasurements = const [],
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final api = ref.read(apiClientProvider);
  final resp = await api.get('/measurements/?limit=14');
  final measurements = (resp['items'] as List?) ?? [];

  final recent = measurements.take(5).toList();
  final trend = measurements.reversed
      .map((m) => <String, dynamic>{
            'date': m['recorded_at'],
            'composite': m['composite_zscore'],
          })
      .where((m) => m['composite'] != null)
      .toList();

  final today = measurements.isNotEmpty ? measurements.first : null;

  return DashboardData(
    todayComposite: today?['composite_zscore'] as double?,
    todayDeviation: today != null
        ? (today['composite_zscore'] as double?) != null &&
                (today['baseline_std'] as double?) != null &&
                (today['baseline_std'] as double) > 0
            ? ((today['composite_zscore'] as double) -
                    (today['baseline_mean'] as double? ?? 0)) /
                (today['baseline_std'] as double)
            : null
        : null,
    trend14d: trend.cast<Map<String, dynamic>>(),
    recentMeasurements: recent.cast<Map<String, dynamic>>(),
  );
});
