import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/crisis_button.dart';
import '../../auth/presentation/auth_provider.dart';
import 'dashboard_provider.dart';
import 'score_ring_widget.dart';
import 'trend_chart_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final dashData = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.background,
                  expandedHeight: 110,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: AppTypography.bodySm,
                        ),
                        Text(
                          user?.displayName ?? '',
                          style: AppTypography.headingMd,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
                        onPressed: () => context.push('/settings'),
                      ),
                    ),
                  ],
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Score ring — today's composite
                      dashData.when(
                        loading: () => const _LoadingCard(),
                        error: (_, __) => const _EmptyCard(),
                        data: (data) => ScoreRingWidget(
                          score: data.todayComposite,
                          deviation: data.todayDeviation,
                          label: 'Dnešní stav',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Trend chart
                      dashData.when(
                        loading: () => const _LoadingCard(height: 160),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (data) => data.trend14d.isEmpty
                            ? const SizedBox.shrink()
                            : TrendChartWidget(points: data.trend14d),
                      ),
                      const SizedBox(height: 24),

                      // Record CTA
                      _RecordButton(onTap: () => context.push('/record')),
                      const SizedBox(height: 24),

                      // Recent measurements
                      Text('Poslední záznamy', style: AppTypography.label),
                      const SizedBox(height: 12),
                      dashData.when(
                        loading: () => const _LoadingCard(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (data) => Column(
                          children: data.recentMeasurements.map((m) => _RecentCard(m)).toList(),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),

            // Crisis button — always visible
            const Positioned(top: 8, right: 16, child: CrisisButton()),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Dobré ráno';
    if (h < 18) return 'Dobrý den';
    return 'Dobrý večer';
  }
}

class _RecordButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RecordButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_none_rounded, color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Začít nahrávání', style: AppTypography.bodyPrimary.copyWith(fontWeight: FontWeight.w600)),
                  Text('Dialog s 5 otázkami', style: AppTypography.bodySm),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({this.height = 120});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Text('Žádná data ještě. Nahraj první záznam.', style: AppTypography.body),
      );
}

class _RecentCard extends StatelessWidget {
  final dynamic measurement;
  const _RecentCard(this.measurement);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(child: Text(measurement.toString(), style: AppTypography.bodySm)),
        ]),
      );
}
