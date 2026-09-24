import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/package8_support_report_artifact_lifecycle.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/support_report_artifact_open_service.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';

void main() {
  group('Package8SupportReportApprovedArtifactOpenService', () {
    test(
      'weekly open verifies DB artifact bytes before external launch',
      () async {
        final artifact = _artifact();
        final lifecycle = _FakeLifecycle(weeklyArtifact: artifact);
        final reader = _FakeReader(<int>[1, 2, 3]);
        final opener = _FakeOpener();
        final service = Package8SupportReportApprovedArtifactOpenService(
          artifactLifecycle: lifecycle,
          bytesReader: reader,
          externalOpener: opener,
        );
        final item = _weeklyItem();

        await service.openApprovedExcel(halaqahId: 7, item: item);

        expect(lifecycle.weeklyCalls, 1);
        expect(reader.calls, 1);
        expect(reader.lastKind, SupportReportArtifactKind.weekly);
        expect(reader.lastArtifact, same(artifact));
        expect(reader.lastSourceFingerprint, item.sourceFingerprint);
        expect(opener.calls, 1);
        expect(opener.lastBytes, <int>[1, 2, 3]);
        expect(opener.lastSha256, artifact.sha256);
      },
    );

    test('monthly open resolves the monthly primary artifact', () async {
      final artifact = _artifact();
      final lifecycle = _FakeLifecycle(monthlyArtifact: artifact);
      final reader = _FakeReader(<int>[1, 2, 3]);
      final opener = _FakeOpener();
      final service = Package8SupportReportApprovedArtifactOpenService(
        artifactLifecycle: lifecycle,
        bytesReader: reader,
        externalOpener: opener,
      );

      await service.openApprovedExcel(halaqahId: 7, item: _monthlyItem());

      expect(lifecycle.monthlyCalls, 1);
      expect(reader.lastKind, SupportReportArtifactKind.monthly);
      expect(opener.calls, 1);
    });

    test(
      'missing primary artifact fails before byte read or external launch',
      () async {
        final reader = _FakeReader(<int>[1, 2, 3]);
        final opener = _FakeOpener();
        final service = Package8SupportReportApprovedArtifactOpenService(
          artifactLifecycle: _FakeLifecycle(),
          bytesReader: reader,
          externalOpener: opener,
        );

        await expectLater(
          service.openApprovedExcel(halaqahId: 7, item: _weeklyItem()),
          throwsStateError,
        );

        expect(reader.calls, 0);
        expect(opener.calls, 0);
      },
    );

    test(
      'non-Excel primary metadata is rejected before external launch',
      () async {
        final reader = _FakeReader(<int>[1, 2, 3]);
        final opener = _FakeOpener();
        final service = Package8SupportReportApprovedArtifactOpenService(
          artifactLifecycle: _FakeLifecycle(
            weeklyArtifact: _artifact(format: SupportReportExportFormat.pdf),
          ),
          bytesReader: reader,
          externalOpener: opener,
        );

        await expectLater(
          service.openApprovedExcel(halaqahId: 7, item: _weeklyItem()),
          throwsStateError,
        );

        expect(reader.calls, 0);
        expect(opener.calls, 0);
      },
    );
  });
}

SupportReportHistoryItem _weeklyItem() {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));
  return SupportReportHistoryItem(
    reportId: 91,
    kind: SupportReportHistoryKind.weekly,
    periodStart: period.weekStart,
    periodEnd: period.weekEnd,
    header: _header,
    sourceFingerprint: 'weekly-source',
    approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
  );
}

SupportReportHistoryItem _monthlyItem() {
  final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 1));
  return SupportReportHistoryItem(
    reportId: 92,
    kind: SupportReportHistoryKind.monthly,
    periodStart: period.monthStart,
    periodEnd: period.monthEnd,
    header: _header,
    sourceFingerprint: 'monthly-source',
    approvedAtUtc: DateTime.utc(2026, 9, 30, 10),
  );
}

const _header = SupportReportHeaderSnapshot(
  teacherName: 'Teacher',
  halaqahName: 'Halaqah',
  organizationName: 'Center',
  reportContext: SupportReportContext.general,
  policyVersion: 1,
  templateVersion: 1,
);

SupportReportExportArtifactMetadata _artifact({
  SupportReportExportFormat format = SupportReportExportFormat.excel,
}) {
  return SupportReportExportArtifactMetadata(
    format: format,
    internalPath:
        'report_artifacts/'
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.xlsx',
    sha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    templateVersion: 1,
    sizeBytes: 3,
  );
}

final class _FakeLifecycle implements SupportReportApprovalArtifactLifecycle {
  _FakeLifecycle({this.weeklyArtifact, this.monthlyArtifact});

  final SupportReportExportArtifactMetadata? weeklyArtifact;
  final SupportReportExportArtifactMetadata? monthlyArtifact;
  var weeklyCalls = 0;
  var monthlyCalls = 0;

  @override
  Future<SupportReportExportArtifactMetadata?> currentWeeklyPrimaryArtifact({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    weeklyCalls += 1;
    return weeklyArtifact;
  }

  @override
  Future<SupportReportExportArtifactMetadata?> currentMonthlyPrimaryArtifact({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    monthlyCalls += 1;
    return monthlyArtifact;
  }

  @override
  Future<void> cleanupPreparedIfUnreferenced(
    PreparedPrimaryReportArtifact artifact,
  ) async {}

  @override
  Future<void> cleanupStoredIfUnreferenced(
    SupportReportExportArtifactMetadata artifact,
  ) async {}

  @override
  Future<int> cleanupOrphans() async => 0;
}

final class _FakeReader implements SupportReportApprovedArtifactBytesReader {
  _FakeReader(this.bytes);

  final List<int> bytes;
  var calls = 0;
  SupportReportArtifactKind? lastKind;
  SupportReportExportArtifactMetadata? lastArtifact;
  String? lastSourceFingerprint;

  @override
  Future<List<int>> readVerified({
    required SupportReportExportArtifactMetadata artifact,
    required SupportReportArtifactKind kind,
    required String sourceFingerprint,
    required int policyVersion,
  }) async {
    calls += 1;
    lastKind = kind;
    lastArtifact = artifact;
    lastSourceFingerprint = sourceFingerprint;
    return bytes;
  }
}

final class _FakeOpener implements SupportReportArtifactExternalOpener {
  var calls = 0;
  List<int>? lastBytes;
  String? lastSha256;

  @override
  Future<void> openExcel({
    required List<int> bytes,
    required String sha256,
  }) async {
    calls += 1;
    lastBytes = List<int>.from(bytes);
    lastSha256 = sha256;
  }
}
