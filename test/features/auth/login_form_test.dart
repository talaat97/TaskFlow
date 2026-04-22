import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gb_crop_assignment_task_app/features/auth/presentation/screens/login_screen.dart';
import 'package:gb_crop_assignment_task_app/app/theme.dart';

// Minimal router stub so GoRouter context calls don't crash in tests
import 'package:go_router/go_router.dart';

Widget _buildTestApp() {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(path: '/tasks', builder: (_, __) => const Scaffold()),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      theme: AppTheme.darkTheme,
      routerConfig: router,
    ),
  );
}

void main() {
  group('LoginScreen form validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Tap the submit button without entering anything
      final submitBtn = find.byKey(const Key('login_submit_button'));
      expect(submitBtn, findsOneWidget);

      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Enter bad email
      await tester.enterText(
        find.byType(TextFormField).first,
        'not-an-email',
      );

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Fill valid email but leave password blank
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'test@example.com');
      await tester.enterText(fields.at(1), '123');

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('no validation errors with valid inputs', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'test@example.com');
      await tester.enterText(fields.at(1), 'password123');

      // Form should be valid — no error texts shown before submit triggers network
      await tester.pump();

      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Enter a valid email address'), findsNothing);
      expect(find.text('Password is required'), findsNothing);
    });
  });
}
