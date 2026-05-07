import 'package:flutter/services.dart';

abstract final class Haptics {
  /// Tick — countdown, question advance
  static Future<void> tick() => HapticFeedback.selectionClick();

  /// Light confirmation — upload done, enrollment step complete
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Medium — recording started
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Heavy — error or significant alert
  static Future<void> heavy() => HapticFeedback.heavyImpact();
}
