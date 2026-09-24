import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';

const String _shaA =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const String _shaB =
    'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

void main() {
  group('Package 8 report export artifact schema', () {
    test(
      'creates the artifact table with the approved metadata columns',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await database.customSelect('SELECT 1;').get();

          final tableRows = await database
              .customSelect(
                "SELECT name FROM sqlite_master "
                "WHERE type = 'table' AND name = 'report_export_artifacts';",
              )
              .get();

          expect(tableRows, hasLength(1));

          final columns = await database
              .customSelect('PRAGMA table_info(report_export_artifacts);')
              .get();

          expect(
            columns.map((row) => row.read<String>('name')).toList(),
            <String>[
              'id',
              'weekly_report_id',
              'monthly_report_id',
              'format',
              'internal_path',
              'sha256',
              'template_version',
              'size_bytes',
            ],
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'enforces weekly XOR monthly identity, format, hash, version, size and current artifact uniqueness',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seedApprovedReports(database);

          await _insertArtifact(
            database,
            weeklyReportId: 1,
            format: 'excel',
            internalPath: 'reports/weekly/current.xlsx',
            sha256: _shaA,
          );

          await expectLater(
            _insertArtifact(
              database,
              weeklyReportId: 1,
              format: 'excel',
              internalPath: 'reports/weekly/duplicate.xlsx',
              sha256: _shaB,
            ),
            throwsA(anything),
          );

          await _insertArtifact(
            database,
            weeklyReportId: 1,
            format: 'pdf',
            internalPath: 'reports/weekly/current.pdf',
            sha256: _shaB,
          );

          await _insertArtifact(
            database,
            monthlyReportId: 1,
            format: 'excel',
            internalPath: 'reports/monthly/current.xlsx',
            sha256: _shaA,
          );

          await expectLater(
            _insertArtifact(
              database,
              format: 'excel',
              internalPath: 'reports/no-owner.xlsx',
              sha256: _shaA,
            ),
            throwsA(anything),
          );

          await expectLater(
            _insertArtifact(
              database,
              weeklyReportId: 1,
              monthlyReportId: 1,
              format: 'excel',
              internalPath: 'reports/two-owners.xlsx',
              sha256: _shaA,
            ),
            throwsA(anything),
          );

          await expectLater(
            _insertArtifact(
              database,
              monthlyReportId: 1,
              format: 'csv',
              internalPath: 'reports/unsupported.csv',
              sha256: _shaA,
            ),
            throwsA(anything),
          );

          await expectLater(
            _insertArtifact(
              database,
              monthlyReportId: 1,
              format: 'pdf',
              internalPath: '   ',
              sha256: _shaA,
            ),
            throwsA(anything),
          );

          await expectLater(
            _insertArtifact(
              database,
              monthlyReportId: 1,
              format: 'pdf',
              internalPath: 'reports/bad-hash.pdf',
              sha256: List<String>.filled(64, 'z').join(),
            ),
            throwsA(anything),
          );

          await expectLater(
            _insertArtifact(
              database,
              monthlyReportId: 1,
              format: 'pdf',
              internalPath: 'reports/bad-version.pdf',
              sha256: _shaB,
              templateVersion: 0,
            ),
            throwsA(anything),
          );

          await expectLater(
            _insertArtifact(
              database,
              monthlyReportId: 1,
              format: 'pdf',
              internalPath: 'reports/empty.pdf',
              sha256: _shaB,
              sizeBytes: 0,
            ),
            throwsA(anything),
          );

          await expectLater(
            _insertArtifact(
              database,
              weeklyReportId: 999,
              format: 'pdf',
              internalPath: 'reports/orphan.pdf',
              sha256: _shaB,
            ),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }
      },
    );

    test('deleting a report cascades only its internal artifacts', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedApprovedReports(database);

        await _insertArtifact(
          database,
          weeklyReportId: 1,
          format: 'excel',
          internalPath: 'reports/weekly/current.xlsx',
          sha256: _shaA,
        );

        await _insertArtifact(
          database,
          monthlyReportId: 1,
          format: 'excel',
          internalPath: 'reports/monthly/current.xlsx',
          sha256: _shaB,
        );

        await database.customStatement(
          'DELETE FROM support_weekly_reports WHERE id = 1;',
        );

        final rows = await database
            .customSelect(
              'SELECT weekly_report_id, monthly_report_id '
              'FROM report_export_artifacts ORDER BY id;',
            )
            .get();

        expect(rows, hasLength(1));
        expect(rows.single.readNullable<int>('weekly_report_id'), isNull);
        expect(rows.single.read<int>('monthly_report_id'), 1);
      } finally {
        await database.close();
      }
    });
  });
}

Future<void> _seedApprovedReports(AppDatabase database) async {
  await database.customSelect('SELECT 1;').get();

  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'المعلم', 'الحلقة', 'المركز', "
    "'2026-09-01T10:00:00.000Z', "
    "'2026-09-01T10:00:00.000Z'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO support_weekly_reports ("
    "id, halaqah_id, week_start_date, week_end_date, status, "
    "teacher_name_snapshot, halaqah_name_snapshot, "
    "organization_name_snapshot, policy_version, template_version, "
    "source_fingerprint, approved_at_utc"
    ") VALUES ("
    "1, 1, '2026-09-12', '2026-09-16', 'approved', "
    "'المعلم', 'الحلقة', 'الجهة', 1, 1, "
    "'weekly-fingerprint', '2026-09-17T10:00:00.000Z'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO support_monthly_reports ("
    "id, halaqah_id, month_start_date, month_end_date, status, "
    "teacher_name_snapshot, halaqah_name_snapshot, "
    "organization_name_snapshot, policy_version, template_version, "
    "source_fingerprint, approved_at_utc"
    ") VALUES ("
    "1, 1, '2026-09-01', '2026-09-30', 'approved', "
    "'المعلم', 'الحلقة', 'الجهة', 1, 1, "
    "'monthly-fingerprint', '2026-10-01T10:00:00.000Z'"
    ");",
  );
}

Future<void> _insertArtifact(
  AppDatabase database, {
  int? weeklyReportId,
  int? monthlyReportId,
  required String format,
  required String internalPath,
  required String sha256,
  int templateVersion = 1,
  int sizeBytes = 1024,
}) {
  return database.customStatement(
    'INSERT INTO report_export_artifacts ('
    'weekly_report_id, monthly_report_id, format, internal_path, '
    'sha256, template_version, size_bytes'
    ') VALUES (?, ?, ?, ?, ?, ?, ?);',
    <Object?>[
      weeklyReportId,
      monthlyReportId,
      format,
      internalPath,
      sha256,
      templateVersion,
      sizeBytes,
    ],
  );
}
