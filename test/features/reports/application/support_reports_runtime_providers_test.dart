import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/data/support_report_artifact_file_store.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/data/drift_runtime_database_opener.dart';

void main() {
  group('supportReportsRuntimeContextProvider', () {
    test('enabled support exposes Reports without history', () async {
      final harness = await _Harness.create(status: 'enabled');
      try {
        final context = await harness.readContext();
        expect(context.halaqahId, harness.halaqahId);
        expect(context.supportEnabled, isTrue);
        expect(context.hasHistoricalReports, isFalse);
        expect(context.canOpenReports, isTrue);
      } finally {
        await harness.close();
      }
    });
    test(
      'disabled support without history still exposes Reports shell',
      () async {
        final harness = await _Harness.create(status: 'disabled');
        try {
          final context = await harness.readContext();
          expect(context.supportEnabled, isFalse);
          expect(context.hasHistoricalReports, isFalse);
          expect(context.canOpenReports, isTrue);
        } finally {
          await harness.close();
        }
      },
    );
    test('disabled support exposes Package 8 approval coordinators', () async {
      final harness = await _Harness.create(status: 'disabled');
      try {
        final context = await harness.readContext();
        expect(context.supportEnabled, isFalse);

        final weekly = await harness.container.read(
          package8WeeklySupportReportApprovalCoordinatorProvider.future,
        );
        final monthly = await harness.container.read(
          package8MonthlySupportReportApprovalCoordinatorProvider.future,
        );

        expect(weekly, isNotNull);
        expect(monthly, isNotNull);
      } finally {
        await harness.close();
      }
    });

    test(
      'disabled support preserves Reports access when approved history exists',
      () async {
        final harness = await _Harness.create(
          status: 'disabled',
          withApprovedWeekly: true,
        );
        try {
          final context = await harness.readContext();
          expect(context.supportEnabled, isFalse);
          expect(context.hasHistoricalReports, isTrue);
          expect(context.canOpenReports, isTrue);
          expect(context.history, hasLength(1));
          final weeklyRows = await harness.database
              .select(harness.database.supportWeeklyReports)
              .get();
          final monthlyRows = await harness.database
              .select(harness.database.supportMonthlyReports)
              .get();
          expect(weeklyRows, hasLength(1));
          expect(monthlyRows, isEmpty);
        } finally {
          await harness.close();
        }
      },
    );
    test(
      'startup cleanup deletes report orphans once per ProviderContainer',
      () async {
        final harness = await _Harness.create(status: 'disabled');

        try {
          final artifactsDirectory = Directory(
            '${harness.artifactDirectory.path}${Platform.pathSeparator}'
            '${SupportReportArtifactFileStore.artifactsDirectoryName}',
          );
          await artifactsDirectory.create(recursive: true);

          final orphanHash = List<String>.filled(64, 'a').join();
          final stagingHash = List<String>.filled(64, 'b').join();
          final lateOrphanHash = List<String>.filled(64, 'c').join();

          final orphan = File(
            '${artifactsDirectory.path}${Platform.pathSeparator}'
            '$orphanHash.xlsx',
          );
          final staging = File(
            '${artifactsDirectory.path}${Platform.pathSeparator}'
            '$stagingHash.xlsx.staging.123',
          );

          await orphan.writeAsBytes(<int>[1, 2, 3], flush: true);
          await staging.writeAsBytes(<int>[4, 5, 6], flush: true);

          final deleted = await harness.container.read(
            supportReportStartupCleanupProvider.future,
          );

          expect(deleted, 2);
          expect(await orphan.exists(), isFalse);
          expect(await staging.exists(), isFalse);

          final lateOrphan = File(
            '${artifactsDirectory.path}${Platform.pathSeparator}'
            '$lateOrphanHash.xlsx',
          );
          await lateOrphan.writeAsBytes(<int>[7, 8, 9], flush: true);

          final cachedDeleted = await harness.container.read(
            supportReportStartupCleanupProvider.future,
          );

          expect(cachedDeleted, 2);
          expect(await lateOrphan.exists(), isTrue);
        } finally {
          await harness.close();
        }
      },
    );
  });
}

