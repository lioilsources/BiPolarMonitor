import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/storage/local_database.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/measurement_detail_screen.dart';
import '../../features/onboarding/enrollment_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/record/presentation/record_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: routerNotifier,
    redirect: (context, state) async {
      final userAsync = ref.read(currentUserProvider);
      final isLoading = userAsync.isLoading;
      if (isLoading) return null;

      final isAuth = userAsync.valueOrNull != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register';
      final isOnboarding = loc == '/onboarding' || loc == '/enrollment';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/enrollment', builder: (_, __) => const EnrollmentScreen()),
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
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
}
