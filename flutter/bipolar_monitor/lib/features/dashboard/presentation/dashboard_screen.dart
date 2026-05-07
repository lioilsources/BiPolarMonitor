import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.background,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(), style: AppTypography.bodySm),
                        Text(user?.displayName ?? '', style: AppTypography.headingMd),
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // Deviation alert banner (>2.5σ)
                      dashAsync.whenOrNull(
                        data: (data) => data.todayDeviation != null && data.todayDeviation!.abs() > 2.5
                            ? _DeviationBanner(deviation: data.todayDeviation!)
                            : null,
                      ) ?? const SizedBox.shrink(),

                      // Recording nudge (>3 days since last)
                      dashAsync.whenOrNull(
                        data: (data) => (data.daysSinceLast ?? 0) > 3
                            ? _RecordingNudge(days: data.daysSinceLast!)
                            : null,
                      ) ?? const SizedBox.shrink(),

                      // Stats row — streak + period avg
                      dashAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (data) => _StatsRow(data: data),
                      ),
                      const SizedBox(height: 16),

                      // Score ring
                      dashAsync.when(
                        loading: () => const _LoadingCard(),
                        error: (_, __) => const _EmptyCard(),
                        data: (data) => ScoreRingWidget(
                          score: data.todayComposite,
                          deviation: data.todayDeviation,
                          label: 'Poslední záznam',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Trend chart
                      dashAsync.when(
                        loading: () => const _LoadingCard(height: 190),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (data) => TrendChartWidget(points: data.trendPoints),
                      ),
                      const SizedBox(height: 24),

                      // Record CTA
                      _RecordButton(onTap: () => context.push('/record')),
                      const SizedBox(height: 24),

                      // Recent measurements
                      Text('Poslední záznamy', style: AppTypography.label),
                      const SizedBox(height: 12),
                      dashAsync.when(
                        loading: () => const _LoadingCard(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (data) => data.recentMeasurements.isEmpty
                            ? const _EmptyCard()
                            : Column(
                                children: data.recentMeasurements
                                    .map((m) => _RecentCard(m, onTap: () {
                                          context.push('/measurement/${m['id']}');
                                        }))
                                    .toList(),
                              ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),

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

// ─── Deviation alert banner ───────────────────────────────────────────────────

class _DeviationBanner extends StatelessWidget {
  final double deviation;
  const _DeviationBanner({required this.deviation});

  @override
  Widget build(BuildContext context) {
    final isHigh = deviation > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (isHigh ? AppColors.accentWarm : AppColors.textSecondary).withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isHigh ? AppColors.accentWarm : AppColors.textSecondary).withOpacity(0.3),
        ),
      ),
      child: Row(children: [
        Icon(
          isHigh ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: isHigh ? AppColors.accentWarm : AppColors.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isHigh
                ? 'Tvůj dnešní záznam se výrazně liší od tvého průměru (${deviation.toStringAsFixed(1)}σ).'
                : 'Dnešní záznam je výrazně pod tvým průměrem (${deviation.toStringAsFixed(1)}σ).',
            style: AppTypography.bodySm.copyWith(
              color: isHigh ? AppColors.accentWarm : AppColors.textSecondary,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Recording nudge ──────────────────────────────────────────────────────────

class _RecordingNudge extends StatelessWidget {
  final int days;
  const _RecordingNudge({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Naposledy jsi nahrál${'a' * 0} záznam před $days dny. Chceš si povídat?',
            style: AppTypography.bodySm,
          ),
        ),
      ]),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final DashboardData data;
  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (data.streak > 1) ...[
        _StatChip(
          icon: Icons.local_fire_department_rounded,
          label: '${data.streak}× v řadě',
          color: AppColors.accentWarm,
        ),
        const SizedBox(width: 8),
      ],
      if (data.periodAvgComposite != null)
        _StatChip(
          icon: Icons.show_chart_rounded,
          label: 'Ø ${data.periodAvgComposite!.toStringAsFixed(1)}σ',
          color: AppColors.accent,
        ),
    ]);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label, style: AppTypography.label.copyWith(color: color)),
      ]),
    );
  }
}

// ─── Record CTA ───────────────────────────────────────────────────────────────

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
        child: Row(children: [
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
        ]),
      ),
    );
  }
}

// ─── Recent card ─────────────────────────────────────────────────────────────

class _RecentCard extends StatelessWidget {
  final Map<String, dynamic> measurement;
  final VoidCallback onTap;
  const _RecentCard(this.measurement, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    final composite = (measurement['composite_zscore'] as num?)?.toDouble();
    final recordedAt = measurement['recorded_at'] as String?;
    final dt = recordedAt != null ? DateTime.tryParse(recordedAt)?.toLocal() : null;
    final analyzed = measurement['analyzed'] as bool? ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          // Score indicator
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _scoreColor(composite).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: analyzed
                  ? Text(
                      composite != null ? composite.toStringAsFixed(1) : '–',
                      style: AppTypography.mono.copyWith(color: _scoreColor(composite), fontSize: 12),
                    )
                  : SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.textSecondary),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dt != null ? DateFormat('d. MMMM yyyy', 'cs').format(dt) : '–',
                  style: AppTypography.bodyPrimary.copyWith(fontSize: 14),
                ),
                Text(
                  dt != null ? DateFormat('HH:mm', 'cs').format(dt) : '',
                  style: AppTypography.bodySm,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
        ]),
      ),
    );
  }

  Color _scoreColor(double? v) {
    if (v == null) return AppColors.textSecondary;
    if (v > 1.5) return AppColors.accentWarm;
    if (v < -1.5) return AppColors.textSecondary;
    return AppColors.accent;
  }
}

// ─── Placeholders ─────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({this.height = 120});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Text('Zatím žádné záznamy. Nahraj první.', style: AppTypography.body),
      );
}
