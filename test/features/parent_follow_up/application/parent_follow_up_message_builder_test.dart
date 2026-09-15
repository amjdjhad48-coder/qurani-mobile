import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_message_builder.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

void main() {
  const builder = ParentFollowUpMessageBuilder();

  group('Package 6 parent follow up message builder', () {
    test('daily message contains the approved operational fields', () {
      final message = builder.buildDaily(
        ParentFollowUpDailyPreviewInput(
          studentName: ' أحمد ',
          dayDate: '2026-09-15',
          attendanceStatus: ParentFollowUpAttendanceStatus.present,
          recitations: const <ParentFollowUpRecitationPreview>[
            ParentFollowUpRecitationPreview(
              type: RecitationType.newMemorization,
              actualRange: QuranRange(
                start: QuranPosition(surahNumber: 2, ayahNumber: 1),
                end: QuranPosition(surahNumber: 2, ayahNumber: 5),
              ),
              facesQuarterAchieved: 2,
              evaluation: RecitationEvaluation.excellent,
              note: '  أداء طيب  ',
            ),
            ParentFollowUpRecitationPreview(
              type: RecitationType.revision,
              actualRange: QuranRange(
                start: QuranPosition(surahNumber: 1, ayahNumber: 1),
                end: QuranPosition(surahNumber: 1, ayahNumber: 7),
              ),
              facesQuarterAchieved: 4,
              evaluation: RecitationEvaluation.veryGood,
            ),
          ],
          teacherName: 'المعلم',
          halaqahName: 'حلقة ذي النورين',
          centerName: 'المركز الرئيسي',
        ),
      );

      expect(message, startsWith('السلام عليكم ورحمة الله وبركاته'));
      expect(message, contains('متابعة الطالب: أحمد'));
      expect(message, contains('التاريخ: 2026-09-15'));
      expect(message, contains('الحضور: حاضر'));
      expect(message, contains('التسميع:'));
      expect(message, contains('حفظ جديد'));
      expect(message, contains('مراجعة'));
      expect(message, contains('سورة البقرة'));
      expect(message, contains('سورة الفاتحة'));
      expect(message, contains('نصف وجه'));
      expect(message, contains('وجه واحد'));
      expect(message, contains('التقييم ممتاز'));
      expect(message, contains('التقييم جيد جدًا'));
      expect(message, contains('ما حفظه الطالب اليوم:'));
      expect(message, contains('الملاحظات:'));
      expect(message, contains('أداء طيب'));
      expect(message, contains('المعلم: المعلم'));
      expect(message, contains('الحلقة: حلقة ذي النورين'));
      expect(message, contains('المركز: المركز الرئيسي'));
    });

    test('daily message remains simple when no recitation exists', () {
      final message = builder.buildDaily(
        const ParentFollowUpDailyPreviewInput(
          studentName: 'خالد',
          dayDate: '2026-09-15',
          attendanceStatus: ParentFollowUpAttendanceStatus.absent,
          recitations: <ParentFollowUpRecitationPreview>[],
          teacherName: 'المعلم',
          halaqahName: 'الحلقة',
        ),
      );

      expect(message, contains('الحضور: غائب'));
      expect(message, contains('لا يوجد تسميع مسجل اليوم.'));
      expect(message, contains('لا يوجد حفظ جديد مسجل.'));
      expect(message, contains('الملاحظات: لا توجد ملاحظات.'));
      expect(message, isNot(contains('المركز:')));
    });

    test('pending preview is rebuilt from current input, not frozen', () {
      const initial = ParentFollowUpDailyPreviewInput(
        studentName: 'سالم',
        dayDate: '2026-09-15',
        attendanceStatus: ParentFollowUpAttendanceStatus.absent,
        recitations: <ParentFollowUpRecitationPreview>[],
        teacherName: 'المعلم',
        halaqahName: 'الحلقة',
      );

      const corrected = ParentFollowUpDailyPreviewInput(
        studentName: 'سالم',
        dayDate: '2026-09-15',
        attendanceStatus: ParentFollowUpAttendanceStatus.present,
        recitations: <ParentFollowUpRecitationPreview>[
          ParentFollowUpRecitationPreview(
            type: RecitationType.newMemorization,
            actualRange: QuranRange(
              start: QuranPosition(surahNumber: 112, ayahNumber: 1),
              end: QuranPosition(surahNumber: 112, ayahNumber: 4),
            ),
            facesQuarterAchieved: 1,
            evaluation: RecitationEvaluation.good,
            note: 'تحسن واضح',
          ),
        ],
        teacherName: 'المعلم',
        halaqahName: 'الحلقة',
      );

      final firstPreview = builder.buildDaily(initial);
      final secondPreview = builder.buildDaily(corrected);

      expect(firstPreview, contains('الحضور: غائب'));
      expect(firstPreview, contains('لا يوجد تسميع مسجل اليوم.'));

      expect(secondPreview, contains('الحضور: حاضر'));
      expect(secondPreview, contains('حفظ جديد'));
      expect(secondPreview, contains('سورة الإخلاص'));
      expect(secondPreview, contains('تحسن واضح'));

      expect(secondPreview, isNot(firstPreview));
    });

    test('multiple new memorization recitations are accumulated', () {
      final message = builder.buildDaily(
        const ParentFollowUpDailyPreviewInput(
          studentName: 'أحمد',
          dayDate: '2026-09-15',
          attendanceStatus: ParentFollowUpAttendanceStatus.present,
          recitations: <ParentFollowUpRecitationPreview>[
            ParentFollowUpRecitationPreview(
              type: RecitationType.newMemorization,
              actualRange: QuranRange(
                start: QuranPosition(surahNumber: 113, ayahNumber: 1),
                end: QuranPosition(surahNumber: 113, ayahNumber: 5),
              ),
              facesQuarterAchieved: 2,
              evaluation: RecitationEvaluation.excellent,
            ),
            ParentFollowUpRecitationPreview(
              type: RecitationType.newMemorization,
              actualRange: QuranRange(
                start: QuranPosition(surahNumber: 114, ayahNumber: 1),
                end: QuranPosition(surahNumber: 114, ayahNumber: 6),
              ),
              facesQuarterAchieved: 3,
              evaluation: RecitationEvaluation.veryGood,
            ),
          ],
          teacherName: 'المعلم',
          halaqahName: 'الحلقة',
        ),
      );

      expect(message, contains('بإجمالي وجه واحد وربع وجه.'));
    });

    test('cross surah range is rendered explicitly', () {
      final message = builder.buildDaily(
        const ParentFollowUpDailyPreviewInput(
          studentName: 'أحمد',
          dayDate: '2026-09-15',
          attendanceStatus: ParentFollowUpAttendanceStatus.present,
          recitations: <ParentFollowUpRecitationPreview>[
            ParentFollowUpRecitationPreview(
              type: RecitationType.newMemorization,
              actualRange: QuranRange(
                start: QuranPosition(surahNumber: 2, ayahNumber: 286),
                end: QuranPosition(surahNumber: 3, ayahNumber: 3),
              ),
              facesQuarterAchieved: 1,
              evaluation: RecitationEvaluation.good,
            ),
          ],
          teacherName: 'المعلم',
          halaqahName: 'الحلقة',
        ),
      );

      expect(
        message,
        contains(
          'من سورة البقرة الآية 286 '
          'إلى سورة آل عمران الآية 3',
        ),
      );
    });

    test('attendance correction identifies itself explicitly', () {
      final message = builder.buildAttendanceCorrection(
        const ParentFollowUpAttendanceCorrectionInput(
          studentName: 'محمد',
          dayDate: '2026-09-15',
          previousStatus: ParentFollowUpAttendanceStatus.absent,
          currentStatus: ParentFollowUpAttendanceStatus.present,
          teacherName: 'المعلم',
          halaqahName: 'الحلقة',
          centerName: 'المركز',
        ),
      );

      expect(message, contains('تصحيح متابعة الحضور'));
      expect(message, contains('الحالة السابقة: غائب'));
      expect(message, contains('الحالة الصحيحة: حاضر'));
      expect(message, contains('الطالب: محمد'));
      expect(message, contains('المركز: المركز'));
    });

    test('blank required data and invalid achievement fail explicitly', () {
      expect(
        () => builder.buildDaily(
          const ParentFollowUpDailyPreviewInput(
            studentName: ' ',
            dayDate: '2026-09-15',
            attendanceStatus: ParentFollowUpAttendanceStatus.present,
            recitations: <ParentFollowUpRecitationPreview>[],
            teacherName: 'المعلم',
            halaqahName: 'الحلقة',
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => builder.buildDaily(
          const ParentFollowUpDailyPreviewInput(
            studentName: 'أحمد',
            dayDate: '2026-09-15',
            attendanceStatus: ParentFollowUpAttendanceStatus.present,
            recitations: <ParentFollowUpRecitationPreview>[
              ParentFollowUpRecitationPreview(
                type: RecitationType.newMemorization,
                actualRange: QuranRange(
                  start: QuranPosition(surahNumber: 1, ayahNumber: 1),
                  end: QuranPosition(surahNumber: 1, ayahNumber: 1),
                ),
                facesQuarterAchieved: 0,
                evaluation: RecitationEvaluation.good,
              ),
            ],
            teacherName: 'المعلم',
            halaqahName: 'الحلقة',
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}
