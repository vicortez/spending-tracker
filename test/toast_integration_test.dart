import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spending_tracker/utils/toast_utils.dart';

void main() {
  group('Toast Integration Tests', () {
    testWidgets('Toast appears and displays message correctly', (WidgetTester tester) async {
      // Build a simple app with a button to trigger toast
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showToast(context, 'Test Message'),
                  child: const Text('Show Toast'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show toast
      await tester.tap(find.text('Show Toast'));
      await tester.pumpAndSettle();

      // Verify toast message appears
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('Toast has close button and can be dismissed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showToast(context, 'Dismissible Toast'),
                  child: const Text('Show Toast'),
                ),
              ),
            ),
          ),
        ),
      );

      // Show the toast
      await tester.tap(find.text('Show Toast'));
      await tester.pumpAndSettle();

      // Verify toast is visible
      expect(find.text('Dismissible Toast'), findsOneWidget);

      // Find and tap the close button
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Verify toast is dismissed
      expect(find.text('Dismissible Toast'), findsNothing);
    });

    testWidgets('Toast auto-dismisses after duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showToast(
                    context,
                    'Auto Dismiss Toast',
                    duration: const Duration(seconds: 2),
                  ),
                  child: const Text('Show Toast'),
                ),
              ),
            ),
          ),
        ),
      );

      // Show the toast
      await tester.tap(find.text('Show Toast'));
      await tester.pumpAndSettle();

      // Verify toast is visible
      expect(find.text('Auto Dismiss Toast'), findsOneWidget);

      // Wait for auto-dismiss (2 seconds + a bit extra)
      await tester.pump(const Duration(seconds: 2, milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify toast is dismissed
      expect(find.text('Auto Dismiss Toast'), findsNothing);
    });

    testWidgets('Toast shows progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showToast(context, 'Progress Test'),
                  child: const Text('Show Toast'),
                ),
              ),
            ),
          ),
        ),
      );

      // Show the toast
      await tester.tap(find.text('Show Toast'));
      await tester.pumpAndSettle();

      // Verify LinearProgressIndicator exists
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Multiple toasts can be shown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => showToast(context, 'First Toast'),
                      child: const Text('Show First'),
                    ),
                    ElevatedButton(
                      onPressed: () => showToast(context, 'Second Toast'),
                      child: const Text('Show Second'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Show first toast
      await tester.tap(find.text('Show First'));
      await tester.pumpAndSettle();
      expect(find.text('First Toast'), findsOneWidget);

      // Show second toast (should replace or stack with first)
      await tester.tap(find.text('Show Second'));
      await tester.pumpAndSettle();
      expect(find.text('Second Toast'), findsOneWidget);
    });

    testWidgets('Toast has white background and black text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showToast(context, 'Styled Toast'),
                  child: const Text('Show Toast'),
                ),
              ),
            ),
          ),
        ),
      );

      // Show the toast
      await tester.tap(find.text('Show Toast'));
      await tester.pumpAndSettle();

      // Find the text widget and verify it has black color
      final textWidget = tester.widget<Text>(find.text('Styled Toast'));
      expect(textWidget.style?.color, Colors.black);
    });

    testWidgets('Toast appears at top position', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showToast(context, 'Top Position Toast'),
                  child: const Text('Show Toast'),
                ),
              ),
            ),
          ),
        ),
      );

      // Show the toast
      await tester.tap(find.text('Show Toast'));
      await tester.pumpAndSettle();

      // Find the toast message
      final toastFinder = find.text('Top Position Toast');
      expect(toastFinder, findsOneWidget);

      // Get the position - should be near the top of the screen
      final toastPosition = tester.getTopLeft(toastFinder);
      final screenHeight = tester.getSize(find.byType(MaterialApp)).height;

      // Toast should be in the top half of the screen
      expect(toastPosition.dy < screenHeight / 2, isTrue);
    });
  });
}
