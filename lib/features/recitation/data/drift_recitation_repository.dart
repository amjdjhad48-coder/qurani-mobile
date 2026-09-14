import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';
import 'package:qurani/features/recitation/domain/recitation_repository.dart';

final class DriftRecitationRepository implements RecitationRepository {
  DriftRecitationRepository(this._database);

  final AppDatabase _database;

  @override
  Future<RecitationRecord> create({
    required int dayId,
    required int studentId,
    required RecitationWriteData data,
  }) async {
    final plannedRange = data.plannedRange;

    final id = await _database
        .into(_database.recitations)
        .insert(
          RecitationsCompanion.insert(
            dayId: dayId,
            studentId: studentId,
            type: data.type.storageValue,
            startSurah: data.actualRange.start.surahNumber,
            startAyah: data.actualRange.start.ayahNumber,
            endSurah: data.actualRange.end.surahNumber,
            endAyah: data.actualRange.end.ayahNumber,
            facesQuarterAchieved: data.facesQuarterAchieved,
            evaluation: data.evaluation.storageValue,
            errorCount: Value<int>(data.errorCount),
            note: Value<String?>(data.note),
            plannedStartSurah: Value<int?>(plannedRange?.start.surahNumber),
            plannedStartAyah: Value<int?>(plannedRange?.start.ayahNumber),
            plannedEndSurah: Value<int?>(plannedRange?.end.surahNumber),
            plannedEndAyah: Value<int?>(plannedRange?.end.ayahNumber),
          ),
        );

    final created = await (_database.select(
      _database.recitations,
    )..where((table) => table.id.equals(id))).getSingle();

    return _map(created);
  }

  @override
  Future<RecitationRecord> update({
    required int recitationId,
    required RecitationWriteData data,
  }) async {
    final plannedRange = data.plannedRange;

    final affected =
        await (_database.update(
          _database.recitations,
        )..where((table) => table.id.equals(recitationId))).write(
          RecitationsCompanion(
            type: Value<String>(data.type.storageValue),
            startSurah: Value<int>(data.actualRange.start.surahNumber),
            startAyah: Value<int>(data.actualRange.start.ayahNumber),
            endSurah: Value<int>(data.actualRange.end.surahNumber),
            endAyah: Value<int>(data.actualRange.end.ayahNumber),
            facesQuarterAchieved: Value<int>(data.facesQuarterAchieved),
            evaluation: Value<String>(data.evaluation.storageValue),
            errorCount: Value<int>(data.errorCount),
            note: Value<String?>(data.note),
            plannedStartSurah: Value<int?>(plannedRange?.start.surahNumber),
            plannedStartAyah: Value<int?>(plannedRange?.start.ayahNumber),
            plannedEndSurah: Value<int?>(plannedRange?.end.surahNumber),
            plannedEndAyah: Value<int?>(plannedRange?.end.ayahNumber),
          ),
        );

    if (affected != 1) {
      throw StateError('Recitation $recitationId could not be updated.');
    }

    final updated = await (_database.select(
      _database.recitations,
    )..where((table) => table.id.equals(recitationId))).getSingle();

    return _map(updated);
  }

  @override
  Future<void> deleteById(int recitationId) async {
    final affected = await (_database.delete(
      _database.recitations,
    )..where((table) => table.id.equals(recitationId))).go();

    if (affected != 1) {
      throw StateError('Recitation $recitationId could not be deleted.');
    }
  }

  @override
  Future<RecitationRecord?> findById(int recitationId) async {
    final row = await (_database.select(
      _database.recitations,
    )..where((table) => table.id.equals(recitationId))).getSingleOrNull();

    return row == null ? null : _map(row);
  }

