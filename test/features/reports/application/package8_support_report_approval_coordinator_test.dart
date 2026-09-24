import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/monthly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/package8_support_report_approval_coordinator.dart';
import 'package:qurani/features/reports/application/package8_support_report_artifact_lifecycle.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  group('Package 8 atomic approval coordinator', () {
    test('weekly orders prepare, gate, recheck, atomic commit', () async {
      final events = <String>[];
      final candidate = _weeklyCandidate(_hash('1'));
      final repository = _FakeWeeklyRepository(events);
      final coordinator = Package8WeeklySupportReportApprovalCoordinator(
        repository: repository,
        artifactLifecycle: _FakeArtifactLifecycle(events),
        artifactPreparer: _FakePreparer(events),
        artifactVerifier: _FakeVerifier(events, isValid: true),
        sourceReloader: _FakeWeeklyReloader(
          events,
          _weeklyCandidate(candidate.sourceFingerprint),
        ),
      );
      final outcome = await coordinator.approve(
        halaqahId: 1,
        candidate: candidate,
        approvedAtUtc: DateTime.utc(2026, 9, 18, 12),
      );
      expect(outcome.isApproved, isTrue);
      expect(events, <String>[
        'prepare-weekly',
        'verify',
        'reload-weekly',
        'current-weekly-primary',
        'commit',
        'find',
        'cleanup-stored',
      ]);
      expect(
        repository.primaryArtifact!.format,
        SupportReportExportFormat.excel,
      );
      expect(
        repository.primaryArtifact!.internalPath,
        'report_artifacts/${_hash('a')}.xlsx',
      );
    });

    test('weekly source change blocks commit after verified staging', () async {
      final events = <String>[];
      final candidate = _weeklyCandidate(_hash('2'));
      final repository = _FakeWeeklyRepository(events);
      final coordinator = Package8WeeklySupportReportApprovalCoordinator(
        repository: repository,
        artifactLifecycle: _FakeArtifactLifecycle(events),
        artifactPreparer: _FakePreparer(events),
        artifactVerifier: _FakeVerifier(events, isValid: true),
        sourceReloader: _FakeWeeklyReloader(
          events,
          _weeklyCandidate(_hash('3')),
        ),
      );
      final outcome = await coordinator.approve(
        halaqahId: 1,
        candidate: candidate,
        approvedAtUtc: DateTime.utc(2026, 9, 18, 12),
      );
      expect(
        outcome.status,
        Package8SupportReportApprovalStatus.sourceChangedDuringPreparation,
      );
      expect(events, <String>[
        'prepare-weekly',
        'verify',
        'reload-weekly',
        'cleanup-prepared',
      ]);
      expect(repository.committed, isFalse);
    });

    test('weekly gate rejection stops before recheck and commit', () async {
      final events = <String>[];
      final candidate = _weeklyCandidate(_hash('4'));
      final repository = _FakeWeeklyRepository(events);
      final coordinator = Package8WeeklySupportReportApprovalCoordinator(
        repository: repository,
        artifactLifecycle: _FakeArtifactLifecycle(events),
        artifactPreparer: _FakePreparer(events),
        artifactVerifier: _FakeVerifier(events, isValid: false),
        sourceReloader: _FakeWeeklyReloader(events, candidate),
      );
      final outcome = await coordinator.approve(
        halaqahId: 1,
        candidate: candidate,
        approvedAtUtc: DateTime.utc(2026, 9, 18, 12),
      );
      expect(
        outcome.status,
        Package8SupportReportApprovalStatus.primaryArtifactNotSatisfied,
      );
      expect(events, <String>['prepare-weekly', 'verify', 'cleanup-prepared']);
      expect(repository.committed, isFalse);
    });

    test(
      'weekly commit failure cleans only the unreferenced prepared artifact',
      () async {
        final events = <String>[];
        final candidate = _weeklyCandidate(_hash('6'));
        final repository = _FakeWeeklyRepository(events, throwOnCommit: true);
        final coordinator = Package8WeeklySupportReportApprovalCoordinator(
          repository: repository,
          artifactLifecycle: _FakeArtifactLifecycle(events),
          artifactPreparer: _FakePreparer(events),
          artifactVerifier: _FakeVerifier(events, isValid: true),
          sourceReloader: _FakeWeeklyReloader(
            events,
            _weeklyCandidate(candidate.sourceFingerprint),
          ),
        );

        await expectLater(
          coordinator.approve(
            halaqahId: 1,
            candidate: candidate,
            approvedAtUtc: DateTime.utc(2026, 9, 18, 12),
          ),
          throwsStateError,
        );

        expect(events, <String>[
          'prepare-weekly',
          'verify',
          'reload-weekly',
          'current-weekly-primary',
          'commit',
          'cleanup-prepared',
        ]);
        expect(repository.committed, isFalse);
      },
    );
    test('monthly orders prepare, gate, recheck, atomic commit', () async {
      final events = <String>[];
      final candidate = _monthlyCandidate(_hash('5'));
      final repository = _FakeMonthlyRepository(events);
      final coordinator = Package8MonthlySupportReportApprovalCoordinator(
        repository: repository,
        artifactLifecycle: _FakeArtifactLifecycle(events),
        artifactPreparer: _FakePreparer(events),
        artifactVerifier: _FakeVerifier(events, isValid: true),
        sourceReloader: _FakeMonthlyReloader(
          events,
          _monthlyCandidate(candidate.sourceFingerprint),
        ),
      );
      final outcome = await coordinator.approve(
        halaqahId: 1,
        candidate: candidate,
        approvedAtUtc: DateTime.utc(2026, 9, 18, 12),
      );
      expect(outcome.isApproved, isTrue);
      expect(events, <String>[
        'prepare-monthly',
        'verify',
        'reload-monthly',
        'current-monthly-primary',
        'commit',
        'find',
        'cleanup-stored',
      ]);
      expect(
        repository.primaryArtifact!.format,
        SupportReportExportFormat.excel,
      );
      expect(repository.primaryArtifact!.sha256, _hash('b'));
    });

    test(
      'monthly commit failure cleans only the unreferenced prepared artifact',
      () async {
        final events = <String>[];
        final candidate = _monthlyCandidate(_hash('7'));
        final repository = _FakeMonthlyRepository(events, throwOnCommit: true);
        final coordinator = Package8MonthlySupportReportApprovalCoordinator(
          repository: repository,
          artifactLifecycle: _FakeArtifactLifecycle(events),
          artifactPreparer: _FakePreparer(events),
          artifactVerifier: _FakeVerifier(events, isValid: true),
          sourceReloader: _FakeMonthlyReloader(
            events,
            _monthlyCandidate(candidate.sourceFingerprint),
          ),
        );

        await expectLater(
          coordinator.approve(
            halaqahId: 1,
            candidate: candidate,
            approvedAtUtc: DateTime.utc(2026, 9, 18, 12),
          ),
          throwsStateError,
        );

        expect(events, <String>[
          'prepare-monthly',
          'verify',
          'reload-monthly',
          'current-monthly-primary',
          'commit',
          'cleanup-prepared',
        ]);
        expect(repository.committed, isFalse);
      },
    );
  });
}

