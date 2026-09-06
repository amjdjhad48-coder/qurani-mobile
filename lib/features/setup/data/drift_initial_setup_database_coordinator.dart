import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/database/database_connection_factory.dart';
import 'package:qurani/core/database/database_migrations.dart';
import 'package:qurani/features/setup/application/initial_setup_database_coordinator.dart';
import 'package:qurani/features/setup/domain/initial_setup_request.dart';

final class DriftInitialSetupDatabaseCoordinator
    implements InitialSetupDatabaseCoordinator {
  DriftInitialSetupDatabaseCoordinator({
    required File finalDatabaseFile,
    required String tempDirectoryPath,
  }) : _finalDatabaseFile = finalDatabaseFile,
       _tempDirectoryPath = tempDirectoryPath {
    if (finalDatabaseFile.path.trim().isEmpty) {
      throw ArgumentError.value(
        finalDatabaseFile.path,
        'finalDatabaseFile.path',
        'Final database path must not be empty.',
      );
    }

    if (tempDirectoryPath.trim().isEmpty) {
      throw ArgumentError.value(
        tempDirectoryPath,
        'tempDirectoryPath',
        'Temporary directory path must not be empty.',
      );
    }
  }

  final File _finalDatabaseFile;
  final String _tempDirectoryPath;

  File get candidateDatabaseFile =>
      File('${_finalDatabaseFile.path}.setup_candidate');

  File get finalDatabaseFile => _finalDatabaseFile;

  @override
  Future<bool> finalDatabaseExists() => _finalDatabaseFile.exists();

  @override
  Future<bool> candidateDatabaseExists() => candidateDatabaseFile.exists();

  @override
  Future<void> discardCandidate() async {
    await _deleteIfExists(candidateDatabaseFile);
    await _deleteCandidateSidecars();
  }

  @override
  Future<void> buildAndVerifyCandidate({
    required InitialSetupRequest request,
    required Uint8List databaseKey,
    required DateTime createdAtUtc,
  }) async {
    request.validate();

    if (!createdAtUtc.isUtc) {
      throw ArgumentError.value(
        createdAtUtc,
        'createdAtUtc',
        'Initial setup event timestamp must be UTC.',
      );
    }

    if (await _finalDatabaseFile.exists()) {
      throw StateError(
        'Cannot build setup candidate after final database publication.',
      );
    }

    await discardCandidate();

    final parent = candidateDatabaseFile.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    final database = _open(
      file: candidateDatabaseFile,
      databaseKey: databaseKey,
    );

    try {
      await database.transaction(() async {
        final halaqahId = await database
            .into(database.halaqahs)
            .insert(
              HalaqahsCompanion.insert(
                teacherName: request.normalizedTeacherName,
                halaqahName: request.normalizedHalaqahName,
                centerName: request.normalizedCenterName,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: createdAtUtc,
              ),
            );

        await database
            .into(database.supportProgramSettings)
            .insert(
              SupportProgramSettingsCompanion.insert(
                halaqahId: halaqahId,
                status: request.supportStatus,
                organizationName: Value<String?>(
                  request.normalizedSupportOrganizationName,
                ),
                createdAtUtc: createdAtUtc,
                updatedAtUtc: createdAtUtc,
              ),
            );
      });

      await verifyDatabaseAfterSchemaChange(database);
      await _verifyExpected(database: database, request: request);
      await _prepareForSingleFilePublish(database);
    } finally {
      await database.close();
    }

    await verifyCandidate(request: request, databaseKey: databaseKey);
  }

  @override
  Future<void> verifyCandidate({
    required InitialSetupRequest request,
    required Uint8List databaseKey,
  }) {
    return _verifyFile(
      file: candidateDatabaseFile,
      request: request,
      databaseKey: databaseKey,
      prepareForPublish: true,
    );
  }

  @override
  Future<void> verifyFinal({
    required InitialSetupRequest request,
    required Uint8List databaseKey,
  }) {
    return _verifyFile(
      file: _finalDatabaseFile,
      request: request,
      databaseKey: databaseKey,
      prepareForPublish: false,
    );
  }

  @override
  Future<void> publishCandidate() async {
    final candidate = candidateDatabaseFile;

    if (!await candidate.exists()) {
      throw StateError('Setup candidate database does not exist.');
    }

    if (await _finalDatabaseFile.exists()) {
      throw StateError(
        'Refusing to overwrite an existing final Qurani database.',
      );
    }

    if (candidate.parent.path != _finalDatabaseFile.parent.path) {
      throw StateError(
        'Candidate and final database must be in the same directory.',
      );
    }

    await _assertNoCandidateSidecars();

    await candidate.rename(_finalDatabaseFile.path);

    if (!await _finalDatabaseFile.exists() || await candidate.exists()) {
      throw StateError('Atomic candidate publication did not complete.');
    }
  }

  AppDatabase _open({required File file, required Uint8List databaseKey}) {
    return AppDatabase(
      DatabaseConnectionFactory.openEncrypted(
        databaseFile: file,
        databaseKey: databaseKey,
        tempDirectoryPath: _tempDirectoryPath,
      ),
    );
  }

  Future<void> _verifyFile({
    required File file,
    required InitialSetupRequest request,
    required Uint8List databaseKey,
    required bool prepareForPublish,
  }) async {
    if (!await file.exists()) {
      throw StateError('Expected setup database file is missing: ${file.path}');
    }

    final database = _open(file: file, databaseKey: databaseKey);

    try {
      await verifyDatabaseAfterSchemaChange(database);
      await _verifyExpected(database: database, request: request);

      if (prepareForPublish) {
        await _prepareForSingleFilePublish(database);
      }
    } finally {
      await database.close();
    }

    if (prepareForPublish) {
      await _assertNoCandidateSidecars();
    }
  }

  Future<void> _verifyExpected({
    required AppDatabase database,
    required InitialSetupRequest request,
  }) async {
    final halaqahs = await database.select(database.halaqahs).get();
    if (halaqahs.length != 1) {
      throw StateError('Setup database must contain exactly one Halaqah.');
    }

    final halaqah = halaqahs.single;
    if (halaqah.teacherName != request.normalizedTeacherName ||
        halaqah.halaqahName != request.normalizedHalaqahName ||
        halaqah.centerName != request.normalizedCenterName ||
        !halaqah.createdAtUtc.isUtc ||
        !halaqah.updatedAtUtc.isUtc) {
      throw StateError('Setup Halaqah verification failed.');
    }

    final settings = await database
        .select(database.supportProgramSettings)
        .get();
    if (settings.length != 1) {
      throw StateError(
        'Setup database must contain exactly one support settings row.',
      );
    }

    final support = settings.single;
    if (support.halaqahId != halaqah.id ||
        support.status != request.supportStatus ||
        support.organizationName != request.normalizedSupportOrganizationName ||
        !support.createdAtUtc.isUtc ||
        !support.updatedAtUtc.isUtc) {
      throw StateError('Setup support settings verification failed.');
    }

    final periods = await database.select(database.supportProgramPeriods).get();
    if (periods.isNotEmpty) {
      throw StateError(
        'Initial setup must not open a support period before Package 3 activation.',
      );
    }
  }

  Future<void> _prepareForSingleFilePublish(AppDatabase database) async {
    await database.customSelect('PRAGMA wal_checkpoint(TRUNCATE);').get();

    final journalModeRows = await database
        .customSelect('PRAGMA journal_mode = DELETE;')
        .get();

    if (journalModeRows.length != 1 ||
        journalModeRows.single.data.values.single.toString().toLowerCase() !=
            'delete') {
      throw StateError(
        'Setup candidate must use DELETE journal mode before publication.',
      );
    }
  }

  Future<void> _assertNoCandidateSidecars() async {
    final residue = <String>[];

    for (final file in _candidateSidecars()) {
      if (await file.exists()) {
        residue.add(file.path);
      }
    }

    if (residue.isNotEmpty) {
      throw StateError(
        'Setup candidate has sidecar files and is not safe to publish: '
        '${residue.join(', ')}',
      );
    }
  }

  Future<void> _deleteCandidateSidecars() async {
    for (final file in _candidateSidecars()) {
      await _deleteIfExists(file);
    }
  }

  List<File> _candidateSidecars() {
    final path = candidateDatabaseFile.path;
    return <File>[File('$path-journal'), File('$path-wal'), File('$path-shm')];
  }

  static Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
