import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';

enum SupportReportStudentExportFormat { excel, pdf }

enum SupportReportStudentExportAction { open, save, share }

enum SupportReportStudentExportOutcome { completed, cancelled }

final class StudentExportProjection {
  StudentExportProjection.weekly({
    required this.sourceStudentId,
    required this.studentName,
    required ApprovedWeeklySupportReportSnapshot snapshot,
  }) : kind = SupportReportArtifactKind.weekly,
       weeklySnapshot = snapshot,
       monthlySnapshot = null;

  StudentExportProjection.monthly({
    required this.sourceStudentId,
    required this.studentName,
    required ApprovedMonthlySupportReportSnapshot snapshot,
  }) : kind = SupportReportArtifactKind.monthly,
       weeklySnapshot = null,
       monthlySnapshot = snapshot;

  final SupportReportArtifactKind kind;
  final int sourceStudentId;
  final String studentName;
  final ApprovedWeeklySupportReportSnapshot? weeklySnapshot;
  final ApprovedMonthlySupportReportSnapshot? monthlySnapshot;

  String get sourceFingerprint =>
      weeklySnapshot?.sourceFingerprint ?? monthlySnapshot!.sourceFingerprint;

  int get templateVersion =>
      weeklySnapshot?.header.templateVersion ??
      monthlySnapshot!.header.templateVersion;
}

final class SupportReportStudentGeneratedArtifact {
  SupportReportStudentGeneratedArtifact({
    required this.format,
    required this.kind,
    required this.sourceFingerprint,
    required this.templateVersion,
    required String sha256,
    required List<int> bytes,
  }) : sha256 = sha256.trim().toLowerCase(),
       bytes = List<int>.unmodifiable(bytes);

  final SupportReportStudentExportFormat format;
  final SupportReportArtifactKind kind;
  final String sourceFingerprint;
  final int templateVersion;
  final String sha256;
  final List<int> bytes;
}

abstract interface class SupportReportStudentExportGenerator {
  Future<SupportReportStudentGeneratedArtifact> generate(
    StudentExportProjection projection,
  );
}

abstract interface class SupportReportStudentExportExternalActions {
  Future<void> open({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  });

  Future<SupportReportStudentExportOutcome> save({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  });

  Future<void> share({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  });
}

abstract interface class SupportReportStudentExportService {
  Future<SupportReportStudentExportOutcome> exportStudent({
    required SupportReportHistoryDetail detail,
    required int sourceStudentId,
    required SupportReportStudentExportFormat format,
    required SupportReportStudentExportAction action,
  });
}

final class SupportReportStudentExportProjectionBuilder {
  const SupportReportStudentExportProjectionBuilder();

  StudentExportProjection build({
    required SupportReportHistoryDetail detail,
    required int sourceStudentId,
  }) {
    if (sourceStudentId <= 0) {
      throw ArgumentError.value(
        sourceStudentId,
        'sourceStudentId',
        'Student id must be positive.',
      );
    }

    final weekly = detail.weeklySnapshot;
    final monthly = detail.monthlySnapshot;

    if ((weekly == null) == (monthly == null)) {
      throw StateError(
        'Approved history detail must expose exactly one immutable snapshot.',
      );
    }

    if (weekly != null) {
      if (detail.item.kind != SupportReportHistoryKind.weekly) {
        throw StateError(
          'Weekly student export requires a weekly approved history item.',
        );
      }

      final students = weekly.students
          .where((student) => student.sourceStudentId == sourceStudentId)
          .toList(growable: false);

      if (students.length != 1) {
        throw StateError(
          'Selected student was not found exactly once in the approved weekly snapshot.',
        );
      }

      final filtered = ApprovedWeeklySupportReportSnapshot(
        reportId: weekly.reportId,
        halaqahId: weekly.halaqahId,
        period: weekly.period,
        header: weekly.header,
        sourceFingerprint: weekly.sourceFingerprint,
        approvedAtUtc: weekly.approvedAtUtc,
        students: students,
        days: weekly.days.map(
          (day) => ApprovedWeeklySupportReportDaySnapshot(
            snapshotRowId: day.snapshotRowId,
            localDate: day.localDate,
            dayKind: day.dayKind,
            entries: day.entries.where(
              (entry) => entry.sourceStudentId == sourceStudentId,
            ),
          ),
        ),
      );

      return StudentExportProjection.weekly(
        sourceStudentId: sourceStudentId,
        studentName: students.single.studentName,
        snapshot: filtered,
      );
    }

    if (detail.item.kind != SupportReportHistoryKind.monthly) {
      throw StateError(
        'Monthly student export requires a monthly approved history item.',
      );
    }

    final snapshot = monthly!;
    final students = snapshot.students
        .where((student) => student.sourceStudentId == sourceStudentId)
        .toList(growable: false);

    if (students.length != 1) {
      throw StateError(
        'Selected student was not found exactly once in the approved monthly snapshot.',
      );
    }

    final filtered = ApprovedMonthlySupportReportSnapshot(
      reportId: snapshot.reportId,
      halaqahId: snapshot.halaqahId,
      period: snapshot.period,
      header: snapshot.header,
      sourceFingerprint: snapshot.sourceFingerprint,
      approvedAtUtc: snapshot.approvedAtUtc,
      students: students,
      days: snapshot.days.map(
        (day) => ApprovedMonthlySupportReportDaySnapshot(
          snapshotRowId: day.snapshotRowId,
          sourceWeeklyReportId: day.sourceWeeklyReportId,
          localDate: day.localDate,
          dayKind: day.dayKind,
          entries: day.entries.where(
            (entry) => entry.sourceStudentId == sourceStudentId,
          ),
        ),
      ),
    );

    return StudentExportProjection.monthly(
      sourceStudentId: sourceStudentId,
      studentName: students.single.studentName,
      snapshot: filtered,
    );
  }
}