String _hash(String digit) => List<String>.filled(64, digit).join();

WeeklySupportReportApprovalCandidate _weeklyCandidate(String fingerprint) {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));
  return WeeklySupportReportApprovalCandidate(
    projection: WeeklySupportReportProjection(
      period: period,
      header: const SupportReportHeaderSnapshot(
        teacherName: 'المعلم',
        halaqahName: 'الحلقة',
        organizationName: 'الجهة',
        policyVersion: SupportReportPolicy.policyVersion,
        templateVersion: SupportReportPolicy.templateVersion,
      ),
      students: const <WeeklySupportReportStudentProjection>[],
      days: period.officialDates
          .map(
            (date) => WeeklySupportReportDayProjection(
              localDate: date,
              dayKind: SupportReportDayKind.normal,
            ),
          )
          .toList(growable: false),
      missingItems: const <ReportMissingItem>[],
    ),
    sourceFingerprint: fingerprint,
    warningsConfirmed: false,
  );
}

MonthlySupportReportApprovalCandidate _monthlyCandidate(String fingerprint) {
  final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));
  final weeklyPeriod = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 5));
  return MonthlySupportReportApprovalCandidate(
    projection: MonthlySupportReportProjection(
      halaqahId: 1,
      period: period,
      header: const SupportReportHeaderSnapshot(
        teacherName: 'المعلم',
        halaqahName: 'الحلقة',
        organizationName: 'الجهة',
        policyVersion: SupportReportPolicy.policyVersion,
        templateVersion: SupportReportPolicy.templateVersion,
      ),
      students: const <MonthlySupportReportStudentProjection>[],
      days: const <MonthlySupportReportDayProjection>[],
      weeklyInputs: <MonthlySupportReportWeeklyInputIdentity>[
        MonthlySupportReportWeeklyInputIdentity(
          reportId: 101,
          period: weeklyPeriod,
          sourceFingerprint: 'approved-weekly-source',
          approvedAtUtc: DateTime.utc(2026, 9, 10, 12),
        ),
      ],
      missingItems: const <ReportMissingItem>[],
    ),
    sourceFingerprint: fingerprint,
    warningsConfirmed: false,
  );
}

