import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/package8_support_report_artifact_lifecycle.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/support_report_artifact_open_service.dart';
import 'package:qurani/features/reports/application/support_report_artifact_share_service.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';

void main() {
  group('Package8SupportReportApprovedArtifactShareService', () {
    test(
      'weekly share verifies approved bytes before chooser launch',
      () async {
        final artifact = _artifact();
        final lifecycle = _FakeLifecycle(weeklyArtifact: artifact);
        final reader = _FakeReader(<int>[1, 2, 3]);
        final sharer = _FakeSharer();
        final service = Package8SupportReportApprovedArtifactShareService(
          artifactLifecycle: lifecycle,
          bytesReader: reader,
          externalSharer: sharer,
        );
        final item = _weeklyItem();

        await service.shareApprovedExcel(halaqahId: 7, item: item);

        expect(lifecycle.weeklyCalls, 1);
        expect(reader.calls, 1);
        expect(reader.lastKind, SupportReportArtifactKind.weekly);
        expect(reader.lastArtifact, same(artifact));
        expect(reader.lastSourceFingerprint, item.sourceFingerprint);
        expect(sharer.calls, 1);
        expect(sharer.lastBytes, <int>[1, 2, 3]);
        expect(sharer.lastSha256, artifact.sha256);
        expect(
          sharer.lastSuggestedName,
          'qurani_weekly_2026-09-12_2026-09-16.xlsx',
        );
      },
    );

    test('monthly share resolves the monthly approved artifact', () async {
      final artifact = _artifact();
      final lifecycle = _FakeLifecycle(monthlyArtifact: artifact);
      final sharer = _FakeSharer();
      final service = Package8SupportReportApprovedArtifactShareService(
        artifactLifecycle: lifecycle,
        bytesReader: _FakeReader(<int>[1, 2, 3]),
        externalSharer: sharer,
      );

      await service.shareApprovedExcel(halaqahId: 7, item: _monthlyItem());

      expect(lifecycle.monthlyCalls, 1);
      expect(
        sharer.lastSuggestedName,
        'qurani_monthly_2026-09-01_2026-09-30.xlsx',
      );
    });

    test('missing primary artifact fails before byte read or share', () async {
      final reader = _FakeReader(<int>[1, 2, 3]);
      final sharer = _FakeSharer();
      final service = Package8SupportReportApprovedArtifactShareService(
        artifactLifecycle: _FakeLifecycle(),
        bytesReader: reader,
        externalSharer: sharer,
      );

      await expectLater(
        service.shareApprovedExcel(halaqahId: 7, item: _weeklyItem()),
        throwsStateError,
      );

      expect(reader.calls, 0);
      expect(sharer.calls, 0);
    });

    test('non-Excel primary metadata is rejected before share', () async {
      final reader = _FakeReader(<int>[1, 2, 3]);
      final sharer = _FakeSharer();
      final service = Package8SupportReportApprovedArtifactShareService(
        artifactLifecycle: _FakeLifecycle(
          weeklyArtifact: _artifact(format: SupportReportExportFormat.pdf),
        ),
        bytesReader: reader,
        externalSharer: sharer,
      );

      await expectLater(
        service.shareApprovedExcel(halaqahId: 7, item: _weeklyItem()),
        throwsStateError,
      );

      expect(reader.calls, 0);
      expect(sharer.calls, 0);
    });
  });
}

SupportReportHistoryItem _weeklyItem() {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));
  return SupportReportHistoryItem(
    reportId: 101,
    kind: SupportReportHistoryKind.weekly,
    periodStart: period.weekStart,
    periodEnd: period.weekEnd,
    header: _header,
    sourceFingerprint: 'weekly-share-source',
    approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
  );
}

SupportReportHistoryItem _monthlyItem() {
  final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 1));
  return SupportReportHistoryItem(
    reportId: 102,
    kind: SupportReportHistoryKind.monthly,
    periodStart: period.monthStart,
    periodEnd: period.monthEnd,
    header: _header,
    sourceFingerprint: 'monthly-share-source',
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

final class _FakeSharer implements SupportReportArtifactExternalSharer {
  var calls = 0;
  List<int>? lastBytes;
  String? lastSha256;
  String? lastSuggestedName;

  @override
  Future<void> shareExcel({
    required List<int> bytes,
    required String sha256,
    required String suggestedName,
  }) async {
    calls += 1;
    lastBytes = List<int>.from(bytes);
    lastSha256 = sha256;
    lastSuggestedName = suggestedName;
  }
}
