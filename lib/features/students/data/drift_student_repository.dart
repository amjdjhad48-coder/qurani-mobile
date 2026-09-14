import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/domain/student_repository.dart';

final class DriftStudentRepository implements StudentRepository {
  DriftStudentRepository(this._database);

  final AppDatabase _database;

  @override
  Future<StudentRecord?> findById(int studentId) async {
    final row = await (_database.select(
      _database.students,
    )..where((table) => table.id.equals(studentId))).getSingleOrNull();

    return row == null ? null : _mapStudent(row);
  }

  @override
  Future<String> supportStatusForHalaqah(int halaqahId) async {
    final row = await (_database.select(
      _database.supportProgramSettings,
    )..where((table) => table.halaqahId.equals(halaqahId))).getSingleOrNull();

    if (row == null) {
      throw StateError('Support settings are missing for halaqah $halaqahId.');
    }

    return row.status;
  }

  @override
  Future<StudentProgressPlanRecord?> progressPlanForStudent(
    int studentId,
  ) async {
    final row = await (_database.select(
      _database.studentProgressPlans,
    )..where((table) => table.studentId.equals(studentId))).getSingleOrNull();

    return row == null ? null : _mapProgressPlan(row);
  }

  @override
  Future<StudentProgressPlanRecord> saveProgressPlan({
    required int studentId,
    required int? currentJuz,
    required String? dailyPlanText,
  }) {
    return _database.transaction(() async {
      final student = await (_database.select(
        _database.students,
      )..where((table) => table.id.equals(studentId))).getSingleOrNull();

      if (student == null) {
        throw StateError('Student $studentId was not found.');
      }

      final existing = await (_database.select(
        _database.studentProgressPlans,
      )..where((table) => table.studentId.equals(studentId))).getSingleOrNull();

      if (existing == null) {
        await _database
            .into(_database.studentProgressPlans)
            .insert(
              StudentProgressPlansCompanion.insert(
                studentId: Value<int>(studentId),
                currentJuz: Value<int?>(currentJuz),
                dailyPlanText: Value<String?>(dailyPlanText),
              ),
            );
      } else {
        final affected =
            await (_database.update(
              _database.studentProgressPlans,
            )..where((table) => table.studentId.equals(studentId))).write(
              StudentProgressPlansCompanion(
                currentJuz: Value<int?>(currentJuz),
                dailyPlanText: Value<String?>(dailyPlanText),
              ),
            );

        if (affected != 1) {
          throw StateError(
            'Progress plan for student $studentId could not be updated.',
          );
        }
      }

      final saved = await progressPlanForStudent(studentId);

      if (saved == null) {
        throw StateError(
          'Progress plan for student $studentId could not be read back.',
        );
      }

      return saved;
    });
  }

  @override
  Future<List<StudentRecord>> reorderActiveStudents({
    required int halaqahId,
    required List<int> orderedStudentIds,
  }) {
    return _database.transaction(() async {
      final currentRows =
          await (_database.select(_database.students)
                ..where(
                  (table) =>
                      table.halaqahId.equals(halaqahId) &
                      table.isActive.equals(true),
                )
                ..orderBy([
                  (table) => OrderingTerm.asc(table.displayOrder),
                  (table) => OrderingTerm.asc(table.id),
                ]))
              .get();

      final currentIds = currentRows
          .map((student) => student.id)
          .toList(growable: false);

      if (orderedStudentIds.length != currentIds.length) {
        throw ArgumentError(
          'Active student order must contain every active student.',
        );
      }

      final requestedIds = orderedStudentIds.toSet();

      if (requestedIds.length != orderedStudentIds.length) {
        throw ArgumentError(
          'Active student order must not contain duplicate student ids.',
        );
      }

      final currentIdSet = currentIds.toSet();

      final hasSameStudents =
          requestedIds.containsAll(currentIdSet) &&
          currentIdSet.containsAll(requestedIds);

      if (!hasSameStudents) {
        throw ArgumentError(
          'Active student order contains an invalid student id.',
        );
      }

      for (var index = 0; index < orderedStudentIds.length; index++) {
        final studentId = orderedStudentIds[index];
        final displayOrder = index + 1;

        final affected =
            await (_database.update(
              _database.students,
            )..where((table) => table.id.equals(studentId))).write(
              StudentsCompanion(displayOrder: Value<int>(displayOrder)),
            );

        if (affected != 1) {
          throw StateError('Student $studentId could not be reordered.');
        }
      }

      final reorderedRows =
          await (_database.select(_database.students)
                ..where(
                  (table) =>
                      table.halaqahId.equals(halaqahId) &
                      table.isActive.equals(true),
                )
                ..orderBy([
                  (table) => OrderingTerm.asc(table.displayOrder),
                  (table) => OrderingTerm.asc(table.id),
                ]))
              .get();

      return reorderedRows.map(_mapStudent).toList(growable: false);
    });
  }