  @override
  Future<List<RecitationRecord>> listForDayStudent({
    required int dayId,
    required int studentId,
  }) async {
    final rows =
        await (_database.select(_database.recitations)
              ..where(
                (table) =>
                    table.dayId.equals(dayId) &
                    table.studentId.equals(studentId),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.id)]))
            .get();

    return rows.map(_map).toList(growable: false);
  }

  @override
  Future<RecitationDerivedTotals> totalsForStudent({
    required int halaqahId,
    required int studentId,
  }) async {
    final row = await _database
        .customSelect(
          '''
SELECT
  COALESCE(
    SUM(
      CASE
        WHEN r.type = 'new_memorization'
        THEN r.faces_quarter_achieved
        ELSE 0
      END
    ),
    0
  ) AS new_total,
  COALESCE(
    SUM(
      CASE
        WHEN r.type = 'revision'
        THEN r.faces_quarter_achieved
        ELSE 0
      END
    ),
    0
  ) AS revision_total
FROM recitations AS r
JOIN halaqah_days AS d
  ON d.id = r.day_id
WHERE d.halaqah_id = ?
  AND r.student_id = ?;
''',
          variables: <Variable<Object>>[
            Variable<int>(halaqahId),
            Variable<int>(studentId),
          ],
          readsFrom: <ResultSetImplementation>{
            _database.recitations,
            _database.halaqahDays,
          },
        )
        .getSingle();

    return RecitationDerivedTotals(
      newMemorizationQuarterFaces: row.read<int>('new_total'),
      revisionQuarterFaces: row.read<int>('revision_total'),
    );
  }

  @override
  Future<RecitationDerivedTotals> totalsForDayStudent({
    required int dayId,
    required int studentId,
  }) async {
    final row = await _database
        .customSelect(
          '''
SELECT
  COALESCE(
    SUM(
      CASE
        WHEN type = 'new_memorization'
        THEN faces_quarter_achieved
        ELSE 0
      END
    ),
    0
  ) AS new_total,
  COALESCE(
    SUM(
      CASE
        WHEN type = 'revision'
        THEN faces_quarter_achieved
        ELSE 0
      END
    ),
    0
  ) AS revision_total
FROM recitations
WHERE day_id = ?
  AND student_id = ?;
''',
          variables: <Variable<Object>>[
            Variable<int>(dayId),
            Variable<int>(studentId),
          ],
          readsFrom: <ResultSetImplementation>{_database.recitations},
        )
        .getSingle();

    return RecitationDerivedTotals(
      newMemorizationQuarterFaces: row.read<int>('new_total'),
      revisionQuarterFaces: row.read<int>('revision_total'),
    );
  }

  RecitationRecord _map(Recitation row) {
    final plannedValues = <int?>[
      row.plannedStartSurah,
      row.plannedStartAyah,
      row.plannedEndSurah,
      row.plannedEndAyah,
    ];

    final hasAnyPlannedValue = plannedValues.any((value) => value != null);
    final hasEveryPlannedValue = plannedValues.every((value) => value != null);

    if (hasAnyPlannedValue && !hasEveryPlannedValue) {
      throw StateError(
        'Recitation ${row.id} has a partial planned Quran range.',
      );
    }

    final plannedRange = hasEveryPlannedValue
        ? QuranRange(
            start: QuranPosition(
              surahNumber: row.plannedStartSurah!,
              ayahNumber: row.plannedStartAyah!,
            ),
            end: QuranPosition(
              surahNumber: row.plannedEndSurah!,
              ayahNumber: row.plannedEndAyah!,
            ),
          )
        : null;

    return RecitationRecord(
      id: row.id,
      dayId: row.dayId,
      studentId: row.studentId,
      type: RecitationType.fromStorage(row.type),
      actualRange: QuranRange(
        start: QuranPosition(
          surahNumber: row.startSurah,
          ayahNumber: row.startAyah,
        ),
        end: QuranPosition(surahNumber: row.endSurah, ayahNumber: row.endAyah),
      ),
      facesQuarterAchieved: row.facesQuarterAchieved,
      evaluation: RecitationEvaluation.fromStorage(row.evaluation),
      errorCount: row.errorCount,
      note: row.note,
      plannedRange: plannedRange,
    );
  }
}
