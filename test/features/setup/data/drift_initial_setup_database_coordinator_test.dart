import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/setup/data/drift_initial_setup_database_coordinator.dart';
import 'package:qurani/features/setup/domain/initial_setup_request.dart';

void main() {
  group('DriftInitialSetupDatabaseCoordinator', () {
    test(
      'builds, reopens, verifies and atomically publishes one candidate file',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p2_05_candidate_',
        );
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        final finalFile = File(
          '${root.path}${Platform.pathSeparator}qurani.db',
        );
        final coordinator = DriftInitialSetupDatabaseCoordinator(
          finalDatabaseFile: finalFile,
          tempDirectoryPath: root.path,
        );
        final databaseKey = Uint8List.fromList(
          List<int>.generate(32, (index) => index + 1, growable: false),
        );
        const request = InitialSetupRequest(
          teacherName: 'عبدالحكيم قائد',
          halaqahName: 'حلقة ذي النورين',
          centerName: 'المركز الرئيسي',
          hasSupportOrganization: true,
          supportOrganizationName: 'الجهة أ',
          pin: '482731',
        );

        expect(
          coordinator.candidateDatabaseFile.parent.path,
          finalFile.parent.path,
        );

        await coordinator.buildAndVerifyCandidate(
          request: request,
          databaseKey: databaseKey,
          createdAtUtc: DateTime.utc(2026, 9, 4, 19, 30),
        );

        expect(await coordinator.candidateDatabaseExists(), isTrue);
        expect(await coordinator.finalDatabaseExists(), isFalse);

        for (final suffix in <String>['-journal', '-wal', '-shm']) {
          expect(
            await File(
              '${coordinator.candidateDatabaseFile.path}$suffix',
            ).exists(),
            isFalse,
          );
        }

        await coordinator.publishCandidate();

        expect(await coordinator.candidateDatabaseExists(), isFalse);
        expect(await coordinator.finalDatabaseExists(), isTrue);

        await expectLater(
          coordinator.verifyFinal(request: request, databaseKey: databaseKey),
          completes,
        );
      },
    );

    test(
      'initial setup without support persists disabled and no support period',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p2_05_disabled_',
        );
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        final coordinator = DriftInitialSetupDatabaseCoordinator(
          finalDatabaseFile: File(
            '${root.path}${Platform.pathSeparator}qurani.db',
          ),
          tempDirectoryPath: root.path,
        );
        final key = Uint8List(32);
        const request = InitialSetupRequest(
          teacherName: 'معلم',
          halaqahName: 'حلقة',
          centerName: 'مركز',
          hasSupportOrganization: false,
          supportOrganizationName: null,
          pin: '482731',
        );

        await coordinator.buildAndVerifyCandidate(
          request: request,
          databaseKey: key,
          createdAtUtc: DateTime.utc(2026, 9, 4, 20),
        );
        await coordinator.publishCandidate();

        await expectLater(
          coordinator.verifyFinal(request: request, databaseKey: key),
          completes,
        );
      },
    );

    test(
      'publication refuses to overwrite an existing final database',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p2_05_conflict_',
        );
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        final finalFile = File(
          '${root.path}${Platform.pathSeparator}qurani.db',
        );
        final coordinator = DriftInitialSetupDatabaseCoordinator(
          finalDatabaseFile: finalFile,
          tempDirectoryPath: root.path,
        );

        await coordinator.candidateDatabaseFile.writeAsBytes(<int>[1, 2, 3]);
        await finalFile.writeAsBytes(<int>[4, 5, 6]);

        await expectLater(coordinator.publishCandidate(), throwsStateError);

        expect(await finalFile.readAsBytes(), <int>[4, 5, 6]);
        expect(await coordinator.candidateDatabaseExists(), isTrue);
      },
    );
  });
}
