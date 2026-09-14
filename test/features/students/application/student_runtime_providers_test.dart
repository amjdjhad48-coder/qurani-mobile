import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/data/drift_runtime_database_opener.dart';
import 'package:qurani/features/students/application/student_runtime_providers.dart';

void main() {
  group('studentRuntimeContextProvider', () {
    test(
      'uses the already-open runtime database and configured halaqah',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database);

          await database
              .into(database.students)
              .insert(
                StudentsCompanion.insert(
                  halaqahId: halaqahId,
                  studentName: 'أحمد',
                  fatherName: 'محمد',
                  ageYears: 10,
                  guardianCountryCode: '+967',
                  guardianNationalNumber: '771234567',
                  previousMemorizationText: 'جزء عم',
                  displayOrder: 1,
                ),
              );

          final coordinator = _FakeRuntimeCoordinator(
            DriftRuntimeDatabaseHandle(database),
          );

          final container = ProviderContainer(
            overrides: <Override>[
              runtimeLockCoordinatorProvider.overrideWith(
                (ref) async => coordinator,
              ),
            ],
          );

          try {
            final context = await container.read(
              studentRuntimeContextProvider.future,
            );

            expect(context.halaqahId, halaqahId);

            final students = await context.service.search(halaqahId: halaqahId);

            expect(students, hasLength(1));
            expect(students.single.studentName, 'أحمد');
          } finally {
            container.dispose();
          }

          await database.customSelect('SELECT 1;').get();
          expect(coordinator.handleCloseCalls, 0);
        } finally {
          await database.close();
        }
      },
    );

    test('refuses access when runtime session is locked', () async {
      final coordinator = _FakeRuntimeCoordinator(null);

      final container = ProviderContainer(
        overrides: <Override>[
          runtimeLockCoordinatorProvider.overrideWith(
            (ref) async => coordinator,
          ),
        ],
      );

      try {
        await expectLater(
          container.read(studentRuntimeContextProvider.future),
          throwsStateError,
        );
      } finally {
        container.dispose();
      }
    });

    test('requires exactly one configured halaqah', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final coordinator = _FakeRuntimeCoordinator(
          DriftRuntimeDatabaseHandle(database),
        );

        final container = ProviderContainer(
          overrides: <Override>[
            runtimeLockCoordinatorProvider.overrideWith(
              (ref) async => coordinator,
            ),
          ],
        );

        try {
          await expectLater(
            container.read(studentRuntimeContextProvider.future),
            throwsStateError,
          );
        } finally {
          container.dispose();
        }

        expect(coordinator.handleCloseCalls, 0);
      } finally {
        await database.close();
      }
    });
  });
}

Future<int> _insertHalaqah(AppDatabase database) {
  final now = DateTime.utc(2026, 9, 13);

  return database
      .into(database.halaqahs)
      .insert(
        HalaqahsCompanion.insert(
          teacherName: 'المعلم',
          halaqahName: 'الحلقة',
          centerName: 'المركز',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );
}

final class _FakeRuntimeCoordinator
    implements RuntimeLockCoordinator, RuntimeDatabaseSessionAccess {
  _FakeRuntimeCoordinator(this._handle);

  final DriftRuntimeDatabaseHandle? _handle;

  int get handleCloseCalls => _handle == null ? 0 : 0;

  @override
  RuntimeDatabaseHandle requireOpenDatabaseHandle() {
    final handle = _handle;

    if (handle == null) {
      throw StateError('Runtime session is locked.');
    }

    return handle;
  }

  @override
  Future<RuntimeLockSnapshot> inspect() async {
    return RuntimeLockSnapshot(
      unlocked: _handle != null,
      failedAttemptCount: 0,
      lockedUntilUtc: null,
    );
  }

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
