import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'shared/router/app_router.dart';

/// Watches the platform's accessibility settings:
/// - High contrast mode   → AppTheme.highContrast
/// - Text scale           → passed through (never clamped below 1.0)
class BipolarApp extends ConsumerWidget {
  const BipolarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1.0,
      maxScaleFactor: 2.0, // cap at 2× — prevents layout overflow on large settings
      child: Builder(
        builder: (ctx) {
          final highContrast = MediaQuery.of(ctx).highContrast;
          return MaterialApp.router(
            title: 'BipolarMonitor',
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: AppTheme.dark,
            highContrastTheme: AppTheme.highContrast,
            // System picks high-contrast automatically; we expose both
            themeMode: ThemeMode.dark,
          );
        },
      ),
    );
  }
}