final class _FakePreparer implements PrimaryReportArtifactPreparer {
  _FakePreparer(this.events);
  final List<String> events;
  @override
  Future<PreparedPrimaryReportArtifact> prepareWeekly({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
  }) async {
    events.add('prepare-weekly');
    return PreparedPrimaryReportArtifact(
      kind: SupportReportArtifactKind.weekly,
      sourceFingerprint: sourceFingerprint,
      policyVersion: projection.header.policyVersion,
      templateVersion: projection.header.templateVersion,
      internalPath: 'report_artifacts/${_hash('a')}.xlsx',
      sha256: _hash('a'),
      sizeBytes: 2048,
    );
  }

  @override
  Future<PreparedPrimaryReportArtifact> prepareMonthly({
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
  }) async {
    events.add('prepare-monthly');
    return PreparedPrimaryReportArtifact(
      kind: SupportReportArtifactKind.monthly,
      sourceFingerprint: sourceFingerprint,
      policyVersion: projection.header.policyVersion,
      templateVersion: projection.header.templateVersion,
      internalPath: 'report_artifacts/${_hash('b')}.xlsx',
      sha256: _hash('b'),
      sizeBytes: 4096,
    );
  }
}

final class _FakeVerifier implements PreparedPrimaryReportArtifactVerifier {
  _FakeVerifier(this.events, {required this.isValid});
  final List<String> events;
  final bool isValid;
  @override
  Future<PreparedPrimaryReportArtifactVerification> verifyPrepared(
    PreparedPrimaryReportArtifact artifact,
  ) async {
    events.add('verify');
    return isValid
        ? const PreparedPrimaryReportArtifactVerification.valid()
        : const PreparedPrimaryReportArtifactVerification.invalid(
            reason: 'test rejection',
          );
  }
}

