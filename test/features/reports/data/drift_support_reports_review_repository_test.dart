import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/data/drift_support_reports_review_repository.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';

void main() {
  test(
    'review repository returns approved weekly and monthly history only',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      try {
        final now = DateTime.utc(2026, 9, 16, 12);
        final halaqahId = await database
            .into(database.halaqahs)
            .insert(
              HalaqahsCompanion.insert(
                teacherName: 'المعلم',
                halaqahName: 'حلقة النور',
                centerName: 'المركز',
                createdAtUtc: now,
                updatedAtUtc: now,
              ),
            );
        await database
            .into(database.supportWeeklyReports)
            .insert(
              SupportWeeklyReportsCompanion.insert(
                halaqahId: halaqahId,
                weekStartDate: '2026-09-12',
                weekEndDate: '2026-09-16',
                status: 'approved',
                teacherNameSnapshot: 'المعلم',
                halaqahNameSnapshot: 'حلقة النور',
                organizationNameSnapshot: 'الجهة',
                policyVersion: 1,
                templateVersion: 1,
                sourceFingerprint: const Value<String?>('weekly-fingerprint'),
                approvedAtUtc: Value<DateTime?>(DateTime.utc(2026, 9, 16, 18)),
              ),
            );
        await database
            .into(database.supportMonthlyReports)
            .insert(
              SupportMonthlyReportsCompanion.insert(
                halaqahId: halaqahId,
                monthStartDate: '2026-08-01',
                monthEndDate: '2026-08-31',
                status: 'approved',
                teacherNameSnapshot: 'المعلم',
                halaqahNameSnapshot: 'حلقة النور',
                organizationNameSnapshot: 'الجهة',
                policyVersion: 1,
                templateVersion: 1,
                sourceFingerprint: const Value<String?>('monthly-fingerprint'),
                approvedAtUtc: Value<DateTime?>(DateTime.utc(2026, 9, 1, 8)),
              ),
            );
        await database
            .into(database.supportWeeklyReports)
            .insert(
              SupportWeeklyReportsCompanion.insert(
                halaqahId: halaqahId,
                weekStartDate: '2026-09-05',
                weekEndDate: '2026-09-09',
                status: 'draft',
                teacherNameSnapshot: 'المعلم',
                halaqahNameSnapshot: 'حلقة النور',
                organizationNameSnapshot: 'الجهة',
                policyVersion: 1,
                templateVersion: 1,
              ),
            );
        final history = await DriftSupportReportsReviewRepository(
          database,
        ).listApproved(halaqahId: halaqahId);
        expect(history, hasLength(2));
        expect(history[0].kind, SupportReportHistoryKind.weekly);
        expect(history[0].periodStart, DateTime(2026, 9, 12));
        expect(history[0].sourceFingerprint, 'weekly-fingerprint');
        expect(history[0].header.organizationName, 'الجهة');
        expect(history[1].kind, SupportReportHistoryKind.monthly);
        expect(history[1].periodStart, DateTime(2026, 8, 1));
        expect(history[1].sourceFingerprint, 'monthly-fingerprint');
      } finally {
        await database.close();
      }
    },
  );
}
