import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';

void main() {
  group('QuranReferenceData surah metadata', () {
    test('contains exactly 114 surahs and 6236 ayahs', () {
      expect(QuranReferenceData.surahs, hasLength(114));
      expect(
        QuranReferenceData.surahs.fold<int>(
          0,
          (sum, surah) => sum + surah.ayahCount,
        ),
        QuranReferenceData.totalAyahCount,
      );

      for (var index = 0; index < QuranReferenceData.surahs.length; index++) {
        expect(QuranReferenceData.surahs[index].number, index + 1);
        expect(QuranReferenceData.surahs[index].arabicName, isNotEmpty);
        expect(QuranReferenceData.surahs[index].ayahCount, greaterThan(0));
      }

      expect(QuranReferenceData.surahByNumber(1).arabicName, 'الفاتحة');
      expect(QuranReferenceData.surahByNumber(1).ayahCount, 7);
      expect(QuranReferenceData.surahByNumber(2).arabicName, 'البقرة');
      expect(QuranReferenceData.surahByNumber(2).ayahCount, 286);
      expect(QuranReferenceData.surahByNumber(114).arabicName, 'الناس');
      expect(QuranReferenceData.surahByNumber(114).ayahCount, 6);
    });

    test('rejects surah numbers outside 1 through 114', () {
      expect(() => QuranReferenceData.surahByNumber(0), throwsRangeError);
      expect(() => QuranReferenceData.surahByNumber(115), throwsRangeError);
    });
  });

  group('Quran positions and ranges', () {
    test('validates ayah boundaries', () {
      expect(
        QuranReferenceData.isValidPosition(
          const QuranPosition(surahNumber: 1, ayahNumber: 1),
        ),
        isTrue,
      );
      expect(
        QuranReferenceData.isValidPosition(
          const QuranPosition(surahNumber: 2, ayahNumber: 286),
        ),
        isTrue,
      );
      expect(
        QuranReferenceData.isValidPosition(
          const QuranPosition(surahNumber: 2, ayahNumber: 287),
        ),
        isFalse,
      );
      expect(
        QuranReferenceData.isValidPosition(
          const QuranPosition(surahNumber: 0, ayahNumber: 1),
        ),
        isFalse,
      );
    });

    test('compares positions inside and across surahs', () {
      expect(
        QuranReferenceData.comparePositions(
          const QuranPosition(surahNumber: 2, ayahNumber: 10),
          const QuranPosition(surahNumber: 2, ayahNumber: 11),
        ),
        lessThan(0),
      );
      expect(
        QuranReferenceData.comparePositions(
          const QuranPosition(surahNumber: 2, ayahNumber: 286),
          const QuranPosition(surahNumber: 3, ayahNumber: 1),
        ),
        lessThan(0),
      );
      expect(
        QuranReferenceData.comparePositions(
          const QuranPosition(surahNumber: 3, ayahNumber: 1),
          const QuranPosition(surahNumber: 2, ayahNumber: 286),
        ),
        greaterThan(0),
      );
    });

    test('validates same-surah and cross-surah ranges', () {
      expect(
        QuranReferenceData.isValidRange(
          const QuranRange(
            start: QuranPosition(surahNumber: 2, ayahNumber: 10),
            end: QuranPosition(surahNumber: 2, ayahNumber: 20),
          ),
        ),
        isTrue,
      );
      expect(
        QuranReferenceData.isValidRange(
          const QuranRange(
            start: QuranPosition(surahNumber: 2, ayahNumber: 286),
            end: QuranPosition(surahNumber: 3, ayahNumber: 1),
          ),
        ),
        isTrue,
      );
      expect(
        QuranReferenceData.isValidRange(
          const QuranRange(
            start: QuranPosition(surahNumber: 3, ayahNumber: 1),
            end: QuranPosition(surahNumber: 2, ayahNumber: 286),
          ),
        ),
        isFalse,
      );
      expect(
        QuranReferenceData.isValidRange(
          const QuranRange(
            start: QuranPosition(surahNumber: 2, ayahNumber: 287),
            end: QuranPosition(surahNumber: 3, ayahNumber: 1),
          ),
        ),
        isFalse,
      );
    });
  });

  group('Quran juz reference', () {
    test('contains exactly 30 juzs in order', () {
      expect(QuranReferenceData.juzs, hasLength(30));

      for (var index = 0; index < QuranReferenceData.juzs.length; index++) {
        expect(QuranReferenceData.juzs[index].number, index + 1);
        expect(QuranReferenceData.juzs[index].segments, isNotEmpty);
      }

      expect(QuranReferenceData.juzByNumber(1).start.surahNumber, 1);
      expect(QuranReferenceData.juzByNumber(1).start.ayahNumber, 1);
      expect(QuranReferenceData.juzByNumber(30).end.surahNumber, 114);
      expect(QuranReferenceData.juzByNumber(30).end.ayahNumber, 6);
    });

    test('juz segments cover every Quran ayah exactly once and in order', () {
      var expectedSurah = 1;
      var expectedAyah = 1;
      var coveredAyahs = 0;

      for (final juz in QuranReferenceData.juzs) {
        for (final segment in juz.segments) {
          expect(segment.surahNumber, expectedSurah);
          expect(segment.startAyah, expectedAyah);

          final surah = QuranReferenceData.surahByNumber(segment.surahNumber);
          expect(segment.endAyah, lessThanOrEqualTo(surah.ayahCount));
          expect(segment.endAyah, greaterThanOrEqualTo(segment.startAyah));

          coveredAyahs += segment.ayahCount;

          if (segment.endAyah == surah.ayahCount) {
            expectedSurah += 1;
            expectedAyah = 1;
          } else {
            expectedAyah = segment.endAyah + 1;
          }
        }
      }

      expect(coveredAyahs, QuranReferenceData.totalAyahCount);
      expect(expectedSurah, 115);
      expect(expectedAyah, 1);
    });

    test('returns only surahs intersecting the selected juz', () {
      expect(
        QuranReferenceData.surahsForJuz(1).map((surah) => surah.number),
        orderedEquals(<int>[1, 2]),
      );
      expect(
        QuranReferenceData.surahsForJuz(2).map((surah) => surah.number),
        orderedEquals(<int>[2]),
      );
      expect(
        QuranReferenceData.surahsForJuz(21).map((surah) => surah.number),
        orderedEquals(<int>[29, 30, 31, 32, 33]),
      );

      final juz30 = QuranReferenceData.surahsForJuz(30);
      expect(juz30, hasLength(37));
      expect(juz30.first.number, 78);
      expect(juz30.last.number, 114);
    });

    test('exposes verse segments for later juz-aware UI selection', () {
      final juz1 = QuranReferenceData.segmentsForJuz(1);

      expect(juz1, hasLength(2));
      expect(juz1[0].surahNumber, 1);
      expect(juz1[0].startAyah, 1);
      expect(juz1[0].endAyah, 7);
      expect(juz1[1].surahNumber, 2);
      expect(juz1[1].startAyah, 1);
      expect(juz1[1].endAyah, 141);
    });

    test('rejects juz numbers outside 1 through 30', () {
      expect(() => QuranReferenceData.juzByNumber(0), throwsRangeError);
      expect(() => QuranReferenceData.juzByNumber(31), throwsRangeError);
      expect(() => QuranReferenceData.surahsForJuz(0), throwsRangeError);
      expect(() => QuranReferenceData.surahsForJuz(31), throwsRangeError);
    });
  });
}
