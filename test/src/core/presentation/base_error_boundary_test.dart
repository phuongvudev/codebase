import 'package:codebase/codebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BaseErrorBoundary', () {
    testWidgets('renders child when no error is captured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BaseErrorBoundary(
            builder: (_) => const Text('child'),
          ),
        ),
      );

      expect(find.text('child'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets('renders fallback when builder throws', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BaseErrorBoundary(
            builder: (_) => throw StateError('boom'),
          ),
        ),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.textContaining('boom'), findsOneWidget);
    });

    testWidgets('calls onError when builder throws', (tester) async {
      Object? capturedError;
      StackTrace? capturedStackTrace;

      await tester.pumpWidget(
        MaterialApp(
          home: BaseErrorBoundary(
            onError: (error, stackTrace) {
              capturedError = error;
              capturedStackTrace = stackTrace;
            },
            builder: (_) => throw StateError('listener boom'),
          ),
        ),
      );

      expect(capturedError, isA<StateError>());
      expect(capturedError.toString(), contains('listener boom'));
      expect(capturedStackTrace, isNotNull);
      expect(capturedStackTrace.toString(), isNotEmpty);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('supports retry after a manual capture', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BaseErrorBoundary(
            fallbackBuilder: (context, error, stackTrace, retry) {
              return Center(
                child: TextButton(
                  onPressed: retry,
                  child: Text(error.toString()),
                ),
              );
            },
            builder: (context) => TextButton(
              onPressed: () {
                BaseErrorBoundary.of(
                  context,
                ).capture(StateError('manual failure'));
              },
              child: const Text('trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('trigger'));
      await tester.pump();

      expect(find.textContaining('manual failure'), findsOneWidget);

      await tester.tap(find.textContaining('manual failure'));
      await tester.pump();

      expect(find.text('trigger'), findsOneWidget);
    });
  });
}
