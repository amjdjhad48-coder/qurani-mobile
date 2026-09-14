import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

void main() {
  group('Package 5 recitation domain', () {
    test('recitation types round-trip approved storage values', () {
      expect(RecitationType.newMemorization.storageValue, 'new_memorization');
      expect(RecitationType.revision.storageValue, 'revision');

      expect(
        RecitationType.fromStorage('new_memorization'),
        RecitationType.newMemorization,
      );
      expect(RecitationType.fromStorage('revision'), RecitationType.revision);

      expect(() => RecitationType.fromStorage('unsupported'), throwsStateError);
    });

    test('evaluation domain preserves the six approved Arabic labels', () {
      expect(
        RecitationEvaluation.values
            .map((value) => value.arabicLabel)
            .toList(growable: false),
        <String>['تلقين', 'ممتاز', 'جيد جدًا', 'جيد', 'مقبول', 'ضعيف'],
      );

      for (final evaluation in RecitationEvaluation.values) {
        expect(
          RecitationEvaluation.fromStorage(evaluation.storageValue),
          evaluation,
        );
      }

      expect(
        () => RecitationEvaluation.fromStorage('unsupported'),
        throwsStateError,
      );
    });

    test('quarter-face units expose the exact achieved face amount', () {
      final quarter = RecitationWriteData(
        type: RecitationType.newMemorization,
        actualRange: _range(2, 1, 2, 2),
        facesQuarterAchieved: 1,
        evaluation: RecitationEvaluation.excellent,
      );

      final half = RecitationWriteData(
        type: RecitationType.newMemorization,
        actualRange: _range(2, 1, 2, 2),
        facesQuarterAchieved: 2,
        evaluation: RecitationEvaluation.excellent,
      );

      final threeQuarters = RecitationWriteData(
        type: RecitationType.newMemorization,
        actualRange: _range(2, 1, 2, 2),
        facesQuarterAchieved: 3,
        evaluation: RecitationEvaluation.excellent,
      );

      final moreThanOneFace = RecitationWriteData(
        type: RecitationType.revision,
        actualRange: _range(2, 1, 2, 20),
        facesQuarterAchieved: 5,
        evaluation: RecitationEvaluation.good,
      );

      expect(quarter.achievedFaces, 0.25);
      expect(half.achievedFaces, 0.5);
      expect(threeQuarters.achievedFaces, 0.75);
      expect(moreThanOneFace.achievedFaces, 1.25);

      expect(quarter.isNewMemorization, isTrue);
      expect(quarter.isRevision, isFalse);
      expect(moreThanOneFace.isRevision, isTrue);
    });
  });
}

QuranRange _range(int startSurah, int startAyah, int endSurah, int endAyah) {
  return QuranRange(
    start: QuranPosition(surahNumber: startSurah, ayahNumber: startAyah),
    end: QuranPosition(surahNumber: endSurah, ayahNumber: endAyah),
  );
}
