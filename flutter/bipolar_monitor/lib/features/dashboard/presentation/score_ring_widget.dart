import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Circular arc progress showing composite z-score.
/// Score is normalized from z-score (-3 to +3) to 0–1 for display.
class ScoreRingWidget extends StatelessWidget {
  final double? score;   // composite z-score
  final double? deviation;
  final String label;

  const ScoreRingWidget({super.key, this.score, this.deviation, required this.label});

  double get _normalized => score == null ? 0.5 : ((score! + 3) / 6).clamp(0.0, 1.0);

  Color get _ringColor => Color.lerp(AppColors.accent, AppColors.accentWarm, _normalized) ?? AppColors.accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CustomPaint(
              painter: _ArcPainter(progress: _normalized, color: _ringColor),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score != null ? score!.toStringAsFixed(1) : '–',
                      style: AppTypography.heading.copyWith(fontSize: 26),
                    ),
                    Text('σ', style: AppTypography.label),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodyPrimary.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (deviation != null)
                  Text(
                    deviation! > 0
                        ? '+${deviation!.toStringAsFixed(1)}σ od tvého průměru'
                        : '${deviation!.toStringAsFixed(1)}σ od tvého průměru',
                    style: AppTypography.bodySm,
                  ),
                if (score == null)
                  Text('Žádná dnešní data', style: AppTypography.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final startAngle = pi * 0.75;
    final sweepFull = pi * 1.5;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepFull, false,
      Paint()
        ..color = AppColors.divider
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepFull * progress, false,
        Paint()
          ..color = color
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress || old.color != color;
}
