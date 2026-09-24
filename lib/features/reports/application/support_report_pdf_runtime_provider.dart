import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/application/support_report_pdf_action_service.dart';
import 'package:qurani/features/reports/data/android_support_report_pdf_actions.dart';
import 'package:qurani/features/reports/data/verified_support_report_pdf_generator.dart';

final supportReportApprovedPdfActionServiceProvider =
    Provider<SupportReportApprovedPdfActionService>((ref) {
      return Package8SupportReportApprovedPdfActionService(
        generator: const VerifiedSupportReportPdfGenerator(),
        externalActions: AndroidSupportReportPdfExternalActions(),
      );
    });

final class Package8SupportReportApprovedPdfActionService
    implements SupportReportApprovedPdfActionService {
  const Package8SupportReportApprovedPdfActionService({
    required this.generator,
    required this.externalActions,
  });

  final VerifiedSupportReportPdfGenerator generator;
  final AndroidSupportReportPdfExternalActions externalActions;

  @override
  Future<void> openApprovedPdf({
    required SupportReportHistoryDetail detail,
  }) async {
    final pdf = await _generateVerifiedPdf(detail);
    await externalActions.openPdf(pdf);
  }

  @override
  Future<SupportReportApprovedPdfSaveOutcome> saveApprovedPdf({
    required SupportReportHistoryDetail detail,
  }) async {
    final pdf = await _generateVerifiedPdf(detail);
    final outcome = await externalActions.savePdf(pdf);

    return outcome == SupportReportPdfSaveOutcome.saved
        ? SupportReportApprovedPdfSaveOutcome.saved
        : SupportReportApprovedPdfSaveOutcome.cancelled;
  }

  @override
  Future<void> shareApprovedPdf({
    required SupportReportHistoryDetail detail,
  }) async {
    final pdf = await _generateVerifiedPdf(detail);
    await externalActions.sharePdf(pdf);
  }

  Future<VerifiedSupportReportPdf> _generateVerifiedPdf(
    SupportReportHistoryDetail detail,
  ) async {
    final weekly = detail.weeklySnapshot;
    final monthly = detail.monthlySnapshot;

    if ((weekly == null) == (monthly == null)) {
      throw StateError(
        'Approved history detail must expose exactly one immutable snapshot.',
      );
    }

    final expectedKind = weekly != null
        ? SupportReportArtifactKind.weekly
        : SupportReportArtifactKind.monthly;

    final pdf = weekly != null
        ? await generator.generateWeekly(weekly)
        : await generator.generateMonthly(monthly!);

    if (pdf.kind != expectedKind ||
        pdf.sourceFingerprint != detail.item.sourceFingerprint ||
        pdf.templateVersion != detail.item.header.templateVersion) {
      throw StateError(
        'Generated PDF identity does not match the approved history snapshot.',
      );
    }

    return pdf;
  }
}
