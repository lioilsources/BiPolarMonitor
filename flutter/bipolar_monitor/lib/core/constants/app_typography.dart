import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get heading => GoogleFonts.dmSerifDisplay(
        fontSize: 28,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get headingMd => GoogleFonts.dmSerifDisplay(
        fontSize: 22,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodyPrimary => GoogleFonts.dmSans(
        fontSize: 16,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySm => GoogleFonts.dmSans(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get mono => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        color: AppColors.accent,
      );

  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: 12,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w500,
      );

  // Dialog question style — large, calm, readable
  static TextStyle get dialogQuestion => GoogleFonts.dmSerifDisplay(
        fontSize: 20,
        color: AppColors.textPrimary,
        height: 1.45,
      );
}
