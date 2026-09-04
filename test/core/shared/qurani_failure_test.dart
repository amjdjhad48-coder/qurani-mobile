import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/shared/qurani_failure.dart';

void main() {
  group('QuraniFailure', () {
    test('defines exactly the seven approved failure categories', () {
      expect(
        QuraniFailureKind.values,
        orderedEquals(<QuraniFailureKind>[
          QuraniFailureKind.validation,
          QuraniFailureKind.notFound,
          QuraniFailureKind.conflict,
          QuraniFailureKind.storage,
          QuraniFailureKind.security,
          QuraniFailureKind.externalAction,
          QuraniFailureKind.unexpected,
        ]),
      );
    });

    test('named constructors map to the correct category', () {
      const failures = <QuraniFailure>[
        QuraniFailure.validation(),
        QuraniFailure.notFound(),
        QuraniFailure.conflict(),
        QuraniFailure.storage(),
        QuraniFailure.security(),
        QuraniFailure.externalAction(),
        QuraniFailure.unexpected(),
      ];

      expect(
        failures.map((failure) => failure.kind),
        orderedEquals(QuraniFailureKind.values),
      );
    });

    test('retains optional technical context without making it UI copy', () {
      const failure = QuraniFailure.validation(
        context: 'student name is required',
      );

      expect(failure.kind, QuraniFailureKind.validation);
      expect(failure.context, 'student name is required');
      expect(failure.cause, isNull);
    });

    test('retains an optional original cause for diagnostics or mapping', () {
      final cause = StateError('database unavailable');
      final failure = QuraniFailure.storage(
        context: 'open encrypted database',
        cause: cause,
      );

      expect(failure.kind, QuraniFailureKind.storage);
      expect(failure.context, 'open encrypted database');
      expect(identical(failure.cause, cause), isTrue);
    });

    test('does not require a cause or context for category-only failures', () {
      const failure = QuraniFailure.externalAction();

      expect(failure.kind, QuraniFailureKind.externalAction);
      expect(failure.context, isNull);
      expect(failure.cause, isNull);
    });
  });
}
