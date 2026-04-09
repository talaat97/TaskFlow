import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gb_crop_assignment_task_app/app/app.dart';

void main() {
  testWidgets('App smoke test — TaskFlowApp renders without crashing',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TaskFlowApp()),
    );
    // Just confirm it builds — network calls and auth won't complete in unit test
    expect(find.byType(MaterialApp), findsNothing); // uses MaterialApp.router
    expect(find.byType(Router), findsOneWidget);
  });
}
