import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/package8_support_report_artifact_lifecycle.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/data/drift_support_report_artifact_reference_repository.dart';
import 'package:qurani/features/reports/data/support_report_artifact_file_store.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

void main() {
  group('Package 8 report artifact lifecycle', () {
    test(
      'keeps referenced content-addressed artifacts and deletes only unreferenced files',
      () async {
        final temp = await Directory.systemTemp.createTemp(
          'qurani_report_artifact_lifecycle_',
        );
        addTearDown(() async {
          if (await temp.exists()) {
            await temp.delete(recursive: true);
          }
        });

        final database = AppDatabase(NativeDatabase.memory());
        addTearDown(database.close);

        final weeklyPeriod = WeeklySupportReportPeriod.forDate(
          DateTime(2026, 9, 14),
        );
        final monthlyPeriod = MonthlySupportReportPeriod.forDate(
          DateTime(2026, 9, 14),
        );
        final ids = await _seedReports(
          database,
          weeklyPeriod: weeklyPeriod,
          monthlyPeriod: monthlyPeriod,
        );

        final referencedWeeklyHash = _hash('a');
        final referencedMonthlyHash = _hash('b');
        final orphanHash = _hash('c');
        final preparedOrphanHash = _hash('d');
        final stagingHash = _hash('e');

        await database
            .into(database.reportExportArtifacts)
            .insert(
              ReportExportArtifactsCompanion.insert(
                weeklyReportId: Value(ids.weeklyId),
                format: SupportReportExportFormat.excel.storageValue,
                internalPath: 'report_artifacts/$referencedWeeklyHash.xlsx',
                sha256: referencedWeeklyHash,
                templateVersion: 1,
                sizeBytes: 3,
              ),
            );
        await database
            .into(database.reportExportArtifacts)
            .insert(
              ReportExportArtifactsCompanion.insert(
                monthlyReportId: Value(ids.monthlyId),
                format: SupportReportExportFormat.excel.storageValue,
                internalPath: 'report_artifacts/$referencedMonthlyHash.xlsx',
                sha256: referencedMonthlyHash,
                templateVersion: 1,
                sizeBytes: 3,
              ),
            );

        final artifactsDirectory = Directory(
          '${temp.path}${Platform.pathSeparator}'
          '${SupportReportArtifactFileStore.artifactsDirectoryName}',
        );
        await artifactsDirectory.create(recursive: true);

        final referencedWeeklyFile = File(
          '${artifactsDirectory.path}${Platform.pathSeparator}'
          '$referencedWeeklyHash.xlsx',
        );
        final referencedMonthlyFile = File(
          '${artifactsDirectory.path}${Platform.pathSeparator}'
          '$referencedMonthlyHash.xlsx',
        );
        final orphanFile = File(
          '${artifactsDirectory.path}${Platform.pathSeparator}'
          '$orphanHash.xlsx',
        );
        final preparedOrphanFile = File(
          '${artifactsDirectory.path}${Platform.pathSeparator}'
          '$preparedOrphanHash.xlsx',
        );
        final stagingFile = File(
          '${artifactsDirectory.path}${Platform.pathSeparator}'
          '$stagingHash.xlsx.staging.123',
        );
        final unknownFile = File(
          '${artifactsDirectory.path}${Platform.pathSeparator}'
          'do-not-touch.txt',
        );

        for (final file in <File>[
          referencedWeeklyFile,
          referencedMonthlyFile,
          orphanFile,
          preparedOrphanFile,
          stagingFile,
          unknownFile,
        ]) {
          await file.writeAsBytes(<int>[1, 2, 3], flush: true);
        }

        final references = DriftSupportReportArtifactReferenceRepository(
          database,
        );
        final store = SupportReportArtifactFileStore(
          applicationSupportDirectory: temp,
        );
        final lifecycle = Package8SupportReportArtifactLifecycle(
          referenceRepository: references,
          fileCleanup: store,
        );

        final weeklyMetadata = await lifecycle.currentWeeklyPrimaryArtifact(
          halaqahId: 1,
          period: weeklyPeriod,
        );
        final monthlyMetadata = await lifecycle.currentMonthlyPrimaryArtifact(
          halaqahId: 1,
          period: monthlyPeriod,
        );

        expect(weeklyMetadata, isNotNull);
        expect(
          weeklyMetadata!.internalPath,
          'report_artifacts/$referencedWeeklyHash.xlsx',
        );
        expect(monthlyMetadata, isNotNull);
        expect(
          monthlyMetadata!.internalPath,
          'report_artifacts/$referencedMonthlyHash.xlsx',
        );

        await lifecycle.cleanupPreparedIfUnreferenced(
          _prepared(referencedWeeklyHash),
        );
        expect(await referencedWeeklyFile.exists(), isTrue);

        await lifecycle.cleanupPreparedIfUnreferenced(
          _prepared(preparedOrphanHash),
        );
        expect(await preparedOrphanFile.exists(), isFalse);

        final deletedOrphans = await lifecycle.cleanupOrphans();

        expect(deletedOrphans, 2);
        expect(await referencedWeeklyFile.exists(), isTrue);
        expect(await referencedMonthlyFile.exists(), isTrue);
        expect(await orphanFile.exists(), isFalse);
        expect(await stagingFile.exists(), isFalse);
        expect(await unknownFile.exists(), isTrue);

        await (database.delete(database.reportExportArtifacts)..where(
              (table) => table.internalPath.equals(weeklyMetadata.internalPath),
            ))
            .go();

        await lifecycle.cleanupStoredIfUnreferenced(weeklyMetadata);
        expect(await referencedWeeklyFile.exists(), isFalse);
        expect(await referencedMonthlyFile.exists(), isTrue);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'file cleanup rejects a non-canonical private artifact path',
      () async {
        final temp = await Directory.systemTemp.createTemp(
          'qurani_report_artifact_path_guard_',
        );
        addTearDown(() async {
          if (await temp.exists()) {
            await temp.delete(recursive: true);
          }
        });

        final store = SupportReportArtifactFileStore(
          applicationSupportDirectory: temp,
        );

        await expectLater(
          store.deleteArtifactIfExists(
            internalPath: '../escape.xlsx',
            sha256: _hash('f'),
          ),
          throwsArgumentError,
        );
      },
    );
  });
}

PreparedPrimaryReportArtifact _prepared(String hash) {
  return PreparedPrimaryReportArtifact(
    kind: SupportReportArtifactKind.weekly,
    sourceFingerprint: 'source',
    policyVersion: 1,
    templateVersion: 1,
    internalPath: 'report_artifacts/$hash.xlsx',
    sha256: hash,
    sizeBytes: 3,
  );
}

Future<_ReportIds> _seedReports(
  AppDatabase database, {
  required WeeklySupportReportPeriod weeklyPeriod,
  required MonthlySupportReportPeriod monthlyPeriod,
}) async {
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

  final weeklyId = await database
      .into(database.supportWeeklyReports)
      .insert(
        SupportWeeklyReportsCompanion.insert(
          halaqahId: 1,
          weekStartDate: _dateText(weeklyPeriod.weekStart),
          weekEndDate: _dateText(weeklyPeriod.weekEnd),
          status: 'approved',
          teacherNameSnapshot: 'المعلم',
          halaqahNameSnapshot: 'الحلقة',
          organizationNameSnapshot: 'الجهة',
          policyVersion: 1,
          templateVersion: 1,
          sourceFingerprint: const Value('weekly-source'),
          approvedAtUtc: Value(DateTime.utc(2026, 9, 18, 10)),
        ),
      );

  final monthlyId = await database
      .into(database.supportMonthlyReports)
      .insert(
        SupportMonthlyReportsCompanion.insert(
          halaqahId: 1,
          monthStartDate: _dateText(monthlyPeriod.monthStart),
          monthEndDate: _dateText(monthlyPeriod.monthEnd),
          status: 'approved',
          teacherNameSnapshot: 'المعلم',
          halaqahNameSnapshot: 'الحلقة',
          organizationNameSnapshot: 'الجهة',
          policyVersion: 1,
          templateVersion: 1,
          sourceFingerprint: const Value('monthly-source'),
          approvedAtUtc: Value(DateTime.utc(2026, 9, 18, 11)),
        ),
      );

  return _ReportIds(weeklyId: weeklyId, monthlyId: monthlyId);
}

String _dateText(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _hash(String character) => List<String>.filled(64, character).join();

final class _ReportIds {
  const _ReportIds({required this.weeklyId, required this.monthlyId});

  final int weeklyId;
  final int monthlyId;
}
