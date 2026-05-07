import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'history_provider.dart';
import 'measurement_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Historie', style: AppTypography.headingMd),
        titleSpacing: 20,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: notifier.refresh,
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nepodařilo se načíst záznamy.', style: AppTypography.body),
              const SizedBox(height: 16),
              TextButton(
                onPressed: notifier.refresh,
                child: Text('Zkusit znovu', style: AppTypography.bodySm.copyWith(color: AppColors.accent)),
              ),
            ],
          ),
        ),
        data: (measurements) => measurements.isEmpty
            ? _EmptyState()
            : NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollEndNotification && n.metrics.extentAfter < 200 && notifier.hasMore) {
                    notifier.load();
                  }
                  return false;
                },
                child: RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  onRefresh: notifier.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    itemCount: measurements.length + (notifier.hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == measurements.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)),
                        );
                      }
                      final m = measurements[i];
                      return MeasurementCard(
                        measurement: m,
                        onTap: () => context.push('/measurement/${m.id}'),
                        onDelete: () => notifier.delete(m.id),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text('Zatím žádné záznamy.', style: AppTypography.headingMd),
            const SizedBox(height: 8),
            Text('Nahraj první dialog a začni sledovat svůj trend.', style: AppTypography.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
