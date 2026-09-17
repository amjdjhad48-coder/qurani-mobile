import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';

final class DriftSupportReportsReviewRepository
    implements SupportReportsReviewRepository {
  const DriftSupportReportsReviewRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<SupportReportHistoryItem>> listApproved({
    required int halaqahId,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }
    final weeklyRows =
        await (_database.select(_database.supportWeeklyReports)..where(
              (table) =>
                  table.halaqahId.equals(halaqahId) &
                  table.status.equals('approved'),
            ))
            .get();
    final monthlyRows =
        await (_database.select(_database.supportMonthlyReports)..where(
              (table) =>
                  table.halaqahId.equals(halaqahId) &
                  table.status.equals('approved'),
            ))
            .get();

    final items = <SupportReportHistoryItem>[
      for (final row in weeklyRows)
        SupportReportHistoryItem(
          reportId: row.id,
          kind: SupportReportHistoryKind.weekly,
          periodStart: _parseLocalDate(row.weekStartDate),
          periodEnd: _parseLocalDate(row.weekEndDate),
          header: SupportReportHeaderSnapshot(
            teacherName: row.teacherNameSnapshot,
            halaqahName: row.halaqahNameSnapshot,
            organizationName: row.organizationNameSnapshot,
            policyVersion: row.policyVersion,
            templateVersion: row.templateVersion,
          ),
          sourceFingerprint: _requiredFingerprint(
            row.sourceFingerprint,
            kind: 'weekly',
            reportId: row.id,
          ),
          approvedAtUtc: _requiredApprovedAtUtc(
            row.approvedAtUtc,
            kind: 'weekly',
            reportId: row.id,
          ),
        ),
      for (final row in monthlyRows)
        SupportReportHistoryItem(
          reportId: row.id,
          kind: SupportReportHistoryKind.monthly,
          periodStart: _parseLocalDate(row.monthStartDate),
          periodEnd: _parseLocalDate(row.monthEndDate),
          header: SupportReportHeaderSnapshot(
            teacherName: row.teacherNameSnapshot,
            halaqahName: row.halaqahNameSnapshot,
            organizationName: row.organizationNameSnapshot,
            policyVersion: row.policyVersion,
            templateVersion: row.templateVersion,
          ),
          sourceFingerprint: _requiredFingerprint(
            row.sourceFingerprint,
            kind: 'monthly',
            reportId: row.id,
          ),
          approvedAtUtc: _requiredApprovedAtUtc(
            row.approvedAtUtc,
            kind: 'monthly',
            reportId: row.id,
          ),
        ),
    ];
    items.sort((left, right) {
      final periodCompare = right.periodStart.compareTo(left.periodStart);
      if (periodCompare != 0) {
        return periodCompare;
      }
      final approvedCompare = right.approvedAtUtc.compareTo(left.approvedAtUtc);
      if (approvedCompare != 0) {
        return approvedCompare;
      }
      return right.kind.index.compareTo(left.kind.index);
    });
    return List<SupportReportHistoryItem>.unmodifiable(items);
  }

  DateTime _parseLocalDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null || value.length != 10) {
      throw StateError('Invalid support report local date: $value');
    }
    return SupportReportPolicy.dateOnly(parsed);
  }

  String _requiredFingerprint(
    String? value, {
    required String kind,
    required int reportId,
  }) {
    if (value == null || value.trim().isEmpty) {
      throw StateError(
        'Approved $kind support report $reportId has no source fingerprint.',
      );
    }
    return value;
  }

  DateTime _requiredApprovedAtUtc(
    DateTime? value, {
    required String kind,
    required int reportId,
  }) {
    if (value == null) {
      throw StateError(
        'Approved $kind support report $reportId has no approval timestamp.',
      );
    }
    return value.toUtc();
  }
}
