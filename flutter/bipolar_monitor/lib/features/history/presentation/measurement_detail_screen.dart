import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'history_provider.dart';

class MeasurementDetailScreen extends ConsumerStatefulWidget {
  final String measurementId;
  const MeasurementDetailScreen({super.key, required this.measurementId});

  @override
  ConsumerState<MeasurementDetailScreen> createState() => _MeasurementDetailScreenState();
}

class _MeasurementDetailScreenState extends ConsumerState<MeasurementDetailScreen> {
  final _notesCtrl = TextEditingController();

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(measurementDetailProvider(widget.measurementId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Detail záznamu', style: AppTypography.headingMd),
        titleSpacing: 0,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(child: Text('Nepodařilo se načíst.', style: AppTypography.body)),
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _SectionCard(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('d. MMMM yyyy, HH:mm', 'cs').format(detail.recordedAt.toLocal()), style: AppTypography.bodyPrimary.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${detail.durationSeconds ~/ 60}:${(detail.durationSeconds % 60).toString().padLeft(2, '0')} min', style: AppTypography.bodySm),
                  if (detail.speakerVerified != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(detail.speakerVerified! ? Icons.verified_user_outlined : Icons.help_outline, color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        detail.speakerVerified! ? 'Hlas ověřen (${(detail.speakerSimilarity! * 100).toInt()}%)' : 'Hlas neověřen',
                        style: AppTypography.label,
                      ),
                    ]),
                  ],
                ],
              )),
              const SizedBox(height: 12),

              // Radar chart — 5 dimenzí
              if (detail.scores != null && detail.analyzed) ...[
                Text('Profil', style: AppTypography.label),
                const SizedBox(height: 8),
                _SectionCard(child: SizedBox(height: 220, child: _RadarChart(scores: detail.scores!))),
                const SizedBox(height: 12),
              ],

              // Scores breakdown
              if (detail.scores != null) ...[
                Text('Dimenze', style: AppTypography.label),
                const SizedBox(height: 8),
                _SectionCard(child: _ScoreBreakdown(scores: detail.scores!)),
                const SizedBox(height: 12),
              ],

              // Per-question
              if (detail.perQuestion != null && detail.perQuestion!.isNotEmpty) ...[
                Text('Dialog', style: AppTypography.label),
                const SizedBox(height: 8),
                _SectionCard(child: _PerQuestionView(perQuestion: detail.perQuestion!)),
                const SizedBox(height: 12),
              ],

              // Flags
              if (detail.flags.isNotEmpty) ...[
                Text('Signály', style: AppTypography.label),
                const SizedBox(height: 8),
                _SectionCard(child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: detail.flags
                      .where((f) => f != 'emotional_avoidance')
                      .map((f) => _FlagTile(flag: f))
                      .toList(),
                )),
                const SizedBox(height: 12),
              ],

              // Notes
              Text('Poznámka', style: AppTypography.label),
              const SizedBox(height: 8),
              _SectionCard(child: TextField(
                controller: _notesCtrl..text = detail.notes ?? '',
                maxLines: 4,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'Přidej poznámku k tomuto záznamu…',
                  hintStyle: AppTypography.bodySm,
                  border: InputBorder.none,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
    child: child,
  );
}

class _RadarChart extends StatelessWidget {
  final Map<String, double> scores;
  const _RadarChart({required this.scores});

  static const _dims = ['speech_rate', 'voice_energy', 'response_length', 'cohesion', 'facial_affect'];
  static const _labels = ['Tempo', 'Energie', 'Délka', 'Soustředění', 'Výraz'];

