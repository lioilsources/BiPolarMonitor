import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/storage/local_database.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/measurement_detail_screen.dart';
import '../../features/onboarding/enrollment_screen.dart';
import '../../features/onboarding/face_enrollment_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/record/presentation/record_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final _routerKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = _RouterNotifier(ref);

  final router = GoRouter(
    navigatorKey: _routerKey,
    initialLocation: '/dashboard',
    refreshListenable: routerNotifier,
    redirect: (context, state) async {
      final userAsync = ref.read(currentUserProvider);
      if (userAsync.isLoading) return null;

      final isAuth = userAsync.valueOrNull != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/enrollment', builder: (_, __) => const EnrollmentScreen()),
      GoRoute(path: '/face-enrollment', builder: (_, __) => const FaceEnrollmentScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/record', builder: (_, __) => const RecordScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(
        path: '/measurement/:id',
        builder: (_, state) => MeasurementDetailScreen(measurementId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );

  // Wire notification taps to router navigation
  NotificationService.onTap = (route) {
    _routerKey.currentContext?.let((ctx) => router.push(route));
  };

  return router;
});

extension _ContextExt on BuildContext {
  T? let<T>(T Function(BuildContext) fn) {
    try { return fn(this); } catch (_) { return null; }
  }
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
}
