import 'package:qurani/features/reports/application/package8_support_report_artifact_lifecycle.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';

abstract interface class SupportReportApprovedArtifactBytesReader {
  Future<List<int>> readVerified({
    required SupportReportExportArtifactMetadata artifact,
    required SupportReportArtifactKind kind,
    required String sourceFingerprint,
    required int policyVersion,
  });
}

abstract interface class SupportReportArtifactExternalOpener {
  Future<void> openExcel({required List<int> bytes, required String sha256});
}

abstract interface class SupportReportApprovedArtifactOpenService {
  Future<void> openApprovedExcel({
    required int halaqahId,
    required SupportReportHistoryItem item,
  });
}

final class Package8SupportReportApprovedArtifactOpenService
    implements SupportReportApprovedArtifactOpenService {
  const Package8SupportReportApprovedArtifactOpenService({
    required this.artifactLifecycle,
    required this.bytesReader,
    required this.externalOpener,
  });

  final SupportReportApprovalArtifactLifecycle artifactLifecycle;
  final SupportReportApprovedArtifactBytesReader bytesReader;
  final SupportReportArtifactExternalOpener externalOpener;

  @override
  Future<void> openApprovedExcel({
    required int halaqahId,
    required SupportReportHistoryItem item,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }

    final resolved = await _resolveArtifact(halaqahId: halaqahId, item: item);

    final artifact = resolved.artifact;

    if (artifact == null) {
      throw StateError(
        'Approved report does not have a primary Excel artifact.',
      );
    }

    if (artifact.format != SupportReportExportFormat.excel) {
      throw StateError('Approved primary report artifact is not Excel.');
    }

    if (artifact.templateVersion != item.header.templateVersion) {
      throw StateError(
        'Approved Excel artifact template version does not match history.',
      );
    }

    final bytes = await bytesReader.readVerified(
      artifact: artifact,
      kind: resolved.kind,
      sourceFingerprint: item.sourceFingerprint,
      policyVersion: item.header.policyVersion,
    );

    if (bytes.length != artifact.sizeBytes) {
      throw StateError(
        'Verified approved Excel bytes do not match artifact metadata size.',
      );
    }

    await externalOpener.openExcel(bytes: bytes, sha256: artifact.sha256);
  }

  Future<_ResolvedApprovedArtifact> _resolveArtifact({
    required int halaqahId,
    required SupportReportHistoryItem item,
  }) async {
    return switch (item.kind) {
      SupportReportHistoryKind.weekly => _resolveWeekly(
        halaqahId: halaqahId,
        item: item,
      ),
      SupportReportHistoryKind.monthly => _resolveMonthly(
        halaqahId: halaqahId,
        item: item,
      ),
    };
  }

  Future<_ResolvedApprovedArtifact> _resolveWeekly({
    required int halaqahId,
    required SupportReportHistoryItem item,
  }) async {
    final period = WeeklySupportReportPeriod.forDate(item.periodStart);

    if (period.weekStart != item.periodStart ||
        period.weekEnd != item.periodEnd) {
      throw StateError(
        'Weekly history period does not match the approved artifact request.',
      );
    }

    return _ResolvedApprovedArtifact(
      kind: SupportReportArtifactKind.weekly,
      artifact: await artifactLifecycle.currentWeeklyPrimaryArtifact(
        halaqahId: halaqahId,
        period: period,
      ),
    );
  }

  Future<_ResolvedApprovedArtifact> _resolveMonthly({
    required int halaqahId,
    required SupportReportHistoryItem item,
  }) async {
    final period = MonthlySupportReportPeriod.forDate(item.periodStart);

    if (period.monthStart != item.periodStart ||
        period.monthEnd != item.periodEnd) {
      throw StateError(
        'Monthly history period does not match the approved artifact request.',
      );
    }

    return _ResolvedApprovedArtifact(
      kind: SupportReportArtifactKind.monthly,
      artifact: await artifactLifecycle.currentMonthlyPrimaryArtifact(
        halaqahId: halaqahId,
        period: period,
      ),
    );
  }
}

final class _ResolvedApprovedArtifact {
  const _ResolvedApprovedArtifact({required this.kind, required this.artifact});

  final SupportReportArtifactKind kind;
  final SupportReportExportArtifactMetadata? artifact;
}
