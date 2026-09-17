import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/data/drift_weekly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

final class DriftApprovedWeeklySupportReportsForMonthRepository
    implements ApprovedWeeklySupportReportsForMonthRepository {
  const DriftApprovedWeeklySupportReportsForMonthRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<ApprovedWeeklySupportReportSnapshot>>
  findApprovedIntersectingMonth({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }

    final reportRows =
        await (_database.select(_database.supportWeeklyReports)
              ..where(
                (table) =>
                    table.halaqahId.equals(halaqahId) &
                    table.status.equals('approved'),
              )
              ..orderBy([
                (table) => OrderingTerm.asc(table.weekStartDate),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    final monthStartText = _dateText(period.monthStart);
    final monthEndText = _dateText(period.monthEnd);

    final intersectingRows = reportRows
        .where(
          (row) =>
              row.weekStartDate.compareTo(monthEndText) <= 0 &&
              row.weekEndDate.compareTo(monthStartText) >= 0,
        )
        .toList(growable: false);

    final weeklyRepository = DriftWeeklySupportReportSnapshotRepository(
      _database,
    );

    final snapshots = <ApprovedWeeklySupportReportSnapshot>[];

    for (final row in intersectingRows) {
      final snapshot = await weeklyRepository.findApproved(
        halaqahId: halaqahId,
        period: WeeklySupportReportPeriod.forDate(
          _parseLocalDate(row.weekStartDate),
        ),
      );

      if (snapshot == null) {
        throw StateError(
          'Approved weekly report ${row.id} disappeared while '
          'building monthly source.',
        );
      }

      snapshots.add(snapshot);
    }

    return List<ApprovedWeeklySupportReportSnapshot>.unmodifiable(snapshots);
  }
}

String _dateText(DateTime value) {
  final normalized = SupportReportPolicy.dateOnly(value);

  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}

DateTime _parseLocalDate(String value) {
  final parts = value.split('-');

  if (parts.length != 3) {
    throw StateError('Invalid weekly snapshot date: $value');
  }

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);

  if (year == null || month == null || day == null) {
    throw StateError('Invalid weekly snapshot date: $value');
  }

  return DateTime(year, month, day);
}