  @override
  Widget build(BuildContext context) {
    final values = _dims.map((d) => (scores['${d}_zscore'] ?? 0.0).clamp(-3.0, 3.0)).toList();

    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: values.map((v) => RadarEntry(value: v + 3)).toList(), // shift to 0–6
            fillColor: AppColors.accent.withOpacity(0.15),
            borderColor: AppColors.accent,
            borderWidth: 2,
          ),
        ],
        radarShape: RadarShape.polygon,
        tickCount: 3,
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        gridBorderData: const BorderSide(color: AppColors.divider, width: 1),
        titleTextStyle: AppTypography.label.copyWith(fontSize: 11),
        getTitle: (i, _) => RadarChartTitle(text: _labels[i]),
        radarBorderData: const BorderSide(color: AppColors.divider),
        tickBorderData: const BorderSide(color: Colors.transparent),
      ),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  final Map<String, double> scores;
  const _ScoreBreakdown({required this.scores});

  static const _rows = [
    ('speech_rate_zscore', 'Tempo řeči'),
    ('pause_ratio_zscore', 'Pauzy'),
    ('voice_energy_zscore', 'Energie hlasu'),
    ('f0_range_zscore', 'Melodie hlasu'),
    ('response_length_zscore', 'Délka odpovědí'),
    ('cohesion_zscore', 'Soustředění'),
    ('facial_affect_zscore', 'Výraz tváře'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map(((String key, String label) row) {
        final v = scores[row.$1];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            SizedBox(width: 120, child: Text(row.$2, style: AppTypography.bodySm)),
            Expanded(child: _ZscoreBar(value: v)),
            SizedBox(width: 36, child: Text(v != null ? v.toStringAsFixed(1) : '–', style: AppTypography.mono.copyWith(fontSize: 12), textAlign: TextAlign.right)),
          ]),
        );
      }).toList(),
    );
  }
}

class _ZscoreBar extends StatelessWidget {
  final double? value;
  const _ZscoreBar({this.value});

  @override
  Widget build(BuildContext context) {
    final v = (value ?? 0).clamp(-3.0, 3.0);
    final fraction = (v + 3) / 6;
    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth;
      return Stack(children: [
        Container(height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
        Positioned(
          left: w / 2,
          child: Container(
            width: max(2.0, (fraction - 0.5).abs() * w),
            height: 4,
            decoration: BoxDecoration(
              color: v > 0 ? AppColors.accent : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Positioned(left: w / 2 - 1, child: Container(width: 2, height: 4, color: AppColors.textSecondary.withOpacity(0.4))),
      ]);
    });
  }
}

class _PerQuestionView extends StatelessWidget {
  final Map<String, dynamic> perQuestion;
  const _PerQuestionView({required this.perQuestion});

  static const _qLabels = {'Q1': 'Přítomnost', 'Q2': 'Asociace', 'Q3': 'Pozornost', 'Q4': 'Pocity', 'Q5': 'Výhled'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: perQuestion.entries.map((e) {
        final data = e.value as Map<String, dynamic>? ?? {};
        final wpm = data['wpm'] as double?;
        final wordCount = data['word_count'] as int?;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_qLabels[e.key] ?? e.key, style: AppTypography.bodySm.copyWith(color: AppColors.accent)),
              const SizedBox(height: 4),
              if (data['text'] != null)
                Text(data['text'] as String, style: AppTypography.bodySm),
              const SizedBox(height: 4),
              Row(children: [
                if (wpm != null) Text('${wpm.toInt()} slov/min', style: AppTypography.label),
                if (wpm != null && wordCount != null) Text('  ·  ', style: AppTypography.label),
                if (wordCount != null) Text('$wordCount slov', style: AppTypography.label),
              ]),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FlagTile extends StatelessWidget {
  final String flag;
  const _FlagTile({required this.flag});

  static const _flagInfo = {
    'elevated_speech_rate':   ('Mluvil jsi dnes rychleji než obvykle.', Icons.speed_rounded),
    'suppressed_speech_rate': ('Mluvil jsi dnes pomaleji než obvykle.', Icons.slow_motion_video_rounded),
    'monotone_voice':         ('Tvůj hlas byl dnes klidnější a tišší.', Icons.graphic_eq_rounded),
    'minimal_responses':      ('Odpovědi byly kratší než obvykle.', Icons.compress_rounded),
    'extended_responses':     ('Hodně myšlenek najednou?', Icons.expand_rounded),
    'flight_of_ideas':        ('Hodně myšlenek najednou?', Icons.bolt_rounded),
    'low_energy_profile':     ('Dnes to vypadá na klidnější den.', Icons.battery_low_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final info = _flagInfo[flag] ?? (flag, Icons.info_outline_rounded);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(info.$2, size: 14, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(info.$1, style: AppTypography.bodySm.copyWith(fontSize: 13)),
      ]),
    );
  }
}
