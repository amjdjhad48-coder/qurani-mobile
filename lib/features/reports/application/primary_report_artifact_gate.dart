enum SupportReportArtifactKind { weekly, monthly }

final class PrimaryReportArtifactRequest {
  const PrimaryReportArtifactRequest({
    required this.kind,
    required this.sourceFingerprint,
    required this.policyVersion,
    required this.templateVersion,
  });

  final SupportReportArtifactKind kind;
  final String sourceFingerprint;
  final int policyVersion;
  final int templateVersion;
}

enum PrimaryReportArtifactGateStatus { satisfied, unavailable, rejected }

final class PrimaryReportArtifactGateResult {
  const PrimaryReportArtifactGateResult.satisfied({
    required String artifactHash,
  }) : this._(
         status: PrimaryReportArtifactGateStatus.satisfied,
         artifactHash: artifactHash,
       );

  const PrimaryReportArtifactGateResult.unavailable({required String reason})
    : this._(
        status: PrimaryReportArtifactGateStatus.unavailable,
        reason: reason,
      );

  const PrimaryReportArtifactGateResult.rejected({required String reason})
    : this._(status: PrimaryReportArtifactGateStatus.rejected, reason: reason);

  const PrimaryReportArtifactGateResult._({
    required this.status,
    this.artifactHash,
    this.reason,
  });

  final PrimaryReportArtifactGateStatus status;
  final String? artifactHash;
  final String? reason;

  bool get isSatisfied {
    final hash = artifactHash?.trim();

    return status == PrimaryReportArtifactGateStatus.satisfied &&
        hash != null &&
        hash.isNotEmpty;
  }
}

abstract interface class PrimaryReportArtifactGate {
  Future<PrimaryReportArtifactGateResult> verify(
    PrimaryReportArtifactRequest request,
  );
}

/// Production Package 7 gate.
///
/// Package 8 replaces this with the verified Excel-artifact gate.
/// This is deliberately not a test fake.
final class Package7PrimaryReportArtifactGate
    implements PrimaryReportArtifactGate {
  const Package7PrimaryReportArtifactGate();

  @override
  Future<PrimaryReportArtifactGateResult> verify(
    PrimaryReportArtifactRequest request,
  ) async {
    return const PrimaryReportArtifactGateResult.unavailable(
      reason:
          'Primary verified Excel artifact is not available before Package 8.',
    );
  }
}
