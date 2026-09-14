import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/recitation/application/recitation_validator.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

void main() {
  const validator = RecitationValidator();

  group('Package 5 recitation validator', () {
    test('accepts a valid same-surah actual range', () {
      final validated = validator.validateAndNormalize(
        _data(actualRange: _range(2, 10, 2, 20)),
      );

      expect(validated.actualRange.start.surahNumber, 2);
      expect(validated.actualRange.start.ayahNumber, 10);
      expect(validated.actualRange.end.surahNumber, 2);
      expect(validated.actualRange.end.ayahNumber, 20);
    });

    test('accepts an actual range that crosses surahs', () {
      final validated = validator.validateAndNormalize(
        _data(actualRange: _range(2, 286, 3, 1), facesQuarterAchieved: 3),
      );

      expect(validated.actualRange.start.surahNumber, 2);
      expect(validated.actualRange.start.ayahNumber, 286);
      expect(validated.actualRange.end.surahNumber, 3);
      expect(validated.actualRange.end.ayahNumber, 1);
      expect(validated.facesQuarterAchieved, 3);
    });

    test('rejects an actual ayah outside its surah', () {
      expect(
        () => validator.validateAndNormalize(
          _data(actualRange: _range(2, 287, 3, 1)),
        ),
        throwsA(
          isA<RecitationValidationException>().having(
            (error) => error.issue,
            'issue',
            RecitationValidationIssue.actualRange,
          ),
        ),
      );
    });

    test('rejects an actual range whose start is after its end', () {
      expect(
        () => validator.validateAndNormalize(
          _data(actualRange: _range(3, 1, 2, 286)),
        ),
        throwsA(
          isA<RecitationValidationException>().having(
            (error) => error.issue,
            'issue',
            RecitationValidationIssue.actualRange,
          ),
        ),
      );
    });

    test('planned range is optional', () {
      final validated = validator.validateAndNormalize(
        _data(actualRange: _range(2, 1, 2, 5), plannedRange: null),
      );

      expect(validated.plannedRange, isNull);
    });

    test('accepts a complete valid planned cross-surah range', () {
      final validated = validator.validateAndNormalize(
        _data(
          actualRange: _range(2, 1, 2, 5),
          plannedRange: _range(2, 280, 3, 5),
        ),
      );

      expect(validated.plannedRange, isNotNull);
      expect(validated.plannedRange!.start.surahNumber, 2);
      expect(validated.plannedRange!.end.surahNumber, 3);
    });

    test('rejects an invalid planned Quran range', () {
      expect(
        () => validator.validateAndNormalize(
          _data(
            actualRange: _range(2, 1, 2, 5),
            plannedRange: _range(3, 1, 2, 286),
          ),
        ),
        throwsA(
          isA<RecitationValidationException>().having(
            (error) => error.issue,
            'issue',
            RecitationValidationIssue.plannedRange,
          ),
        ),
      );
    });

    test('rejects zero or negative achieved quarter-face units', () {
      for (final invalidValue in <int>[0, -1]) {
        expect(
          () => validator.validateAndNormalize(
            _data(
              actualRange: _range(2, 1, 2, 5),
              facesQuarterAchieved: invalidValue,
            ),
          ),
          throwsA(
            isA<RecitationValidationException>().having(
              (error) => error.issue,
              'issue',
              RecitationValidationIssue.facesQuarterAchieved,
            ),
          ),
        );
      }
    });

    test('rejects a negative error count while zero is valid', () {
      final zeroErrors = validator.validateAndNormalize(
        _data(actualRange: _range(2, 1, 2, 5), errorCount: 0),
      );

      expect(zeroErrors.errorCount, 0);

      expect(
        () => validator.validateAndNormalize(
          _data(actualRange: _range(2, 1, 2, 5), errorCount: -1),
        ),
        throwsA(
          isA<RecitationValidationException>().having(
            (error) => error.issue,
            'issue',
            RecitationValidationIssue.errorCount,
          ),
        ),
      );
    });

    test('normalizes optional note without making it required', () {
      final trimmed = validator.validateAndNormalize(
        _data(actualRange: _range(2, 1, 2, 5), note: '  ملاحظة المعلم  '),
      );

      final empty = validator.validateAndNormalize(
        _data(actualRange: _range(2, 1, 2, 5), note: '   '),
      );

      final absent = validator.validateAndNormalize(
        _data(actualRange: _range(2, 1, 2, 5)),
      );

      expect(trimmed.note, 'ملاحظة المعلم');
      expect(empty.note, isNull);
      expect(absent.note, isNull);
    });

    test('revision uses the same Quran and quarter-face validation rules', () {
      final validated = validator.validateAndNormalize(
        _data(
          type: RecitationType.revision,
          actualRange: _range(1, 1, 2, 3),
          facesQuarterAchieved: 8,
          evaluation: RecitationEvaluation.good,
          errorCount: 2,
        ),
      );

      expect(validated.type, RecitationType.revision);
      expect(validated.facesQuarterAchieved, 8);
      expect(validated.achievedFaces, 2);
      expect(validated.errorCount, 2);
    });
  });
}

RecitationWriteData _data({
  RecitationType type = RecitationType.newMemorization,
  required QuranRange actualRange,
  int facesQuarterAchieved = 1,
  RecitationEvaluation evaluation = RecitationEvaluation.excellent,
  int errorCount = 0,
  String? note,
  QuranRange? plannedRange,
}) {
  return RecitationWriteData(
    type: type,
    actualRange: actualRange,
    facesQuarterAchieved: facesQuarterAchieved,
    evaluation: evaluation,
    errorCount: errorCount,
    note: note,
    plannedRange: plannedRange,
  );
}

QuranRange _range(int startSurah, int startAyah, int endSurah, int endAyah) {
  return QuranRange(
    start: QuranPosition(surahNumber: startSurah, ayahNumber: startAyah),
    end: QuranPosition(surahNumber: endSurah, ayahNumber: endAyah),
  );
}
