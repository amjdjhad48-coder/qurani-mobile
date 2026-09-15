import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/database_migrations.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/core/shared/core_providers.dart';

import '../../helpers/fake_clock.dart';
import '../../helpers/provider_container.dart';
import '../../helpers/test_database.dart';

void main() {
  group('Core test helpers', () {
    test('FakeClock provides deterministic event and local-date values', () {
      final clock = FakeClock(
        nowUtc: DateTime.utc(2026, 9, 3, 8, 30),
        todayLocal: DateTime(2026, 9, 3, 17, 15),
      );

      expect(clock.nowUtc(), DateTime.utc(2026, 9, 3, 8, 30));
      expect(clock.todayLocal(), DateTime(2026, 9, 3));
    });

    test('createTestProviderContainer supports Riverpod overrides', () {
      final fixedClock = _FixedClock();
      final container = createTestProviderContainer(
        overrides: <Override>[clockProvider.overrideWithValue(fixedClock)],
      );

      expect(identical(container.read(clockProvider), fixedClock), isTrue);
      expect(container.read(quranSurahsProvider), hasLength(114));
    });

    test(
      'createTestDatabase opens the current in-memory production schema',
      () async {
        final database = createTestDatabase();

        await database.customSelect('SELECT 1;').get();
        await expectLater(verifyDatabaseAfterSchemaChange(database), completes);

        final userTables = await database
            .customSelect(
              "SELECT name FROM sqlite_master "
              "WHERE type = 'table' "
              "AND name NOT LIKE 'sqlite_%' "
              "ORDER BY name;",
            )
            .get();

        expect(
          userTables.map((row) => row.read<String>('name')).toList(),
          <String>[
            'attendance_records',
            'halaqah_days',
            'halaqahs',
            'parent_follow_ups',
            'recitations',
            'student_activity_periods',
            'student_progress_plans',
            'students',
            'support_program_periods',
            'support_program_settings',
          ],
        );

        final foreignKeys = await database
            .customSelect('PRAGMA foreign_keys;')
            .get();

        expect(foreignKeys, hasLength(1));
        expect(foreignKeys.single.data.values.single, 1);
      },
    );
  });
}

final class _FixedClock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 3, 9);

  @override
  DateTime todayLocal() => DateTime(2026, 9, 3);
}
