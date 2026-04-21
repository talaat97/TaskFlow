import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/tasks/presentation/screens/task_list_screen.dart';
import '../features/tasks/presentation/screens/task_detail_screen.dart';
import '../features/tasks/presentation/screens/task_form_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.matchedLocation;

      switch (auth.status) {
        case AuthStatus.initial:
        case AuthStatus.loading:
          return location == '/splash' ? null : '/splash';

        case AuthStatus.authenticated:
          if (location == '/login' || location == '/splash') return '/tasks';
          return null;

        case AuthStatus.unauthenticated:
        case AuthStatus.error:
          if (location == '/login') return null;
          return '/login';
      }
    },
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
      ),
    ],
  );
});
