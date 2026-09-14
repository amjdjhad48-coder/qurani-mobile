import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/students/domain/support_program.dart';
import 'package:qurani/features/students/domain/support_program_repository.dart';

final class DriftSupportProgramRepository implements SupportProgramRepository {
  DriftSupportProgramRepository(this._database);

  final AppDatabase _database;

  @override
  Future<SupportProgramState> getState(int halaqahId) async {
    final settings = await (_database.select(
      _database.supportProgramSettings,
    )..where((table) => table.halaqahId.equals(halaqahId))).getSingleOrNull();

    if (settings == null) {
      throw StateError('Support settings are missing for halaqah $halaqahId.');
    }

    return SupportProgramState(
      halaqahId: settings.halaqahId,
      status: settings.status,
      organizationName: settings.organizationName,
    );
  }

  @override
  Future<SupportActivationCheck> checkActivation(int halaqahId) async {
    final state = await getState(halaqahId);

    if (!state.isPendingActivation) {
      throw StateError(
        'Support activation check requires pending_activation state.',
      );
    }

    final missing = await _missingActiveStudentNumbers(halaqahId);

    return SupportActivationCheck(
      state: state,
      missingStudentNumbers: List<StudentSupportGap>.unmodifiable(missing),
    );
  }

  @override
  Future<SupportProgramState> beginActivation({
    required int halaqahId,
    required String organizationName,
    required DateTime updatedAtUtc,
  }) {
    return _database.transaction(() async {
      final settings = await (_database.select(
        _database.supportProgramSettings,
      )..where((table) => table.halaqahId.equals(halaqahId))).getSingleOrNull();

      if (settings == null) {
        throw StateError(
          'Support settings are missing for halaqah $halaqahId.',
        );
      }

      if (settings.status != 'disabled') {
        throw StateError(
          'Support activation can begin only from disabled state.',
        );
      }

      final openPeriods =
          await (_database.select(_database.supportProgramPeriods)..where(
                (table) =>
                    table.halaqahId.equals(halaqahId) &
                    table.endedAtUtc.isNull(),
              ))
              .get();

      if (openPeriods.isNotEmpty) {
        throw StateError(
          'Disabled support must not have an open support period.',
        );
      }

      final affected =
          await (_database.update(
            _database.supportProgramSettings,
          )..where((table) => table.halaqahId.equals(halaqahId))).write(
            SupportProgramSettingsCompanion(
              status: const Value<String>('pending_activation'),
              organizationName: Value<String?>(organizationName),
              updatedAtUtc: Value<DateTime>(updatedAtUtc),
            ),
          );

      if (affected != 1) {
        throw StateError(
          'Support settings update failed for halaqah $halaqahId.',
        );
      }

      return SupportProgramState(
        halaqahId: halaqahId,
        status: 'pending_activation',
        organizationName: organizationName,
      );
    });
  }

  @override
  Future<SupportProgramState> activate({
    required int halaqahId,
    required DateTime activatedAtUtc,
  }) {
    return _database.transaction(() async {
      final settings = await (_database.select(
        _database.supportProgramSettings,
      )..where((table) => table.halaqahId.equals(halaqahId))).getSingleOrNull();

      if (settings == null) {
        throw StateError(
          'Support settings are missing for halaqah $halaqahId.',
        );
      }

      if (settings.status != 'pending_activation') {
        throw StateError(
          'Support can be enabled only from pending_activation state.',
        );
      }

      final organizationName = settings.organizationName?.trim();

      if (organizationName == null || organizationName.isEmpty) {
        throw StateError(
          'Pending support activation has no organization name.',
        );
      }

      final missing = await _missingActiveStudentNumbers(halaqahId);

      if (missing.isNotEmpty) {
        final studentIds = missing
            .map((student) => student.studentId)
            .join(',');

        throw StateError(
          'Active students are missing support numbers: $studentIds.',
        );
      }

      final openPeriods =
          await (_database.select(_database.supportProgramPeriods)..where(
                (table) =>
                    table.halaqahId.equals(halaqahId) &
                    table.endedAtUtc.isNull(),
              ))
              .get();

      if (openPeriods.isNotEmpty) {
        throw StateError(
          'Support activation cannot open a second active period.',
        );
      }

      final affected =
          await (_database.update(
            _database.supportProgramSettings,
          )..where((table) => table.halaqahId.equals(halaqahId))).write(
            SupportProgramSettingsCompanion(
              status: const Value<String>('enabled'),
              updatedAtUtc: Value<DateTime>(activatedAtUtc),
            ),
          );

      if (affected != 1) {
        throw StateError(
          'Support settings activation failed for halaqah $halaqahId.',
        );
      }

      await _database
          .into(_database.supportProgramPeriods)
          .insert(
            SupportProgramPeriodsCompanion.insert(
              halaqahId: halaqahId,
              organizationName: organizationName,
              startedAtUtc: activatedAtUtc,
            ),
          );

      return SupportProgramState(
        halaqahId: halaqahId,
        status: 'enabled',
        organizationName: organizationName,
      );
    });
  }

  @override
  Future<SupportProgramState> disable({
    required int halaqahId,
    required DateTime disabledAtUtc,
  }) {
    return _database.transaction(() async {
      final settings = await (_database.select(
        _database.supportProgramSettings,
      )..where((table) => table.halaqahId.equals(halaqahId))).getSingleOrNull();

      if (settings == null) {
        throw StateError(
          'Support settings are missing for halaqah $halaqahId.',
        );
      }

      if (settings.status != 'enabled') {
        throw StateError('Support can be disabled only from enabled state.');
      }

      final openPeriods =
          await (_database.select(_database.supportProgramPeriods)..where(
                (table) =>
                    table.halaqahId.equals(halaqahId) &
                    table.endedAtUtc.isNull(),
              ))
              .get();

      if (openPeriods.length != 1) {
        throw StateError(
          'Enabled support must have exactly one open support period.',
        );
      }

      final openPeriod = openPeriods.single;

      if (!disabledAtUtc.isAfter(openPeriod.startedAtUtc)) {
        throw StateError('Support period end must be after its start.');
      }

      final periodAffected =
          await (_database.update(
            _database.supportProgramPeriods,
          )..where((table) => table.id.equals(openPeriod.id))).write(
            SupportProgramPeriodsCompanion(
              endedAtUtc: Value<DateTime?>(disabledAtUtc),
            ),
          );

      if (periodAffected != 1) {
        throw StateError('Open support period could not be closed.');
      }

      final settingsAffected =
          await (_database.update(
            _database.supportProgramSettings,
          )..where((table) => table.halaqahId.equals(halaqahId))).write(
            SupportProgramSettingsCompanion(
              status: const Value<String>('disabled'),
              organizationName: const Value<String?>(null),
              updatedAtUtc: Value<DateTime>(disabledAtUtc),
            ),
          );

      if (settingsAffected != 1) {
        throw StateError(
          'Support settings disable failed for halaqah $halaqahId.',
        );
      }

      return SupportProgramState(
        halaqahId: halaqahId,
        status: 'disabled',
        organizationName: null,
      );
    });
  }

  Future<List<StudentSupportGap>> _missingActiveStudentNumbers(
    int halaqahId,
  ) async {
    final students =
        await (_database.select(_database.students)
              ..where(
                (table) =>
                    table.halaqahId.equals(halaqahId) &
                    table.isActive.equals(true) &
                    table.supportStudentNumber.isNull(),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.displayOrder)]))
            .get();

    return students
        .map(
          (student) => StudentSupportGap(
            studentId: student.id,
            studentName: student.studentName,
          ),
        )
        .toList(growable: false);
  }
}