final class _FakeWeeklyReloader
    implements WeeklySupportReportApprovalCandidateReloader {
  _FakeWeeklyReloader(this.events, this.candidate);
  final List<String> events;
  final WeeklySupportReportApprovalCandidate candidate;
  @override
  Future<WeeklySupportReportApprovalCandidate> reload({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    events.add('reload-weekly');
    return candidate;
  }
}

final class _FakeMonthlyReloader
    implements MonthlySupportReportApprovalCandidateReloader {
  _FakeMonthlyReloader(this.events, this.candidate);
  final List<String> events;
  final MonthlySupportReportApprovalCandidate candidate;
  @override
  Future<MonthlySupportReportApprovalCandidate> reload({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    events.add('reload-monthly');
    return candidate;
  }
}

final class _FakeWeeklyRepository
    implements WeeklySupportReportAtomicApprovalRepository {
  _FakeWeeklyRepository(this.events, {this.throwOnCommit = false});
  final List<String> events;
  final bool throwOnCommit;
  bool committed = false;
  WeeklySupportReportProjection? projection;
  String? sourceFingerprint;
  DateTime? approvedAtUtc;
  SupportReportExportArtifactMetadata? primaryArtifact;
  @override
  Future<void> replaceApprovedWithPrimaryArtifact({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
    required SupportReportExportArtifactMetadata primaryArtifact,
  }) async {
    events.add('commit');
    if (throwOnCommit) {
      throw StateError('test weekly commit failure');
    }
    committed = true;
    this.projection = projection;
    this.sourceFingerprint = sourceFingerprint;
    this.approvedAtUtc = approvedAtUtc;
    this.primaryArtifact = primaryArtifact;
  }

  @override
  Future<ApprovedWeeklySupportReportSnapshot?> findApproved({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    events.add('find');
    if (!committed) return null;
    return ApprovedWeeklySupportReportSnapshot(
      reportId: 1,
      halaqahId: halaqahId,
      period: period,
      header: projection!.header,
      sourceFingerprint: sourceFingerprint!,
      approvedAtUtc: approvedAtUtc!,
      students: const <ApprovedWeeklySupportReportStudentSnapshot>[],
      days: const <ApprovedWeeklySupportReportDaySnapshot>[],
    );
  }

  @override
  Future<void> replaceApproved({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
  }) {
    throw UnsupportedError('Atomic Package 8 test repository.');
  }
}

final class _FakeMonthlyRepository
    implements MonthlySupportReportAtomicApprovalRepository {
  _FakeMonthlyRepository(this.events, {this.throwOnCommit = false});
  final List<String> events;
  final bool throwOnCommit;
  bool committed = false;
  MonthlySupportReportProjection? projection;
  String? sourceFingerprint;
  DateTime? approvedAtUtc;
  SupportReportExportArtifactMetadata? primaryArtifact;
  @override
  Future<void> replaceApprovedWithPrimaryArtifact({
    required int halaqahId,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
    required SupportReportExportArtifactMetadata primaryArtifact,
  }) async {
    events.add('commit');
    if (throwOnCommit) {
      throw StateError('test monthly commit failure');
    }
    committed = true;
    this.projection = projection;
    this.sourceFingerprint = sourceFingerprint;
    this.approvedAtUtc = approvedAtUtc;
    this.primaryArtifact = primaryArtifact;
  }

  @override
  Future<ApprovedMonthlySupportReportSnapshot?> findApproved({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    events.add('find');
    if (!committed) return null;
    return ApprovedMonthlySupportReportSnapshot(
      reportId: 1,
      halaqahId: halaqahId,
      period: period,
      header: projection!.header,
      sourceFingerprint: sourceFingerprint!,
      approvedAtUtc: approvedAtUtc!,
      students: const <ApprovedMonthlySupportReportStudentSnapshot>[],
      days: const <ApprovedMonthlySupportReportDaySnapshot>[],
    );
  }

  @override
  Future<void> replaceApproved({
    required int halaqahId,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
  }) {
    throw UnsupportedError('Atomic Package 8 test repository.');
  }
}

final class _FakeArtifactLifecycle
    implements SupportReportApprovalArtifactLifecycle {
  _FakeArtifactLifecycle(this.events);

  final List<String> events;

  @override
  Future<SupportReportExportArtifactMetadata?> currentWeeklyPrimaryArtifact({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    events.add('current-weekly-primary');
    return _oldArtifact();
  }

  @override
  Future<SupportReportExportArtifactMetadata?> currentMonthlyPrimaryArtifact({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    events.add('current-monthly-primary');
    return _oldArtifact();
  }

  @override
  Future<void> cleanupPreparedIfUnreferenced(
    PreparedPrimaryReportArtifact artifact,
  ) async {
    events.add('cleanup-prepared');
  }

  @override
  Future<void> cleanupStoredIfUnreferenced(
    SupportReportExportArtifactMetadata artifact,
  ) async {
    events.add('cleanup-stored');
  }

  @override
  Future<int> cleanupOrphans() async => 0;
}

SupportReportExportArtifactMetadata _oldArtifact() {
  return SupportReportExportArtifactMetadata(
    format: SupportReportExportFormat.excel,
    internalPath: 'report_artifacts/.xlsx',
    sha256: _hash('c'),
    templateVersion: SupportReportPolicy.templateVersion,
    sizeBytes: 1024,
  );
}
