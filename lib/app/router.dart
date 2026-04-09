import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/tasks/presentation/screens/task_list_screen.dart';
import '../features/tasks/presentation/screens/task_detail_screen.dart';
import '../features/tasks/presentation/screens/task_form_screen.dart';

/// Bridges Riverpod [AuthState] → [ChangeNotifier] for [GoRouter.refreshListenable].
///
/// When auth state changes, [notifyListeners] fires → GoRouter re-runs [redirect].
/// The router itself is never rebuilt; only the redirect is re-evaluated.
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    // Listen once — any auth state change triggers a router redirect check.
    _ref.listen<AuthState>(authNotifierProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final auth = _ref.read(authNotifierProvider);
    final loc = state.matchedLocation;

    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        // Still bootstrapping — keep user on splash
        return loc == '/splash' ? null : '/splash';

      case AuthStatus.authenticated:
        // Push away from auth screens once logged in
        if (loc == '/splash' || loc == '/login') return '/tasks';
        return null;

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        // Force login; allow staying on /login itself
        if (loc == '/login') return null;
        return '/login';
    }
  }
}

final routerNotifierProvider = ChangeNotifierProvider<_RouterNotifier>(
  (ref) => _RouterNotifier(ref),
);

/// The GoRouter is created ONCE (ref.read, not ref.watch).
/// Auth-triggered navigation is handled by [refreshListenable], not by
/// rebuilding the router from scratch.
final routerProvider = Provider<GoRouter>((ref) {
  // ref.read — intentional: we never want this provider to rebuild the router.
  final notifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false, // set true only when debugging routing
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (_, __) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/tasks/create',
        builder: (_, __) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (_, s) => TaskDetailScreen(taskId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, s) =>
                TaskFormScreen(taskId: s.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});

