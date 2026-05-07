/// BladeRunner-style dialog UI — shows one question at a time during recording.
/// The user sees the question, speaks, then taps "Další" to advance.
/// Question timings (start/end in recording seconds) are tracked for ML segmentation.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../domain/measurement_model.dart';

class DialogWidget extends StatefulWidget {
  final List<DialogQuestion> questions;
  final int suggestedDurationSeconds;
  final Duration recordingElapsed;          // live elapsed time from RecordingWidget
  final void Function(QuestionTiming) onQuestionAdvanced;
  final VoidCallback onAllQuestionsAnswered;

  const DialogWidget({
    super.key,
    required this.questions,
    required this.suggestedDurationSeconds,
    required this.recordingElapsed,
    required this.onQuestionAdvanced,
    required this.onAllQuestionsAnswered,
  });

  @override
  State<DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  double? _currentQuestionStart;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _currentQuestionStart = widget.recordingElapsed.inMilliseconds / 1000.0;
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool get _isLast => _currentIndex >= widget.questions.length - 1;
  DialogQuestion get _current => widget.questions[_currentIndex];

  void _advance() {
    HapticFeedback.selectionClick();
    final endSeconds = widget.recordingElapsed.inMilliseconds / 1000.0;
    widget.onQuestionAdvanced(QuestionTiming(
      questionId: _current.questionId,
      startSeconds: _currentQuestionStart ?? 0,
      endSeconds: endSeconds,
    ));

    if (_isLast) {
      widget.onAllQuestionsAnswered();
      return;
    }

    _fadeCtrl.reverse().then((_) {
      setState(() {
        _currentIndex++;
        _currentQuestionStart = endSeconds;
      });
      _fadeCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _current;
    return FadeTransition(
      opacity: _fade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question counter
          Row(
            children: [
              _DimensionChip(question.dimension),
              const Spacer(),
              Text(
                '${_currentIndex + 1} / ${widget.questions.length}',
                style: AppTypography.label,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // The question text — Voigt-Kampff style
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withOpacity(0.25)),
            ),
            child: Text(question.text, style: AppTypography.dialogQuestion),
          ),

          const SizedBox(height: 8),
          Text(
            'Mluv volně. Trvej tolik, kolik potřebuješ.',
            style: AppTypography.label.copyWith(color: AppColors.textSecondary.withOpacity(0.6)),
          ),

          const SizedBox(height: 28),

          // Advance button
          GestureDetector(
            onTap: _advance,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isLast ? AppColors.elevated : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isLast ? AppColors.accent : AppColors.divider,
                ),
              ),
              child: Center(
                child: Text(
                  _isLast ? 'Dokončit dialog' : 'Další otázka',
                  style: AppTypography.bodyPrimary.copyWith(
                    color: _isLast ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Progress dots
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.questions.length, (i) {
              final isActive = i == _currentIndex;
              final isDone = i < _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.accent.withOpacity(0.5)
                      : isActive
                          ? AppColors.accent
                          : AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DimensionChip extends StatelessWidget {
  final String dimension;

  const _DimensionChip(this.dimension);

  String get _label => switch (dimension) {
        'orientation' => 'Přítomnost',
        'abstraction' => 'Asociace',
        'cognitive'   => 'Pozornost',
        'valence'     => 'Pocity',
        'future'      => 'Výhled',
        _             => dimension,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(_label, style: AppTypography.label.copyWith(color: AppColors.accent)),
    );
  }
}