final class Package8SupportReportStudentExportService
    implements SupportReportStudentExportService {
  const Package8SupportReportStudentExportService({
    required this.excelGenerator,
    required this.pdfGenerator,
    required this.externalActions,
    this.projectionBuilder =
        const SupportReportStudentExportProjectionBuilder(),
  });

  final SupportReportStudentExportGenerator excelGenerator;
  final SupportReportStudentExportGenerator pdfGenerator;
  final SupportReportStudentExportExternalActions externalActions;
  final SupportReportStudentExportProjectionBuilder projectionBuilder;

  @override
  Future<SupportReportStudentExportOutcome> exportStudent({
    required SupportReportHistoryDetail detail,
    required int sourceStudentId,
    required SupportReportStudentExportFormat format,
    required SupportReportStudentExportAction action,
  }) async {
    final projection = projectionBuilder.build(
      detail: detail,
      sourceStudentId: sourceStudentId,
    );

    if (projection.sourceFingerprint != detail.item.sourceFingerprint ||
        projection.templateVersion != detail.item.header.templateVersion) {
      throw StateError(
        'Student export projection identity does not match approved history.',
      );
    }

    final generator = switch (format) {
      SupportReportStudentExportFormat.excel => excelGenerator,
      SupportReportStudentExportFormat.pdf => pdfGenerator,
    };

    final artifact = await generator.generate(projection);

    _verifyGeneratedArtifact(
      artifact: artifact,
      projection: projection,
      expectedFormat: format,
    );

    final fileName = _suggestedName(
      detail: detail,
      projection: projection,
      format: format,
    );

    return switch (action) {
      SupportReportStudentExportAction.open => _open(
        artifact: artifact,
        fileName: fileName,
      ),
      SupportReportStudentExportAction.save => externalActions.save(
        artifact: artifact,
        fileName: fileName,
      ),
      SupportReportStudentExportAction.share => _share(
        artifact: artifact,
        fileName: fileName,
      ),
    };
  }

  Future<SupportReportStudentExportOutcome> _open({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  }) async {
    await externalActions.open(artifact: artifact, fileName: fileName);
    return SupportReportStudentExportOutcome.completed;
  }

  Future<SupportReportStudentExportOutcome> _share({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  }) async {
    await externalActions.share(artifact: artifact, fileName: fileName);
    return SupportReportStudentExportOutcome.completed;
  }

  void _verifyGeneratedArtifact({
    required SupportReportStudentGeneratedArtifact artifact,
    required StudentExportProjection projection,
    required SupportReportStudentExportFormat expectedFormat,
  }) {
    if (artifact.format != expectedFormat ||
        artifact.kind != projection.kind ||
        artifact.sourceFingerprint != projection.sourceFingerprint ||
        artifact.templateVersion != projection.templateVersion) {
      throw StateError(
        'Generated student export identity does not match its approved projection.',
      );
    }

    if (artifact.bytes.isEmpty) {
      throw StateError('Generated student export bytes are empty.');
    }

    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(artifact.sha256)) {
      throw StateError('Generated student export exposes an invalid SHA-256.');
    }
  }

  String _suggestedName({
    required SupportReportHistoryDetail detail,
    required StudentExportProjection projection,
    required SupportReportStudentExportFormat format,
  }) {
    final kind = switch (projection.kind) {
      SupportReportArtifactKind.weekly => 'weekly',
      SupportReportArtifactKind.monthly => 'monthly',
    };
    final extension = switch (format) {
      SupportReportStudentExportFormat.excel => 'xlsx',
      SupportReportStudentExportFormat.pdf => 'pdf',
    };

    return 'qurani_${kind}_student_${projection.sourceStudentId}_'
        '${_date(detail.item.periodStart)}_${_date(detail.item.periodEnd)}.'
        '$extension';
  }

  String _date(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
