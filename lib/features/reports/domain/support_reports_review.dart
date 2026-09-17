import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

enum SupportReportHistoryKind { weekly, monthly }

final class SupportReportHistoryItem {
  SupportReportHistoryItem({
    required this.reportId,
    required this.kind,
    required DateTime periodStart,
    required DateTime periodEnd,
    required this.header,
    required this.sourceFingerprint,
    required DateTime approvedAtUtc,
  }) : periodStart = SupportReportPolicy.dateOnly(periodStart),
       periodEnd = SupportReportPolicy.dateOnly(periodEnd),
       approvedAtUtc = approvedAtUtc.toUtc() {
    if (reportId <= 0) {
      throw ArgumentError.value(
        reportId,
        'reportId',
        'Report id must be positive.',
      );
    }
    if (this.periodEnd.isBefore(this.periodStart)) {
      throw ArgumentError(
        'Report history period end must not precede its start.',
      );
    }
    if (sourceFingerprint.trim().isEmpty) {
      throw ArgumentError.value(
        sourceFingerprint,
        'sourceFingerprint',
        'Approved report fingerprint must not be empty.',
      );
    }
  }

  final int reportId;
  final SupportReportHistoryKind kind;
  final DateTime periodStart;
  final DateTime periodEnd;
  final SupportReportHeaderSnapshot header;
  final String sourceFingerprint;
  final DateTime approvedAtUtc;
}

abstract interface class SupportReportsReviewRepository {
  Future<List<SupportReportHistoryItem>> listApproved({required int halaqahId});
}
