import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';

void main() {
  group('Package8PrimaryReportArtifactGate', () {
    test(
      'satisfies only a matching request backed by verified bytes',
      () async {
        final artifact = _artifact();
        const verifier = _FakePreparedVerifier(valid: true);
        final gate = Package8PrimaryReportArtifactGate(
          preparedArtifact: artifact,
          verifier: verifier,
        );

        final result = await gate.verify(_request());

        expect(result.status, PrimaryReportArtifactGateStatus.satisfied);
        expect(result.artifactHash, artifact.sha256);
        expect(result.isSatisfied, isTrue);
      },
    );

    test(
      'rejects source fingerprint mismatch before file verification',
      () async {
        final verifier = _CountingPreparedVerifier();
        final gate = Package8PrimaryReportArtifactGate(
          preparedArtifact: _artifact(),
          verifier: verifier,
        );

        final result = await gate.verify(
          _request(sourceFingerprint: 'changed-source'),
        );

        expect(result.status, PrimaryReportArtifactGateStatus.rejected);
        expect(result.isSatisfied, isFalse);
        expect(verifier.calls, 0);
      },
    );

    test('rejects kind, policy and template mismatches', () async {
      for (final request in <PrimaryReportArtifactRequest>[
        _request(kind: SupportReportArtifactKind.monthly),
        _request(policyVersion: 2),
        _request(templateVersion: 2),
      ]) {
        final gate = Package8PrimaryReportArtifactGate(
          preparedArtifact: _artifact(),
          verifier: const _FakePreparedVerifier(valid: true),
        );

        final result = await gate.verify(request);

        expect(result.status, PrimaryReportArtifactGateStatus.rejected);
        expect(result.isSatisfied, isFalse);
      }
    });

    test(
      'rejects a matching request when staged bytes fail integrity',
      () async {
        final gate = Package8PrimaryReportArtifactGate(
          preparedArtifact: _artifact(),
          verifier: const _FakePreparedVerifier(
            valid: false,
            reason: 'tampered',
          ),
        );

        final result = await gate.verify(_request());

        expect(result.status, PrimaryReportArtifactGateStatus.rejected);
        expect(result.reason, 'tampered');
        expect(result.isSatisfied, isFalse);
      },
    );
  });
}

PreparedPrimaryReportArtifact _artifact() {
  return PreparedPrimaryReportArtifact(
    kind: SupportReportArtifactKind.weekly,
    sourceFingerprint: 'source-fingerprint',
    policyVersion: 1,
    templateVersion: 1,
    internalPath:
        'report_artifacts/'
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.xlsx',
    sha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    sizeBytes: 1024,
  );
}

PrimaryReportArtifactRequest _request({
  SupportReportArtifactKind kind = SupportReportArtifactKind.weekly,
  String sourceFingerprint = 'source-fingerprint',
  int policyVersion = 1,
  int templateVersion = 1,
}) {
  return PrimaryReportArtifactRequest(
    kind: kind,
    sourceFingerprint: sourceFingerprint,
    policyVersion: policyVersion,
    templateVersion: templateVersion,
  );
}

final class _FakePreparedVerifier
    implements PreparedPrimaryReportArtifactVerifier {
  const _FakePreparedVerifier({required this.valid, this.reason});

  final bool valid;
  final String? reason;

  @override
  Future<PreparedPrimaryReportArtifactVerification> verifyPrepared(
    PreparedPrimaryReportArtifact artifact,
  ) async {
    if (valid) {
      return const PreparedPrimaryReportArtifactVerification.valid();
    }

    return PreparedPrimaryReportArtifactVerification.invalid(
      reason: reason ?? 'invalid',
    );
  }
}

final class _CountingPreparedVerifier
    implements PreparedPrimaryReportArtifactVerifier {
  int calls = 0;

  @override
  Future<PreparedPrimaryReportArtifactVerification> verifyPrepared(
    PreparedPrimaryReportArtifact artifact,
  ) async {
    calls += 1;
    return const PreparedPrimaryReportArtifactVerification.valid();
  }
}
