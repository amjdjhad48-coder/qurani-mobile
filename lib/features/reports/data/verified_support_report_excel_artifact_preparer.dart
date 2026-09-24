import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/data/support_report_artifact_file_store.dart';
import 'package:qurani/features/reports/data/verified_support_report_excel_generator.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class VerifiedSupportReportExcelArtifactPreparer
    implements PrimaryReportArtifactPreparer {
  const VerifiedSupportReportExcelArtifactPreparer({
    required this.fileStore,
    this.generator = const VerifiedSupportReportExcelGenerator(),
  });

  final SupportReportArtifactFileStore fileStore;
  final VerifiedSupportReportExcelGenerator generator;

  @override
  Future<PreparedPrimaryReportArtifact> prepareWeekly({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
  }) async {
    final excel = await generator.generateWeeklyCandidate(
      halaqahId: halaqahId,
      projection: projection,
      sourceFingerprint: sourceFingerprint,
    );

    final artifact = await fileStore.stageVerifiedExcel(
      excel: excel,
      policyVersion: projection.header.policyVersion,
    );

    final reopenedBytes = await fileStore.readVerifiedPreparedBytes(artifact);
    final semanticVerification = generator.verifyWeeklyCandidateBytes(
      bytes: reopenedBytes,
      halaqahId: halaqahId,
      projection: projection,
      sourceFingerprint: sourceFingerprint,
    );

    if (!semanticVerification.isValid) {
      throw StateError(
        'Staged weekly Excel failed close/reopen semantic verification: '
        '${semanticVerification.reason}',
      );
    }

    return artifact;
  }

  @override
  Future<PreparedPrimaryReportArtifact> prepareMonthly({
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
  }) async {
    final excel = await generator.generateMonthlyCandidate(
      projection: projection,
      sourceFingerprint: sourceFingerprint,
    );

    final artifact = await fileStore.stageVerifiedExcel(
      excel: excel,
      policyVersion: projection.header.policyVersion,
    );

    final reopenedBytes = await fileStore.readVerifiedPreparedBytes(artifact);
    final semanticVerification = generator.verifyMonthlyCandidateBytes(
      bytes: reopenedBytes,
      projection: projection,
      sourceFingerprint: sourceFingerprint,
    );

    if (!semanticVerification.isValid) {
      throw StateError(
        'Staged monthly Excel failed close/reopen semantic verification: '
        '${semanticVerification.reason}',
      );
    }

    return artifact;
  }
}
