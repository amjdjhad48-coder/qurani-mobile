import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
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
    test('disabled support without history hides Reports', () async {
      final harness = await _Harness.create(status: 'disabled');
      try {
        final context = await harness.readContext();
        expect(context.supportEnabled, isFalse);
        expect(context.hasHistoricalReports, isFalse);
        expect(context.canOpenReports, isFalse);
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
  });
}

final class _Harness {
  _Harness({
    required this.database,
    required this.halaqahId,
    required this.container,
  });
  final AppDatabase database;
  final int halaqahId;
  final ProviderContainer container;

  static Future<_Harness> create({
    required String status,
    bool withApprovedWeekly = false,
  }) async {
    final database = AppDatabase(NativeDatabase.memory());
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
      ],
    );
    return _Harness(
      database: database,
      halaqahId: halaqahId,
      container: container,
    );
  }

  Future<SupportReportsRuntimeContext> readContext() {
    return container.read(supportReportsRuntimeContextProvider.future);
  }

  Future<void> close() async {
    container.dispose();
    await database.close();
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
