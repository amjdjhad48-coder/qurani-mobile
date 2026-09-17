import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  group('SupportReportAttendanceStatus', () {
    test('uses canonical source-of-truth storage values', () {
      expect(SupportReportAttendanceStatus.present.storageValue, 'present');
      expect(SupportReportAttendanceStatus.absent.storageValue, 'absent');
      expect(
        SupportReportAttendanceStatus.excusedAbsent.storageValue,
        'excused_absent',
      );
    });

    test('round trips canonical attendance values', () {
      for (final value in SupportReportAttendanceStatus.values) {
        expect(
          SupportReportAttendanceStatus.fromStorage(value.storageValue),
          value,
        );
      }

      expect(
        () => SupportReportAttendanceStatus.fromStorage('late'),
        throwsStateError,
      );
    });
  });

  group('WeeklySupportReportProjection', () {
    test('represents one live Saturday-Wednesday projection', () {
      final projection = _validProjection();

      expect(projection.period.weekStart, DateTime(2026, 9, 12));

      expect(projection.period.weekEnd, DateTime(2026, 9, 16));

      expect(projection.days, hasLength(5));
      expect(projection.students, hasLength(1));
      expect(projection.hasWarnings, isFalse);

      expect(
        projection.dayForDate(DateTime(2026, 9, 12, 22)).dayKind,
        SupportReportDayKind.normal,
      );
    });

    test('achievement sums new memorization entries only', () {
      final projection = _validProjection();

      expect(projection.achievedQuarterFacesForStudent(7), 12);
    });

    test('supports multiple new memorization events in one day', () {
      final projection = _validProjection();

      final saturday = projection.dayForDate(DateTime(2026, 9, 12));

      expect(saturday.entries, hasLength(1));
      expect(saturday.entries.single.newMemorizationEntries, hasLength(2));

      expect(
        saturday.entries.single.attendanceStatus,
        SupportReportAttendanceStatus.present,
      );
    });

    test('keeps report missing items transient inside projection', () {
      final projection = _validProjection(
        missingItems: <ReportMissingItem>[
          ReportMissingItem(
            studentId: 7,
            studentName: 'أحمد',
            field: ReportMissingField.currentJuz,
          ),
          ReportMissingItem(
            studentId: 7,
            studentName: 'أحمد',
            field: ReportMissingField.attendanceStatus,
            localDate: DateTime(2026, 9, 15),
          ),
        ],
      );

      expect(projection.hasWarnings, isTrue);
      expect(projection.missingItemsForStudent(7), hasLength(2));
    });

    test('rejects duplicate students', () {
      expect(
        () => _validProjection(
          students: <WeeklySupportReportStudentProjection>[
            _student(),
            _student(),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('requires all five official dates in order', () {
      final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));

      expect(
        () => WeeklySupportReportProjection(
          period: period,
          header: _header(),
          students: <WeeklySupportReportStudentProjection>[_student()],
          days: <WeeklySupportReportDayProjection>[
            WeeklySupportReportDayProjection(
              localDate: DateTime(2026, 9, 12),
              dayKind: SupportReportDayKind.normal,
            ),
          ],
        ),
        throwsArgumentError,
      );

      expect(
        () => WeeklySupportReportProjection(
          period: period,
          header: _header(),
          students: <WeeklySupportReportStudentProjection>[_student()],
          days: <WeeklySupportReportDayProjection>[
            WeeklySupportReportDayProjection(
              localDate: DateTime(2026, 9, 13),
              dayKind: SupportReportDayKind.normal,
            ),
            WeeklySupportReportDayProjection(
              localDate: DateTime(2026, 9, 12),
              dayKind: SupportReportDayKind.normal,
            ),
            WeeklySupportReportDayProjection(
              localDate: DateTime(2026, 9, 14),
              dayKind: SupportReportDayKind.normal,
            ),
            WeeklySupportReportDayProjection(
              localDate: DateTime(2026, 9, 15),
              dayKind: SupportReportDayKind.normal,
            ),
            WeeklySupportReportDayProjection(
              localDate: DateTime(2026, 9, 16),
              dayKind: SupportReportDayKind.normal,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects a day entry for a student outside projection', () {
      expect(
        () => _validProjection(
          firstDayEntries: <WeeklySupportReportDayEntryProjection>[
            WeeklySupportReportDayEntryProjection(
              sourceStudentId: 999,
              attendanceStatus: SupportReportAttendanceStatus.present,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects more than one aggregate entry per student per day', () {
      expect(
        () => _validProjection(
          firstDayEntries: <WeeklySupportReportDayEntryProjection>[
            WeeklySupportReportDayEntryProjection(
              sourceStudentId: 7,
              attendanceStatus: SupportReportAttendanceStatus.present,
            ),
            WeeklySupportReportDayEntryProjection(
              sourceStudentId: 7,
              attendanceStatus: SupportReportAttendanceStatus.present,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects missing warning outside official week', () {
      expect(
        () => _validProjection(
          missingItems: <ReportMissingItem>[
            ReportMissingItem(
              studentId: 7,
              studentName: 'أحمد',
              field: ReportMissingField.attendanceStatus,
              localDate: DateTime(2026, 9, 18),
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects missing warning for unknown student', () {
      expect(
        () => _validProjection(
          missingItems: <ReportMissingItem>[
            const ReportMissingItem(
              studentId: 999,
              studentName: 'غير معروف',
              field: ReportMissingField.currentJuz,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });
  });
}

WeeklySupportReportProjection _validProjection({
  List<WeeklySupportReportStudentProjection>? students,
  List<WeeklySupportReportDayEntryProjection>? firstDayEntries,
  List<ReportMissingItem> missingItems = const <ReportMissingItem>[],
}) {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));

  return WeeklySupportReportProjection(
    period: period,
    header: _header(),
    students: students ?? <WeeklySupportReportStudentProjection>[_student()],
    days: <WeeklySupportReportDayProjection>[
      WeeklySupportReportDayProjection(
        localDate: DateTime(2026, 9, 12),
        dayKind: SupportReportDayKind.normal,
        entries:
            firstDayEntries ??
            <WeeklySupportReportDayEntryProjection>[
              WeeklySupportReportDayEntryProjection(
                sourceStudentId: 7,
                attendanceStatus: SupportReportAttendanceStatus.present,
                newMemorizationEntries:
                    const <WeeklySupportReportRecitationProjection>[
                      WeeklySupportReportRecitationProjection(
                        achievedQuarterFaces: 4,
                        range: SupportReportQuranRange(
                          startSurah: 2,
                          startAyah: 1,
                          endSurah: 2,
                          endAyah: 5,
                        ),
                      ),
                      WeeklySupportReportRecitationProjection(
                        achievedQuarterFaces: 8,
                        range: SupportReportQuranRange(
                          startSurah: 2,
                          startAyah: 6,
                          endSurah: 2,
                          endAyah: 20,
                        ),
                      ),
                    ],
              ),
            ],
      ),
      WeeklySupportReportDayProjection(
        localDate: DateTime(2026, 9, 13),
        dayKind: SupportReportDayKind.normal,
      ),
      WeeklySupportReportDayProjection(
        localDate: DateTime(2026, 9, 14),
        dayKind: SupportReportDayKind.holiday,
      ),
      WeeklySupportReportDayProjection(
        localDate: DateTime(2026, 9, 15),
        dayKind: SupportReportDayKind.missing,
      ),
      WeeklySupportReportDayProjection(
        localDate: DateTime(2026, 9, 16),
        dayKind: SupportReportDayKind.normal,
      ),
    ],
    missingItems: missingItems,
  );
}

const SupportReportHeaderSnapshot _headerValue = SupportReportHeaderSnapshot(
  teacherName: 'المعلم',
  halaqahName: 'حلقة النور',
  organizationName: 'الجهة الداعمة',
  policyVersion: SupportReportPolicy.policyVersion,
  templateVersion: SupportReportPolicy.templateVersion,
);

SupportReportHeaderSnapshot _header() => _headerValue;

WeeklySupportReportStudentProjection _student() {
  return const WeeklySupportReportStudentProjection(
    sourceStudentId: 7,
    supportStudentNumber: 'SUP-007',
    studentName: 'أحمد',
    currentJuz: 2,
    dailyPlanText: 'نصف وجه',
    displayOrder: 1,
  );
}
