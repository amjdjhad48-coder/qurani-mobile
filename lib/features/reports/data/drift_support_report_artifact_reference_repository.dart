import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/application/package8_support_report_artifact_lifecycle.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

final class DriftSupportReportArtifactReferenceRepository
    implements SupportReportArtifactReferenceRepository {
  const DriftSupportReportArtifactReferenceRepository(this._database);

  final AppDatabase _database;

  @override
  Future<SupportReportExportArtifactMetadata?> findWeeklyPrimaryArtifact({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }

    final report =
        await (_database.select(_database.supportWeeklyReports)..where(
              (table) =>
                  table.halaqahId.equals(halaqahId) &
                  table.weekStartDate.equals(_dateText(period.weekStart)),
            ))
            .getSingleOrNull();

    if (report == null) {
      return null;
    }

    final artifact =
        await (_database.select(_database.reportExportArtifacts)..where(
              (table) =>
                  table.weeklyReportId.equals(report.id) &
                  table.format.equals(
                    SupportReportExportFormat.excel.storageValue,
                  ),
            ))
            .getSingleOrNull();

    if (artifact == null) {
      return null;
    }

    return SupportReportExportArtifactMetadata(
      format: SupportReportExportFormat.excel,
      internalPath: artifact.internalPath,
      sha256: artifact.sha256,
      templateVersion: artifact.templateVersion,
      sizeBytes: artifact.sizeBytes,
    );
  }

  @override
  Future<SupportReportExportArtifactMetadata?> findMonthlyPrimaryArtifact({
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

    final report =
        await (_database.select(_database.supportMonthlyReports)..where(
              (table) =>
                  table.halaqahId.equals(halaqahId) &
                  table.monthStartDate.equals(_dateText(period.monthStart)),
            ))
            .getSingleOrNull();

    if (report == null) {
      return null;
    }

    final artifact =
        await (_database.select(_database.reportExportArtifacts)..where(
              (table) =>
                  table.monthlyReportId.equals(report.id) &
                  table.format.equals(
                    SupportReportExportFormat.excel.storageValue,
                  ),
            ))
            .getSingleOrNull();

    if (artifact == null) {
      return null;
    }

    return SupportReportExportArtifactMetadata(
      format: SupportReportExportFormat.excel,
      internalPath: artifact.internalPath,
      sha256: artifact.sha256,
      templateVersion: artifact.templateVersion,
      sizeBytes: artifact.sizeBytes,
    );
  }

  @override
  Future<bool> isInternalPathReferenced(String internalPath) async {
    final normalized = internalPath.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        internalPath,
        'internalPath',
        'Artifact internal path must not be empty.',
      );
    }

    final row =
        await (_database.select(_database.reportExportArtifacts)
              ..where((table) => table.internalPath.equals(normalized))
              ..limit(1))
            .getSingleOrNull();

    return row != null;
  }

  @override
  Future<Set<String>> referencedInternalPaths() async {
    final rows = await _database.select(_database.reportExportArtifacts).get();

    return <String>{for (final row in rows) row.internalPath};
  }
}

String _dateText(DateTime value) {
  final normalized = SupportReportPolicy.dateOnly(value);

  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}
