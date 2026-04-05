// Basic smoke test for the Routine TodoApp.

import 'package:flutter_test/flutter_test.dart';

import 'package:routine/main.dart';

void main() {
  testWidgets('TodoApp smoke test - app renders without crashing',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const TodoApp());

    // Verify the app title is displayed.
    expect(find.text('ROUTINE'), findsOneWidget);

    // Verify the bottom navigation bar is present.
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
  });
}

