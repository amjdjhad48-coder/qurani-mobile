import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class PreparedPrimaryReportArtifact {
  PreparedPrimaryReportArtifact({
    required this.kind,
    required String sourceFingerprint,
    required this.policyVersion,
    required this.templateVersion,
    required String internalPath,
    required String sha256,
    required this.sizeBytes,
  }) : sourceFingerprint = sourceFingerprint.trim(),
       internalPath = internalPath.trim(),
       sha256 = sha256.trim().toLowerCase() {
    if (this.sourceFingerprint.isEmpty) {
      throw ArgumentError.value(
        sourceFingerprint,
        'sourceFingerprint',
        'Prepared artifact source fingerprint must not be empty.',
      );
    }

    if (policyVersion <= 0) {
      throw ArgumentError.value(
        policyVersion,
        'policyVersion',
        'Prepared artifact policy version must be positive.',
      );
    }

    if (templateVersion <= 0) {
      throw ArgumentError.value(
        templateVersion,
        'templateVersion',
        'Prepared artifact template version must be positive.',
      );
    }

    if (this.internalPath.isEmpty) {
      throw ArgumentError.value(
        internalPath,
        'internalPath',
        'Prepared artifact internal path must not be empty.',
      );
    }

    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(this.sha256)) {
      throw ArgumentError.value(
        sha256,
        'sha256',
        'Prepared artifact hash must be a 64-character SHA-256 hex value.',
      );
    }

    if (sizeBytes <= 0) {
      throw ArgumentError.value(
        sizeBytes,
        'sizeBytes',
        'Prepared artifact size must be positive.',
      );
    }
  }

  final SupportReportArtifactKind kind;
  final String sourceFingerprint;
  final int policyVersion;
  final int templateVersion;
  final String internalPath;
  final String sha256;
  final int sizeBytes;
}

final class PreparedPrimaryReportArtifactVerification {
  const PreparedPrimaryReportArtifactVerification.valid()
    : isValid = true,
      reason = null;

  const PreparedPrimaryReportArtifactVerification.invalid({
    required this.reason,
  }) : isValid = false;

  final bool isValid;
  final String? reason;
}

abstract interface class PreparedPrimaryReportArtifactVerifier {
  Future<PreparedPrimaryReportArtifactVerification> verifyPrepared(
    PreparedPrimaryReportArtifact artifact,
  );
}

abstract interface class PrimaryReportArtifactPreparer {
  Future<PreparedPrimaryReportArtifact> prepareWeekly({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
  });

  Future<PreparedPrimaryReportArtifact> prepareMonthly({
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
  });
}

final class Package8PrimaryReportArtifactGate
    implements PrimaryReportArtifactGate {
  const Package8PrimaryReportArtifactGate({
    required this.preparedArtifact,
    required this.verifier,
  });

  final PreparedPrimaryReportArtifact preparedArtifact;
  final PreparedPrimaryReportArtifactVerifier verifier;

  @override
  Future<PrimaryReportArtifactGateResult> verify(
    PrimaryReportArtifactRequest request,
  ) async {
    if (request.kind != preparedArtifact.kind) {
      return const PrimaryReportArtifactGateResult.rejected(
        reason: 'Prepared Excel artifact kind does not match approval request.',
      );
    }

    if (request.sourceFingerprint.trim() !=
        preparedArtifact.sourceFingerprint) {
      return const PrimaryReportArtifactGateResult.rejected(
        reason:
            'Prepared Excel artifact source fingerprint does not match approval request.',
      );
    }

    if (request.policyVersion != preparedArtifact.policyVersion) {
      return const PrimaryReportArtifactGateResult.rejected(
        reason:
            'Prepared Excel artifact policy version does not match approval request.',
      );
    }

    if (request.templateVersion != preparedArtifact.templateVersion) {
      return const PrimaryReportArtifactGateResult.rejected(
        reason:
            'Prepared Excel artifact template version does not match approval request.',
      );
    }

    final verification = await verifier.verifyPrepared(preparedArtifact);

    if (!verification.isValid) {
      return PrimaryReportArtifactGateResult.rejected(
        reason:
            verification.reason ??
            'Prepared Excel artifact failed file-integrity verification.',
      );
    }

    return PrimaryReportArtifactGateResult.satisfied(
      artifactHash: preparedArtifact.sha256,
    );
  }
}