  @override
  Future<List<StudentActivityPeriodRecord>> activityPeriodsForStudent(
    int studentId,
  ) async {
    final rows =
        await (_database.select(_database.studentActivityPeriods)
              ..where((table) => table.studentId.equals(studentId))
              ..orderBy([(table) => OrderingTerm.asc(table.id)]))
            .get();

    return rows
        .map(
          (row) => StudentActivityPeriodRecord(
            id: row.id,
            studentId: row.studentId,
            activeFromDate: row.activeFromDate,
            activeToDate: row.activeToDate,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<StudentRecord>> search({
    required int halaqahId,
    required String query,
    bool includeArchived = false,
  }) async {
    final normalizedQuery = query.trim();

    final statement = _database.select(_database.students)
      ..where((table) {
        Expression<bool> predicate = table.halaqahId.equals(halaqahId);

        if (!includeArchived) {
          predicate = predicate & table.isActive.equals(true);
        }

        if (normalizedQuery.isNotEmpty) {
          predicate =
              predicate &
              (table.studentName.contains(normalizedQuery) |
                  table.supportStudentNumber.contains(normalizedQuery));
        }

        return predicate;
      })
      ..orderBy([
        (table) => OrderingTerm.asc(table.displayOrder),
        (table) => OrderingTerm.asc(table.id),
      ]);

    final rows = await statement.get();

    return rows.map(_mapStudent).toList(growable: false);
  }

  @override
  Future<StudentRecord> create({
    required int halaqahId,
    required StudentWriteData data,
    required String activeFromDate,
  }) {
    return _database.transaction(() async {
      final lastStudents =
          await (_database.select(_database.students)
                ..where((table) => table.halaqahId.equals(halaqahId))
                ..orderBy([(table) => OrderingTerm.desc(table.displayOrder)])
                ..limit(1))
              .get();

      final displayOrder = lastStudents.isEmpty
          ? 1
          : lastStudents.single.displayOrder + 1;

      final studentId = await _database
          .into(_database.students)
          .insert(
            StudentsCompanion.insert(
              halaqahId: halaqahId,
              studentName: data.studentName,
              fatherName: data.fatherName,
              ageYears: data.ageYears,
              guardianCountryCode: data.guardianCountryCode,
              guardianNationalNumber: data.guardianNationalNumber,
              previousMemorizationText: data.previousMemorizationText,
              note: Value<String?>(data.note),
              supportStudentNumber: Value<String?>(data.supportStudentNumber),
              displayOrder: displayOrder,
            ),
          );

      await _database
          .into(_database.studentActivityPeriods)
          .insert(
            StudentActivityPeriodsCompanion.insert(
              studentId: studentId,
              activeFromDate: activeFromDate,
            ),
          );

      final created = await findById(studentId);

      if (created == null) {
        throw StateError('Created student $studentId could not be read back.');
      }

      return created;
    });
  }

  @override
  Future<StudentRecord> update({
    required int studentId,
    required StudentWriteData data,
  }) {
    return _database.transaction(() async {
      final affected =
          await (_database.update(
            _database.students,
          )..where((table) => table.id.equals(studentId))).write(
            StudentsCompanion(
              studentName: Value<String>(data.studentName),
              fatherName: Value<String>(data.fatherName),
              ageYears: Value<int>(data.ageYears),
              guardianCountryCode: Value<String>(data.guardianCountryCode),
              guardianNationalNumber: Value<String>(
                data.guardianNationalNumber,
              ),
              previousMemorizationText: Value<String>(
                data.previousMemorizationText,
              ),
              note: Value<String?>(data.note),
              supportStudentNumber: Value<String?>(data.supportStudentNumber),
            ),
          );

      if (affected != 1) {
        throw StateError('Student $studentId was not found.');
      }

      final updated = await findById(studentId);

      if (updated == null) {
        throw StateError('Updated student $studentId could not be read back.');
      }

      return updated;
    });
  }

  @override
  Future<StudentRecord> archive({
    required int studentId,
    required int openActivityPeriodId,
    required String activeToDate,
    required DateTime archivedAtUtc,
  }) {
    return _database.transaction(() async {
      final student = await (_database.select(
        _database.students,
      )..where((table) => table.id.equals(studentId))).getSingleOrNull();

      if (student == null) {
        throw StateError('Student $studentId was not found.');
      }

      if (!student.isActive) {
        throw StateError('Student $studentId is already archived.');
      }

      final period =
          await (_database.select(_database.studentActivityPeriods)
                ..where((table) => table.id.equals(openActivityPeriodId)))
              .getSingleOrNull();

      if (period == null ||
          period.studentId != studentId ||
          period.activeToDate != null) {
        throw StateError('The required open activity period is not valid.');
      }

      final periodAffected =
          await (_database.update(
            _database.studentActivityPeriods,
          )..where((table) => table.id.equals(openActivityPeriodId))).write(
            StudentActivityPeriodsCompanion(
              activeToDate: Value<String?>(activeToDate),
            ),
          );

      if (periodAffected != 1) {
        throw StateError('Student activity period could not be closed.');
      }

      final studentAffected =
          await (_database.update(
            _database.students,
          )..where((table) => table.id.equals(studentId))).write(
            StudentsCompanion(
              isActive: const Value<bool>(false),
              archivedAtUtc: Value<DateTime?>(archivedAtUtc),
            ),
          );

      if (studentAffected != 1) {
        throw StateError('Student $studentId could not be archived.');
      }

      final archived = await findById(studentId);

      if (archived == null) {
        throw StateError('Archived student $studentId could not be read back.');
      }

      return archived;
    });
  }

  @override
  Future<StudentRecord> reactivate({
    required int studentId,
    required String activeFromDate,
    required int? periodIdToReopen,
  }) {
    return _database.transaction(() async {
      final student = await (_database.select(
        _database.students,
      )..where((table) => table.id.equals(studentId))).getSingleOrNull();

      if (student == null) {
        throw StateError('Student $studentId was not found.');
      }

      if (student.isActive) {
        throw StateError('Student $studentId is already active.');
      }

      if (periodIdToReopen != null) {
        final period =
            await (_database.select(_database.studentActivityPeriods)
                  ..where((table) => table.id.equals(periodIdToReopen)))
                .getSingleOrNull();

        if (period == null ||
            period.studentId != studentId ||
            period.activeToDate == null) {
          throw StateError(
            'The activity period selected for reopening is invalid.',
          );
        }

        final periodAffected =
            await (_database.update(
              _database.studentActivityPeriods,
            )..where((table) => table.id.equals(periodIdToReopen))).write(
              const StudentActivityPeriodsCompanion(
                activeToDate: Value<String?>(null),
              ),
            );

        if (periodAffected != 1) {
          throw StateError('Student activity period could not be reopened.');
        }
      } else {
        await _database
            .into(_database.studentActivityPeriods)
            .insert(
              StudentActivityPeriodsCompanion.insert(
                studentId: studentId,
                activeFromDate: activeFromDate,
              ),
            );
      }

      final studentAffected =
          await (_database.update(
            _database.students,
          )..where((table) => table.id.equals(studentId))).write(
            const StudentsCompanion(
              isActive: Value<bool>(true),
              archivedAtUtc: Value<DateTime?>(null),
            ),
          );

      if (studentAffected != 1) {
        throw StateError('Student $studentId could not be reactivated.');
      }

      final reactivated = await findById(studentId);

      if (reactivated == null) {
        throw StateError(
          'Reactivated student $studentId could not be read back.',
        );
      }

      return reactivated;
    });
  }

  StudentProgressPlanRecord _mapProgressPlan(StudentProgressPlan row) {
    return StudentProgressPlanRecord(
      studentId: row.studentId,
      currentJuz: row.currentJuz,
      dailyPlanText: row.dailyPlanText,
    );
  }

  StudentRecord _mapStudent(Student row) {
    return StudentRecord(
      id: row.id,
      halaqahId: row.halaqahId,
      studentName: row.studentName,
      fatherName: row.fatherName,
      ageYears: row.ageYears,
      guardianCountryCode: row.guardianCountryCode,
      guardianNationalNumber: row.guardianNationalNumber,
      previousMemorizationText: row.previousMemorizationText,
      note: row.note,
      supportStudentNumber: row.supportStudentNumber,
      displayOrder: row.displayOrder,
      isActive: row.isActive,
      archivedAtUtc: row.archivedAtUtc,
    );
  }
}
