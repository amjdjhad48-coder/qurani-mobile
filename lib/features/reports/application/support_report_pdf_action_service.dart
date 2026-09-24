import 'package:qurani/features/reports/application/support_report_history_detail.dart';

enum SupportReportApprovedPdfSaveOutcome { saved, cancelled }

abstract interface class SupportReportApprovedPdfActionService {
  Future<void> openApprovedPdf({required SupportReportHistoryDetail detail});

  Future<SupportReportApprovedPdfSaveOutcome> saveApprovedPdf({
    required SupportReportHistoryDetail detail,
  });

  Future<void> shareApprovedPdf({required SupportReportHistoryDetail detail});
}
