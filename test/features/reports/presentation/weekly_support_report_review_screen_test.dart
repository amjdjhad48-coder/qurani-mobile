import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_service.dart';
import 'package:qurani/features/reports/application/weekly_support_report_review.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';
import 'package:qurani/features/reports/presentation/support_reports_screen.dart';
import 'package:qurani/features/reports/presentation/weekly_support_report_review_screen.dart';

void main() {
  testWidgets(
    'weekly review view shows stale state warnings source correction actions and disabled approval',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final review = _review();

      var fixedProfileStudentId = -1;
      var fixedProgressStudentId = -1;
      ReportMissingItem? fixedAttendanceItem;
      int? fixedAttendanceDayId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklySupportReportReviewView(
              review: review,
              actionsEnabled: true,
              onFixStudentProfile: (studentId) async {
                fixedProfileStudentId = studentId;
              },
              onFixProgressPlan: (studentId) async {
                fixedProgressStudentId = studentId;
              },
              onFixAttendance: (item, sourceDayId) async {
                fixedAttendanceItem = item;
                fixedAttendanceDayId = sourceDayId;
              },
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('weekly_report_stale_warning')),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('weekly_report_missing_warnings')),
        findsOneWidget,
      );

      expect(find.byKey(const Key('weekly_report_student_7')), findsOneWidget);

      final approval = tester.widget<FilledButton>(
        find.byKey(const Key('weekly_report_final_approval_button')),
      );

      expect(approval.onPressed, isNull);

      await tester.tap(
        find.byKey(const Key('weekly_report_fix_support_number_7')),
      );
      await tester.pump();

      expect(fixedProfileStudentId, 7);

      await tester.tap(
        find.byKey(const Key('weekly_report_fix_current_juz_7')),
      );
      await tester.pump();

      expect(fixedProgressStudentId, 7);

      await tester.tap(
        find.byKey(const Key('weekly_report_fix_attendance_7_20260914')),
      );
      await tester.pump();

      expect(fixedAttendanceItem?.studentId, 7);
      expect(fixedAttendanceDayId, 44);
    },
  );

  testWidgets('reports weekly gateway opens the live weekly review screen', (
    tester,
  ) async {
    final review = _review();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          supportReportsRuntimeContextProvider.overrideWith(
            (ref) async => SupportReportsRuntimeContext(
              halaqahId: 1,
              supportEnabled: true,
              history: <SupportReportHistoryItem>[],
            ),
          ),
          weeklySupportReportReviewProvider.overrideWith((ref) async => review),
        ],
        child: MaterialApp(
          home: SupportReportsScreen(
            actionsEnabled: true,
            onChangePin: () {},
            onLockNow: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('reports_current_weekly_gateway')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('reports_current_weekly_gateway')));

    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('weekly_support_report_review_screen')),
      findsOneWidget,
    );

    expect(
      find.byKey(const Key('weekly_report_stale_warning')),
      findsOneWidget,
    );
  });
}

WeeklySupportReportReview _review() {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));

  const studentId = 7;

  final days = <WeeklySupportReportDayProjection>[
    for (final date in period.officialDates)
      WeeklySupportReportDayProjection(
        localDate: date,
        dayKind: SupportReportDayKind.normal,
        entries: <WeeklySupportReportDayEntryProjection>[
          WeeklySupportReportDayEntryProjection(
            sourceStudentId: studentId,
            attendanceStatus: date == DateTime(2026, 9, 14)
                ? null
                : SupportReportAttendanceStatus.present,
            newMemorizationEntries: date == DateTime(2026, 9, 14)
                ? const <WeeklySupportReportRecitationProjection>[
                    WeeklySupportReportRecitationProjection(
                      achievedQuarterFaces: 2,
                      range: SupportReportQuranRange(
                        startSurah: 2,
                        startAyah: 1,
                        endSurah: 2,
                        endAyah: 5,
                      ),
                    ),
                  ]
                : const <WeeklySupportReportRecitationProjection>[],
          ),
        ],
      ),
  ];

  final projection = WeeklySupportReportProjection(
    period: period,
    header: const SupportReportHeaderSnapshot(
      teacherName: 'المعلم',
      halaqahName: 'حلقة النور',
      organizationName: 'الجهة',
      policyVersion: 1,
      templateVersion: 1,
    ),
    students: const <WeeklySupportReportStudentProjection>[
      WeeklySupportReportStudentProjection(
        sourceStudentId: studentId,
        studentName: 'أحمد',
        displayOrder: 1,
        dailyPlanText: 'وجه يوميًا',
      ),
    ],
    days: days,
    missingItems: <ReportMissingItem>[
      const ReportMissingItem(
        studentId: studentId,
        studentName: 'أحمد',
        field: ReportMissingField.supportStudentNumber,
      ),
      const ReportMissingItem(
        studentId: studentId,
        studentName: 'أحمد',
        field: ReportMissingField.currentJuz,
      ),
      ReportMissingItem(
        studentId: studentId,
        studentName: 'أحمد',
        field: ReportMissingField.attendanceStatus,
        localDate: DateTime(2026, 9, 14),
      ),
    ],
  );

  final source = WeeklySupportReportSource(
    period: period,
    halaqah: const SupportReportHalaqahSource(
      id: 1,
      teacherName: 'المعلم',
      halaqahName: 'حلقة النور',
      centerName: 'المركز',
    ),
    supportPeriods: <SupportReportSupportPeriodSource>[
      SupportReportSupportPeriodSource(
        id: 1,
        organizationName: 'الجهة',
        startedAtUtc: DateTime.utc(2026, 9, 1),
        endedAtUtc: null,
      ),
    ],
    students: <SupportReportStudentSource>[
      SupportReportStudentSource(
        id: studentId,
        studentName: 'أحمد',
        supportStudentNumber: null,
        note: null,
        displayOrder: 1,
        currentJuz: null,
        dailyPlanText: 'وجه يوميًا',
        activityPeriods: const <SupportReportStudentActivityPeriodSource>[
          SupportReportStudentActivityPeriodSource(
            id: 1,
            activeFromDate: '2026-09-01',
            activeToDate: null,
          ),
        ],
      ),
    ],
    days: const <SupportReportDaySource>[
      SupportReportDaySource(id: 44, dayDate: '2026-09-14', status: 'open'),
    ],
    attendance: const <SupportReportAttendanceSource>[],
    newMemorization: const <SupportReportNewMemorizationSource>[],
  );

  return WeeklySupportReportReview(
    source: source,
    candidate: WeeklySupportReportApprovalCandidate(
      projection: projection,
      sourceFingerprint: 'live-fingerprint',
      warningsConfirmed: false,
    ),
    comparison: const WeeklySupportReportSnapshotComparison(
      freshness: WeeklySupportReportSnapshotFreshness.stale,
      currentSourceFingerprint: 'live-fingerprint',
    ),
  );
}
