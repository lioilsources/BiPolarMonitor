import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'history_provider.dart';

class MeasurementCard extends StatelessWidget {
  final MeasurementSummary measurement;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MeasurementCard({
    super.key,
    required this.measurement,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(measurement.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.accentWarm.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.accentWarm),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Score badge
              _ScoreBadge(zscore: measurement.compositeZscore),
              const SizedBox(width: 14),

              // Date + flags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(measurement.recordedAt),
                      style: AppTypography.bodyPrimary.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(measurement.recordedAt),
                      style: AppTypography.bodySm,
                    ),
                    if (measurement.flags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: measurement.flags
                            .where((f) => f != 'emotional_avoidance') // never show this one
                            .map((f) => _FlagChip(flag: f))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Trend + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (measurement.trend7d != null) _TrendIcon(trend: measurement.trend7d!),
                  const SizedBox(height: 4),
                  if (!measurement.analyzed)
                    const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.textSecondary),
                    )
                  else
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Smazat záznam?', style: AppTypography.headingMd),
            content: Text('Tato akce je nevratná.', style: AppTypography.body),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Zrušit', style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary))),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Smazat', style: AppTypography.bodySm.copyWith(color: AppColors.accentWarm))),
            ],
          ),
        ) ??
        false;
  }

  String _formatDate(DateTime dt) => DateFormat('d. MMMM yyyy', 'cs').format(dt.toLocal());
  String _formatTime(DateTime dt) => DateFormat('HH:mm', 'cs').format(dt.toLocal());
}

class _ScoreBadge extends StatelessWidget {
  final double? zscore;
  const _ScoreBadge({this.zscore});

  Color get _color {
    if (zscore == null) return AppColors.surfaceAlt;
    if (zscore! > 1.5) return AppColors.accentWarm.withOpacity(0.8);
    if (zscore! < -1.5) return AppColors.textSecondary.withOpacity(0.5);
    return AppColors.accent.withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: _color.withOpacity(0.15), shape: BoxShape.circle),
      child: Center(
        child: Text(
          zscore != null ? zscore!.toStringAsFixed(1) : '–',
          style: AppTypography.mono.copyWith(color: _color, fontSize: 14),
        ),
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  final String flag;
  const _FlagChip({required this.flag});

  static const _labels = {
    'elevated_speech_rate': 'Tempo řeči ↑',
    'suppressed_speech_rate': 'Tempo řeči ↓',
    'monotone_voice': 'Monotónní hlas',
    'minimal_responses': 'Krátké odpovědi',
    'extended_responses': 'Dlouhé odpovědi',
    'flight_of_ideas': 'Hodně myšlenek',
    'low_energy_profile': 'Klidnější den',
  };

  @override
  Widget build(BuildContext context) {
    final label = _labels[flag] ?? flag;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: AppTypography.label.copyWith(fontSize: 11)),
    );
  }
}

class _TrendIcon extends StatelessWidget {
  final String trend;
  const _TrendIcon({required this.trend});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (trend) {
      'markedly_elevated' || 'mildly_elevated' => (Icons.trending_up_rounded, AppColors.accentWarm),
      'markedly_suppressed' || 'mildly_suppressed' => (Icons.trending_down_rounded, AppColors.textSecondary),
      _ => (Icons.trending_flat_rounded, AppColors.textSecondary),
    };
    return Icon(icon, color: color, size: 18);
  }
}
