import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_service.dart';
import 'package:qurani/features/reports/application/weekly_support_report_review.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  test(
    'weekly review loads live projection and comparison without snapshot write',
    () async {
      final sourceRepository = _SourceRepository();
      final snapshotRepository = _SnapshotRepository();

      final review = await WeeklySupportReportReviewService(
        sourceRepository: sourceRepository,
        snapshotRepository: snapshotRepository,
      ).load(halaqahId: 1, localDate: DateTime(2026, 9, 14));

      expect(review.projection.period.weekStart, DateTime(2026, 9, 12));

      expect(review.projection.period.weekEnd, DateTime(2026, 9, 16));

      expect(
        review.comparison.freshness,
        WeeklySupportReportSnapshotFreshness.noApprovedSnapshot,
      );

      expect(review.hasWarnings, isFalse);
      expect(review.isStale, isFalse);
      expect(snapshotRepository.replaceCount, 0);
      expect(sourceRepository.readCount, 1);
      expect(sourceRepository.lastPeriod?.weekStart, DateTime(2026, 9, 12));
    },
  );

  test('weekly review exposes source day id for correction routing', () async {
    final sourceRepository = _SourceRepository(includeSourceDay: true);

    final review = await WeeklySupportReportReviewService(
      sourceRepository: sourceRepository,
      snapshotRepository: _SnapshotRepository(),
    ).load(halaqahId: 1, localDate: DateTime(2026, 9, 14));

    expect(review.sourceDayIdFor(DateTime(2026, 9, 14)), 44);

    expect(review.sourceDayIdFor(DateTime(2026, 9, 15)), isNull);
  });
}

final class _SourceRepository implements SupportReportSourceRepository {
  _SourceRepository({this.includeSourceDay = false});

  final bool includeSourceDay;

  int readCount = 0;
  WeeklySupportReportPeriod? lastPeriod;

  @override
  Future<WeeklySupportReportSource> readWeeklySource({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    readCount += 1;
    lastPeriod = period;

    return WeeklySupportReportSource(
      period: period,
      halaqah: const SupportReportHalaqahSource(
        id: 1,
        teacherName: 'ط§ظ„ظ…ط¹ظ„ظ…',
        halaqahName: 'ط­ظ„ظ‚ط© ط§ظ„ظ†ظˆط±',
        centerName: 'ط§ظ„ظ…ط±ظƒط²',
      ),
      supportPeriods: <SupportReportSupportPeriodSource>[
        SupportReportSupportPeriodSource(
          id: 1,
          organizationName: 'ط§ظ„ط¬ظ‡ط©',
          startedAtUtc: DateTime.utc(2026, 9, 1),
          endedAtUtc: null,
        ),
      ],
      students: const <SupportReportStudentSource>[],
      days: includeSourceDay
          ? const <SupportReportDaySource>[
              SupportReportDaySource(
                id: 44,
                dayDate: '2026-09-14',
                status: 'open',
              ),
            ]
          : const <SupportReportDaySource>[],
      attendance: const <SupportReportAttendanceSource>[],
      newMemorization: const <SupportReportNewMemorizationSource>[],
    );
  }
}

final class _SnapshotRepository
    implements WeeklySupportReportSnapshotRepository {
  int replaceCount = 0;

  @override
  Future<ApprovedWeeklySupportReportSnapshot?> findApproved({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    return null;
  }

  @override
  Future<void> replaceApproved({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
  }) async {
    replaceCount += 1;
  }
}
