import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/data/support_report_artifact_file_store.dart';
import 'package:qurani/features/reports/data/verified_support_report_excel_generator.dart';

void main() {
  group('SupportReportArtifactFileStore', () {
    test(
      'stages verified Excel in private content-addressed storage',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p8_artifact_store_',
        );

        try {
          final store = SupportReportArtifactFileStore(
            applicationSupportDirectory: root,
          );
          final excel = await _excel(
            kind: SupportReportArtifactKind.weekly,
            sourceFingerprint: 'weekly-source',
          );

          final artifact = await store.stageVerifiedExcel(
            excel: excel,
            policyVersion: 1,
          );

          expect(artifact.kind, SupportReportArtifactKind.weekly);
          expect(artifact.sourceFingerprint, 'weekly-source');
          expect(artifact.policyVersion, 1);
          expect(artifact.templateVersion, 1);
          expect(artifact.sha256, excel.sha256);
          expect(artifact.sizeBytes, excel.bytes.length);
          expect(
            artifact.internalPath,
            'report_artifacts/${excel.sha256}.xlsx',
          );

          final file = File(
            '${root.path}${Platform.pathSeparator}'
            'report_artifacts${Platform.pathSeparator}${excel.sha256}.xlsx',
          );

          expect(await file.exists(), isTrue);
          expect(await file.readAsBytes(), excel.bytes);

          final verification = await store.verifyPrepared(artifact);

          expect(verification.isValid, isTrue);
        } finally {
          await root.delete(recursive: true);
        }
      },
    );

    test('staging the same verified bytes is idempotent', () async {
      final root = await Directory.systemTemp.createTemp(
        'qurani_p8_artifact_store_idempotent_',
      );

      try {
        final store = SupportReportArtifactFileStore(
          applicationSupportDirectory: root,
        );
        final excel = await _excel(
          kind: SupportReportArtifactKind.monthly,
          sourceFingerprint: 'monthly-source',
        );

        final first = await store.stageVerifiedExcel(
          excel: excel,
          policyVersion: 1,
        );
        final second = await store.stageVerifiedExcel(
          excel: excel,
          policyVersion: 1,
        );

        expect(second.internalPath, first.internalPath);
        expect(second.sha256, first.sha256);

        final directory = Directory(
          '${root.path}${Platform.pathSeparator}report_artifacts',
        );
        final xlsxFiles = await directory
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.xlsx'))
            .toList();

        expect(xlsxFiles, hasLength(1));
      } finally {
        await root.delete(recursive: true);
      }
    });

    test('tampering or deleting a staged file fails verification', () async {
      final root = await Directory.systemTemp.createTemp(
        'qurani_p8_artifact_store_tamper_',
      );

      try {
        final store = SupportReportArtifactFileStore(
          applicationSupportDirectory: root,
        );
        final excel = await _excel(
          kind: SupportReportArtifactKind.weekly,
          sourceFingerprint: 'weekly-source',
        );
        final artifact = await store.stageVerifiedExcel(
          excel: excel,
          policyVersion: 1,
        );
        final file = File(
          '${root.path}${Platform.pathSeparator}'
          '${artifact.internalPath.replaceAll('/', Platform.pathSeparator)}',
        );

        await file.writeAsBytes(<int>[9, 9, 9], flush: true);

        final tampered = await store.verifyPrepared(artifact);

        expect(tampered.isValid, isFalse);

        await file.delete();

        final missing = await store.verifyPrepared(artifact);

        expect(missing.isValid, isFalse);
      } finally {
        await root.delete(recursive: true);
      }
    });

    test('rejects bytes that do not match the declared verified hash', () async {
      final root = await Directory.systemTemp.createTemp(
        'qurani_p8_artifact_store_hash_guard_',
      );

      try {
        final store = SupportReportArtifactFileStore(
          applicationSupportDirectory: root,
        );
        final excel = VerifiedSupportReportExcel(
          kind: SupportReportArtifactKind.weekly,
          fileName: 'bad.xlsx',
          sourceFingerprint: 'weekly-source',
          templateVersion: 1,
          sha256:
              'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          bytes: const <int>[1, 2, 3],
        );

        await expectLater(
          store.stageVerifiedExcel(excel: excel, policyVersion: 1),
          throwsStateError,
        );

        final artifactDirectory = Directory(
          '${root.path}${Platform.pathSeparator}report_artifacts',
        );

        if (await artifactDirectory.exists()) {
          expect(await artifactDirectory.list().toList(), isEmpty);
        }
      } finally {
        await root.delete(recursive: true);
      }
    });
  });
}

Future<VerifiedSupportReportExcel> _excel({
  required SupportReportArtifactKind kind,
  required String sourceFingerprint,
}) async {
  final bytes = List<int>.generate(2048, (index) => index % 251);
  final hash = await Sha256().hash(bytes);
  final sha256 = hash.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();

  return VerifiedSupportReportExcel(
    kind: kind,
    fileName: 'report.xlsx',
    sourceFingerprint: sourceFingerprint,
    templateVersion: 1,
    sha256: sha256,
    bytes: bytes,
  );
}