final class _Harness {
  _Harness({
    required this.database,
    required this.halaqahId,
    required this.container,
    required this.artifactDirectory,
  });
  final AppDatabase database;
  final int halaqahId;
  final ProviderContainer container;
  final Directory artifactDirectory;

  static Future<_Harness> create({
    required String status,
    bool withApprovedWeekly = false,
  }) async {
    final database = AppDatabase(NativeDatabase.memory());
    final artifactDirectory = await Directory.systemTemp.createTemp(
      'qurani_reports_runtime_provider_',
    );
    final now = DateTime.utc(2026, 9, 16, 12);
    final halaqahId = await database
        .into(database.halaqahs)
        .insert(
          HalaqahsCompanion.insert(
            teacherName: 'المعلم',
            halaqahName: 'حلقة النور',
            centerName: 'المركز',
            createdAtUtc: now,
            updatedAtUtc: now,
          ),
        );
    final organizationName = status == 'enabled' ? 'الجهة' : null;
    await database
        .into(database.supportProgramSettings)
        .insert(
          SupportProgramSettingsCompanion.insert(
            halaqahId: halaqahId,
            status: status,
            organizationName: Value<String?>(organizationName),
            createdAtUtc: now,
            updatedAtUtc: now,
          ),
        );
    if (status == 'enabled') {
      await database
          .into(database.supportProgramPeriods)
          .insert(
            SupportProgramPeriodsCompanion.insert(
              halaqahId: halaqahId,
              organizationName: organizationName!,
              startedAtUtc: DateTime.utc(2026, 9, 13, 12),
            ),
          );
    }
    if (withApprovedWeekly) {
      await database
          .into(database.supportWeeklyReports)
          .insert(
            SupportWeeklyReportsCompanion.insert(
              halaqahId: halaqahId,
              weekStartDate: '2026-09-05',
              weekEndDate: '2026-09-09',
              status: 'approved',
              teacherNameSnapshot: 'المعلم',
              halaqahNameSnapshot: 'حلقة النور',
              organizationNameSnapshot: 'الجهة',
              policyVersion: 1,
              templateVersion: 1,
              sourceFingerprint: const Value<String?>('history-fingerprint'),
              approvedAtUtc: Value<DateTime?>(DateTime.utc(2026, 9, 10, 8)),
            ),
          );
    }
    final coordinator = _FakeRuntimeCoordinator(
      DriftRuntimeDatabaseHandle(database),
    );
    final container = ProviderContainer(
      overrides: <Override>[
        runtimeLockCoordinatorProvider.overrideWith((ref) async => coordinator),
        supportReportArtifactFileStoreProvider.overrideWith(
          (ref) async => SupportReportArtifactFileStore(
            applicationSupportDirectory: artifactDirectory,
          ),
        ),
      ],
    );
    return _Harness(
      database: database,
      halaqahId: halaqahId,
      container: container,
      artifactDirectory: artifactDirectory,
    );
  }

  Future<SupportReportsRuntimeContext> readContext() {
    return container.read(supportReportsRuntimeContextProvider.future);
  }

  Future<void> close() async {
    container.dispose();
    await database.close();

    if (await artifactDirectory.exists()) {
      await artifactDirectory.delete(recursive: true);
    }
  }
}

final class _FakeRuntimeCoordinator
    implements RuntimeLockCoordinator, RuntimeDatabaseSessionAccess {
  _FakeRuntimeCoordinator(this._handle);
  final DriftRuntimeDatabaseHandle? _handle;

  @override
  RuntimeDatabaseHandle requireOpenDatabaseHandle() {
    final handle = _handle;
    if (handle == null) {
      throw StateError('Runtime session is locked.');
    }
    return handle;
  }

  @override
  Future<RuntimeLockSnapshot> inspect() async => RuntimeLockSnapshot(
    unlocked: _handle != null,
    failedAttemptCount: 0,
    lockedUntilUtc: null,
  );
  @override
  Future<RuntimeUnlockResult> unlock(String pin) {
    throw UnsupportedError('Not used by this provider test.');
  }

  @override
  Future<RuntimeChangePinResult> changePin({
    required String currentPin,
    required String newPin,
  }) {
    throw UnsupportedError('Not used by this provider test.');
  }

  @override
  Future<void> lock() async {}
  @override
  Future<void> dispose() async {}
}
