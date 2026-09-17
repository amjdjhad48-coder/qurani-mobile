import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/reports/application/monthly_support_report_review.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/data/drift_approved_weekly_reports_for_month_repository.dart';
import 'package:qurani/features/reports/data/drift_monthly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/application/weekly_support_report_review.dart';
import 'package:qurani/features/reports/data/drift_support_report_source_repository.dart';
import 'package:qurani/features/reports/data/drift_weekly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/data/drift_support_reports_review_repository.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/data/drift_runtime_database_opener.dart';
import 'package:qurani/features/students/application/student_runtime_providers.dart';

final class SupportReportsRuntimeContext {
  SupportReportsRuntimeContext({
    required this.halaqahId,
    required this.supportEnabled,
    required Iterable<SupportReportHistoryItem> history,
  }) : history = List<SupportReportHistoryItem>.unmodifiable(history);

  final int halaqahId;
  final bool supportEnabled;
  final List<SupportReportHistoryItem> history;

  bool get hasHistoricalReports => history.isNotEmpty;
  bool get canOpenReports => supportEnabled || hasHistoricalReports;
}

final class SupportReportsReviewService {
  const SupportReportsReviewService({required this.repository});
  final SupportReportsReviewRepository repository;

  Future<List<SupportReportHistoryItem>> listApproved({
    required int halaqahId,
  }) {
    return repository.listApproved(halaqahId: halaqahId);
  }
}

final supportReportsRuntimeContextProvider =
    FutureProvider.autoDispose<SupportReportsRuntimeContext>((ref) async {
      final studentContext = await ref.watch(
        studentRuntimeContextProvider.future,
      );
      final coordinator = await ref.watch(
        runtimeLockCoordinatorProvider.future,
      );
      if (coordinator is! RuntimeDatabaseSessionAccess) {
        throw StateError(
          'Runtime lock coordinator does not expose the open database session.',
        );
      }
      // Match the existing Student/Daily runtime session-access pattern.
      final sessionAccess = coordinator as RuntimeDatabaseSessionAccess;
      final handle = sessionAccess.requireOpenDatabaseHandle();
      if (handle is! DriftRuntimeDatabaseHandle) {
        throw StateError(
          'Runtime database handle is not the production Drift handle.',
        );
      }
      final supportStatus = await studentContext.service
          .supportStatusForHalaqah(studentContext.halaqahId);
      final reviewService = SupportReportsReviewService(
        repository: DriftSupportReportsReviewRepository(handle.database),
      );
      final history = await reviewService.listApproved(
        halaqahId: studentContext.halaqahId,
      );
      return SupportReportsRuntimeContext(
        halaqahId: studentContext.halaqahId,
        supportEnabled: supportStatus == 'enabled',
        history: history,
      );
    });

final supportReportHistoryDetailProvider = FutureProvider.autoDispose
    .family<SupportReportHistoryDetail, SupportReportHistoryItem>((
      ref,
      item,
    ) async {
      final reportsContext = await ref.watch(
        supportReportsRuntimeContextProvider.future,
      );

      final knownHistoryItem = reportsContext.history.any(
        (candidate) =>
            candidate.kind == item.kind &&
            candidate.reportId == item.reportId &&
            candidate.sourceFingerprint == item.sourceFingerprint,
      );

      if (!knownHistoryItem) {
        throw StateError(
          'Requested approved report is not part of the active halaqah history.',
        );
      }

      final coordinator = await ref.watch(
        runtimeLockCoordinatorProvider.future,
      );

      if (coordinator is! RuntimeDatabaseSessionAccess) {
        throw StateError(
          'Runtime lock coordinator does not expose the open database session.',
        );
      }

      final sessionAccess = coordinator as RuntimeDatabaseSessionAccess;
      final handle = sessionAccess.requireOpenDatabaseHandle();

      if (handle is! DriftRuntimeDatabaseHandle) {
        throw StateError(
          'Runtime database handle is not the production Drift handle.',
        );
      }

      return SupportReportHistoryDetailService(
        weeklyRepository: DriftWeeklySupportReportSnapshotRepository(
          handle.database,
        ),
        monthlyRepository: DriftMonthlySupportReportSnapshotRepository(
          handle.database,
        ),
      ).load(halaqahId: reportsContext.halaqahId, item: item);
    });
final monthlySupportReportReviewProvider =
    FutureProvider.autoDispose<MonthlySupportReportReview>((ref) async {
      final reportsContext = await ref.watch(
        supportReportsRuntimeContextProvider.future,
      );

      if (!reportsContext.supportEnabled) {
        throw StateError(
          'Current monthly report review requires an enabled support program.',
        );
      }

      final dailyContext = await ref.watch(
        dailyHalaqahRuntimeContextProvider.future,
      );

      if (dailyContext.halaqahId != reportsContext.halaqahId) {
        throw StateError(
          'Reports and daily halaqah runtime contexts do not match.',
        );
      }

      final coordinator = await ref.watch(
        runtimeLockCoordinatorProvider.future,
      );

      if (coordinator is! RuntimeDatabaseSessionAccess) {
        throw StateError(
          'Runtime lock coordinator does not expose the open database session.',
        );
      }

      final sessionAccess = coordinator as RuntimeDatabaseSessionAccess;
      final handle = sessionAccess.requireOpenDatabaseHandle();

      if (handle is! DriftRuntimeDatabaseHandle) {
        throw StateError(
          'Runtime database handle is not the production Drift handle.',
        );
      }

      final service = MonthlySupportReportReviewService(
        weeklyRepository: DriftApprovedWeeklySupportReportsForMonthRepository(
          handle.database,
        ),
        snapshotRepository: DriftMonthlySupportReportSnapshotRepository(
          handle.database,
        ),
      );

      return service.load(
        halaqahId: reportsContext.halaqahId,
        localDate: dailyContext.clock.todayLocal(),
      );
    });
final weeklySupportReportReviewProvider =
    FutureProvider.autoDispose<WeeklySupportReportReview>((ref) async {
      final reportsContext = await ref.watch(
        supportReportsRuntimeContextProvider.future,
      );

      if (!reportsContext.supportEnabled) {
        throw StateError(
          'Current weekly report review requires an enabled support program.',
        );
      }

      final dailyContext = await ref.watch(
        dailyHalaqahRuntimeContextProvider.future,
      );

      if (dailyContext.halaqahId != reportsContext.halaqahId) {
        throw StateError(
          'Reports and daily halaqah runtime contexts do not match.',
        );
      }

      final coordinator = await ref.watch(
        runtimeLockCoordinatorProvider.future,
      );

      if (coordinator is! RuntimeDatabaseSessionAccess) {
        throw StateError(
          'Runtime lock coordinator does not expose the open database session.',
        );
      }

      final sessionAccess = coordinator as RuntimeDatabaseSessionAccess;

      final handle = sessionAccess.requireOpenDatabaseHandle();

      if (handle is! DriftRuntimeDatabaseHandle) {
        throw StateError(
          'Runtime database handle is not the production Drift handle.',
        );
      }

      return WeeklySupportReportReviewService(
        sourceRepository: DriftSupportReportSourceRepository(handle.database),
        snapshotRepository: DriftWeeklySupportReportSnapshotRepository(
          handle.database,
        ),
      ).load(
        halaqahId: reportsContext.halaqahId,
        localDate: dailyContext.clock.todayLocal(),
      );
    });
