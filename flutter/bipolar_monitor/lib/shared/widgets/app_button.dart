import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool secondary;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: onPressed == null
                ? AppColors.surfaceAlt
                : secondary
                    ? AppColors.surface
                    : AppColors.elevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: secondary ? AppColors.accent.withOpacity(0.4) : Colors.transparent,
            ),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                  )
                : Text(
                    label,
                    style: AppTypography.bodyPrimary.copyWith(
                      fontWeight: FontWeight.w600,
                      color: onPressed == null ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
