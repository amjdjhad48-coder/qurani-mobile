import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/reports/application/support_report_artifact_save_service.dart';
import 'package:qurani/features/reports/application/support_report_student_export_service.dart';
import 'package:qurani/features/reports/data/android_support_report_artifact_opener.dart';
import 'package:qurani/features/reports/data/android_support_report_artifact_saf_saver.dart';
import 'package:qurani/features/reports/data/android_support_report_artifact_sharer.dart';
import 'package:qurani/features/reports/data/android_support_report_pdf_actions.dart';
import 'package:qurani/features/reports/data/verified_support_report_excel_generator.dart';
import 'package:qurani/features/reports/data/verified_support_report_pdf_generator.dart';

final supportReportStudentExportServiceProvider =
    Provider<SupportReportStudentExportService>((_) {
      return Package8SupportReportStudentExportService(
        excelGenerator: const _VerifiedStudentExcelGenerator(),
        pdfGenerator: const _VerifiedStudentPdfGenerator(),
        externalActions: _AndroidStudentExportExternalActions(),
      );
    });

final class _VerifiedStudentExcelGenerator
    implements SupportReportStudentExportGenerator {
  const _VerifiedStudentExcelGenerator();

  static const VerifiedSupportReportExcelGenerator _delegate =
      VerifiedSupportReportExcelGenerator();

  @override
  Future<SupportReportStudentGeneratedArtifact> generate(
    StudentExportProjection projection,
  ) async {
    final weekly = projection.weeklySnapshot;
    final monthly = projection.monthlySnapshot;

    if ((weekly == null) == (monthly == null)) {
      throw StateError(
        'Student Excel projection must expose exactly one snapshot.',
      );
    }

    final excel = weekly != null
        ? await _delegate.generateWeekly(weekly)
        : await _delegate.generateMonthly(monthly!);

    return SupportReportStudentGeneratedArtifact(
      format: SupportReportStudentExportFormat.excel,
      kind: excel.kind,
      sourceFingerprint: excel.sourceFingerprint,
      templateVersion: excel.templateVersion,
      sha256: excel.sha256,
      bytes: excel.bytes,
    );
  }
}

final class _VerifiedStudentPdfGenerator
    implements SupportReportStudentExportGenerator {
  const _VerifiedStudentPdfGenerator();

  static const VerifiedSupportReportPdfGenerator _delegate =
      VerifiedSupportReportPdfGenerator();

  @override
  Future<SupportReportStudentGeneratedArtifact> generate(
    StudentExportProjection projection,
  ) async {
    final weekly = projection.weeklySnapshot;
    final monthly = projection.monthlySnapshot;

    if ((weekly == null) == (monthly == null)) {
      throw StateError(
        'Student PDF projection must expose exactly one snapshot.',
      );
    }

    final pdf = weekly != null
        ? await _delegate.generateWeekly(weekly)
        : await _delegate.generateMonthly(monthly!);

    return SupportReportStudentGeneratedArtifact(
      format: SupportReportStudentExportFormat.pdf,
      kind: pdf.kind,
      sourceFingerprint: pdf.sourceFingerprint,
      templateVersion: pdf.templateVersion,
      sha256: pdf.sha256,
      bytes: pdf.bytes,
    );
  }
}

final class _AndroidStudentExportExternalActions
    implements SupportReportStudentExportExternalActions {
  _AndroidStudentExportExternalActions({
    AndroidSupportReportArtifactExternalOpener? excelOpener,
    AndroidSupportReportArtifactSafSaver? excelSaver,
    AndroidSupportReportArtifactExternalSharer? excelSharer,
    AndroidSupportReportPdfExternalActions? pdfActions,
  }) : _excelOpener =
           excelOpener ?? AndroidSupportReportArtifactExternalOpener(),
       _excelSaver = excelSaver ?? AndroidSupportReportArtifactSafSaver(),
       _excelSharer =
           excelSharer ?? AndroidSupportReportArtifactExternalSharer(),
       _pdfActions = pdfActions ?? AndroidSupportReportPdfExternalActions();

  final AndroidSupportReportArtifactExternalOpener _excelOpener;
  final AndroidSupportReportArtifactSafSaver _excelSaver;
  final AndroidSupportReportArtifactExternalSharer _excelSharer;
  final AndroidSupportReportPdfExternalActions _pdfActions;

  @override
  Future<void> open({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  }) {
    return switch (artifact.format) {
      SupportReportStudentExportFormat.excel => _excelOpener.openExcel(
        bytes: artifact.bytes,
        sha256: artifact.sha256,
      ),
      SupportReportStudentExportFormat.pdf => _pdfActions.openPdf(
        _verifiedPdf(artifact: artifact, fileName: fileName),
      ),
    };
  }

  @override
  Future<SupportReportStudentExportOutcome> save({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  }) async {
    switch (artifact.format) {
      case SupportReportStudentExportFormat.excel:
        final outcome = await _excelSaver.saveExcel(
          bytes: artifact.bytes,
          sha256: artifact.sha256,
          suggestedName: fileName,
        );

        return outcome == SupportReportApprovedArtifactSaveOutcome.saved
            ? SupportReportStudentExportOutcome.completed
            : SupportReportStudentExportOutcome.cancelled;
      case SupportReportStudentExportFormat.pdf:
        final outcome = await _pdfActions.savePdf(
          _verifiedPdf(artifact: artifact, fileName: fileName),
        );

        return outcome == SupportReportPdfSaveOutcome.saved
            ? SupportReportStudentExportOutcome.completed
            : SupportReportStudentExportOutcome.cancelled;
    }
  }

  @override
  Future<void> share({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  }) {
    return switch (artifact.format) {
      SupportReportStudentExportFormat.excel => _excelSharer.shareExcel(
        bytes: artifact.bytes,
        sha256: artifact.sha256,
        suggestedName: fileName,
      ),
      SupportReportStudentExportFormat.pdf => _pdfActions.sharePdf(
        _verifiedPdf(artifact: artifact, fileName: fileName),
      ),
    };
  }

  VerifiedSupportReportPdf _verifiedPdf({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  }) {
    if (artifact.format != SupportReportStudentExportFormat.pdf) {
      throw StateError(
        'Only PDF student exports can use PDF external actions.',
      );
    }

    return VerifiedSupportReportPdf(
      kind: artifact.kind,
      fileName: fileName,
      sourceFingerprint: artifact.sourceFingerprint,
      templateVersion: artifact.templateVersion,
      sha256: artifact.sha256,
      bytes: artifact.bytes,
    );
  }
}
