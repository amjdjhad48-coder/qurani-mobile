import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';

void main() {
  group('Package 2 setup schema', () {
    test('persists the required Halaqah identity fields', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final now = DateTime.utc(2026, 9, 4, 14);

        final id = await database
            .into(database.halaqahs)
            .insert(
              HalaqahsCompanion.insert(
                teacherName: 'عبدالحكيم قائد',
                halaqahName: 'حلقة ذي النورين',
                centerName: 'المركز الرئيسي',
                createdAtUtc: now,
                updatedAtUtc: now,
              ),
            );

        final row = await (database.select(
          database.halaqahs,
        )..where((table) => table.id.equals(id))).getSingle();

        expect(row.teacherName, 'عبدالحكيم قائد');
        expect(row.halaqahName, 'حلقة ذي النورين');
        expect(row.centerName, 'المركز الرئيسي');
        expect(row.createdAtUtc, now);
        expect(row.createdAtUtc.isUtc, isTrue);
        expect(row.updatedAtUtc, now);
        expect(row.updatedAtUtc.isUtc, isTrue);
      } finally {
        await database.close();
      }
    });

    test(
      'stores event timestamps as ISO-8601 text and preserves UTC',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final now = DateTime.utc(2026, 9, 4, 14, 0, 0, 123);

          final id = await database
              .into(database.halaqahs)
              .insert(
                HalaqahsCompanion.insert(
                  teacherName: 'معلم',
                  halaqahName: 'حلقة',
                  centerName: 'مركز',
                  createdAtUtc: now,
                  updatedAtUtc: now,
                ),
              );

          final raw = await database
              .customSelect(
                'SELECT typeof(created_at_utc) AS storage_type, '
                'created_at_utc AS raw_value '
                'FROM halaqahs WHERE id = ?;',
                variables: <Variable<Object>>[Variable<int>(id)],
              )
              .getSingle();

          expect(raw.read<String>('storage_type'), 'text');

          final rawValue = raw.read<String>('raw_value');
          expect(rawValue.endsWith('Z'), isTrue);

          final row = await (database.select(
            database.halaqahs,
          )..where((table) => table.id.equals(id))).getSingle();

          expect(row.createdAtUtc, now);
          expect(row.createdAtUtc.isUtc, isTrue);
          expect(row.createdAtUtc.millisecond, 123);
        } finally {
          await database.close();
        }
      },
    );

    test('requires non-empty teacher, halaqah, and center names', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final now = DateTime.utc(2026, 9, 4, 14);

        await expectLater(
          database
              .into(database.halaqahs)
              .insert(
                HalaqahsCompanion.insert(
                  teacherName: '',
                  halaqahName: 'حلقة',
                  centerName: 'مركز',
                  createdAtUtc: now,
                  updatedAtUtc: now,
                ),
              ),
          throwsA(anything),
        );

        await expectLater(
          database
              .into(database.halaqahs)
              .insert(
                HalaqahsCompanion.insert(
                  teacherName: 'معلم',
                  halaqahName: '',
                  centerName: 'مركز',
                  createdAtUtc: now,
                  updatedAtUtc: now,
                ),
              ),
          throwsA(anything),
        );

        await expectLater(
          database
              .into(database.halaqahs)
              .insert(
                HalaqahsCompanion.insert(
                  teacherName: 'معلم',
                  halaqahName: 'حلقة',
                  centerName: '',
                  createdAtUtc: now,
                  updatedAtUtc: now,
                ),
              ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('support settings allow only the approved states', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database);

        for (final state in <String>[
          'disabled',
          'pending_activation',
          'enabled',
        ]) {
          final secondHalaqahId = state == 'disabled'
              ? halaqahId
              : await _insertHalaqah(database, suffix: state);

          await database
              .into(database.supportProgramSettings)
              .insert(
                SupportProgramSettingsCompanion.insert(
                  halaqahId: secondHalaqahId,
                  status: state,
                  organizationName: state == 'disabled'
                      ? const Value<String?>(null)
                      : Value<String>('جهة $state'),
                  createdAtUtc: DateTime.utc(2026, 9, 4, 14),
                  updatedAtUtc: DateTime.utc(2026, 9, 4, 14),
                ),
              );
        }

        final invalidHalaqahId = await _insertHalaqah(
          database,
          suffix: 'invalid',
        );

        await expectLater(
          database
              .into(database.supportProgramSettings)
              .insert(
                SupportProgramSettingsCompanion.insert(
                  halaqahId: invalidHalaqahId,
                  status: 'unknown',
                  organizationName: const Value<String>('جهة'),
                  createdAtUtc: DateTime.utc(2026, 9, 4, 14),
                  updatedAtUtc: DateTime.utc(2026, 9, 4, 14),
                ),
              ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('support settings keep one current row per halaqah', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database);
        final now = DateTime.utc(2026, 9, 4, 14);

        await database
            .into(database.supportProgramSettings)
            .insert(
              SupportProgramSettingsCompanion.insert(
                halaqahId: halaqahId,
                status: 'disabled',
                organizationName: const Value<String?>(null),
                createdAtUtc: now,
                updatedAtUtc: now,
              ),
            );

        await expectLater(
          database
              .into(database.supportProgramSettings)
              .insert(
                SupportProgramSettingsCompanion.insert(
                  halaqahId: halaqahId,
                  status: 'pending_activation',
                  organizationName: const Value<String>('جهة جديدة'),
                  createdAtUtc: now,
                  updatedAtUtc: now,
                ),
              ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test(
      'disabled support has no current organization and active states require one',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final now = DateTime.utc(2026, 9, 4, 14);

          final disabledHalaqah = await _insertHalaqah(
            database,
            suffix: 'disabled',
          );

          await expectLater(
            database
                .into(database.supportProgramSettings)
                .insert(
                  SupportProgramSettingsCompanion.insert(
                    halaqahId: disabledHalaqah,
                    status: 'disabled',
                    organizationName: const Value<String>('جهة قديمة'),
                    createdAtUtc: now,
                    updatedAtUtc: now,
                  ),
                ),
            throwsA(anything),
          );

          final pendingHalaqah = await _insertHalaqah(
            database,
            suffix: 'pending',
          );

          await expectLater(
            database
                .into(database.supportProgramSettings)
                .insert(
                  SupportProgramSettingsCompanion.insert(
                    halaqahId: pendingHalaqah,
                    status: 'pending_activation',
                    organizationName: const Value<String?>(null),
                    createdAtUtc: now,
                    updatedAtUtc: now,
                  ),
                ),
            throwsA(anything),
          );

          final enabledHalaqah = await _insertHalaqah(
            database,
            suffix: 'enabled',
          );

          await expectLater(
            database
                .into(database.supportProgramSettings)
                .insert(
                  SupportProgramSettingsCompanion.insert(
                    halaqahId: enabledHalaqah,
                    status: 'enabled',
                    organizationName: const Value<String>('   '),
                    createdAtUtc: now,
                    updatedAtUtc: now,
                  ),
                ),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'support history preserves each organization name across sponsor changes',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database);
          final now = DateTime.utc(2026, 9, 4, 14);

          final settingsId = await database
              .into(database.supportProgramSettings)
              .insert(
                SupportProgramSettingsCompanion.insert(
                  halaqahId: halaqahId,
                  status: 'pending_activation',
                  organizationName: const Value<String>('الجهة أ'),
                  createdAtUtc: now,
                  updatedAtUtc: now,
                ),
              );

          await database
              .into(database.supportProgramPeriods)
              .insert(
                SupportProgramPeriodsCompanion.insert(
                  halaqahId: halaqahId,
                  organizationName: 'الجهة أ',
                  startedAtUtc: DateTime.utc(2026, 1, 1),
                  endedAtUtc: Value<DateTime?>(
                    DateTime.utc(2026, 6, 30, 23, 59),
                  ),
                ),
              );

          await (database.update(
            database.supportProgramSettings,
          )..where((table) => table.id.equals(settingsId))).write(
            SupportProgramSettingsCompanion(
              status: const Value<String>('pending_activation'),
              organizationName: const Value<String?>('الجهة ب'),
              updatedAtUtc: Value<DateTime>(now),
            ),
          );

          await database
              .into(database.supportProgramPeriods)
              .insert(
                SupportProgramPeriodsCompanion.insert(
                  halaqahId: halaqahId,
                  organizationName: 'الجهة ب',
                  startedAtUtc: DateTime.utc(2026, 8, 1),
                  endedAtUtc: const Value<DateTime?>(null),
                ),
              );

          final periods = await (database.select(
            database.supportProgramPeriods,
          )..where((table) => table.halaqahId.equals(halaqahId))).get();

          periods.sort((left, right) => left.id.compareTo(right.id));

          expect(periods, hasLength(2));
          expect(
            periods.map((period) => period.organizationName).toList(),
            containsAllInOrder(<String>['الجهة أ', 'الجهة ب']),
          );

          final oldPeriod = periods.firstWhere(
            (period) => period.organizationName == 'الجهة أ',
          );
          expect(oldPeriod.endedAtUtc, isNotNull);

          final newPeriod = periods.firstWhere(
            (period) => period.organizationName == 'الجهة ب',
          );
          expect(newPeriod.endedAtUtc, isNull);
        } finally {
          await database.close();
        }
      },
    );

    test('support period end must be after its start', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database);

        await expectLater(
          database
              .into(database.supportProgramPeriods)
              .insert(
                SupportProgramPeriodsCompanion.insert(
                  halaqahId: halaqahId,
                  organizationName: 'الجهة',
                  startedAtUtc: DateTime.utc(2026, 9, 1),
                  endedAtUtc: Value<DateTime?>(DateTime.utc(2026, 8, 31)),
                ),
              ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });
  });
}

Future<int> _insertHalaqah(AppDatabase database, {String suffix = ''}) {
  final now = DateTime.utc(2026, 9, 4, 14);

  return database
      .into(database.halaqahs)
      .insert(
        HalaqahsCompanion.insert(
          teacherName: 'معلم$suffix',
          halaqahName: 'حلقة$suffix',
          centerName: 'مركز$suffix',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );
}
