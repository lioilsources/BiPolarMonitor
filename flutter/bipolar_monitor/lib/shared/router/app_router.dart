import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/record/presentation/record_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      final userAsync = ref.read(currentUserProvider);
      final isAuth = userAsync.valueOrNull != null;
      final isLoading = userAsync.isLoading;

      if (isLoading) return null;

      final isOnAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!isAuth && !isOnAuth) return '/login';
      if (isAuth && isOnAuth) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/record', builder: (_, __) => const RecordScreen()),
    ],
  );
});
