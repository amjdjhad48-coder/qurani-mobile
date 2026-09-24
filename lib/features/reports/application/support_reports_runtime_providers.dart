import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/reports/application/monthly_support_report_review.dart';
import 'package:qurani/features/reports/application/package8_support_report_approval_coordinator.dart';
import 'package:qurani/features/reports/application/package8_support_report_approval_reloaders.dart';
import 'package:qurani/features/reports/application/package8_support_report_artifact_lifecycle.dart';
import 'package:qurani/features/reports/application/support_report_artifact_open_service.dart';
import 'package:qurani/features/reports/application/support_report_artifact_save_service.dart';
import 'package:qurani/features/reports/application/support_report_artifact_share_service.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/data/android_support_report_artifact_opener.dart';
import 'package:qurani/features/reports/data/android_support_report_artifact_saf_saver.dart';
import 'package:qurani/features/reports/data/android_support_report_artifact_sharer.dart';
import 'package:qurani/features/reports/data/drift_approved_weekly_reports_for_month_repository.dart';
import 'package:qurani/features/reports/data/drift_monthly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/application/weekly_support_report_review.dart';
import 'package:qurani/features/reports/data/drift_support_report_source_repository.dart';
import 'package:qurani/features/reports/data/drift_support_report_artifact_reference_repository.dart';
import 'package:qurani/features/reports/data/drift_weekly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/data/support_report_artifact_file_store.dart';
import 'package:qurani/features/reports/data/verified_support_report_excel_artifact_preparer.dart';
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
  bool get canOpenReports => true;
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

Future<String> _loadReportsCenterName({
  required DriftRuntimeDatabaseHandle handle,
  required int halaqahId,
}) async {
  final halaqahs = await handle.database.select(handle.database.halaqahs).get();

  if (halaqahs.length != 1 || halaqahs.single.id != halaqahId) {
    throw StateError(
      'Qurani v1 requires exactly one configured halaqah identity for reports.',
    );
  }

  final centerName = halaqahs.single.centerName.trim();

  if (centerName.isEmpty) {
    throw StateError(
      'The configured halaqah center identity must not be empty.',
    );
  }

  return centerName;
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

      final centerName = await _loadReportsCenterName(
        handle: handle,
        halaqahId: reportsContext.halaqahId,
      );

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
        centerName: centerName,
      );
    });
final weeklySupportReportReviewProvider =
    FutureProvider.autoDispose<WeeklySupportReportReview>((ref) async {
      final reportsContext = await ref.watch(
        supportReportsRuntimeContextProvider.future,
      );

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

final supportReportArtifactFileStoreProvider =
    FutureProvider.autoDispose<SupportReportArtifactFileStore>((ref) async {
      final directory = await ref.watch(
        applicationSupportDirectoryProvider.future,
      );

      return SupportReportArtifactFileStore(
        applicationSupportDirectory: directory,
      );
    });

final supportReportArtifactLifecycleProvider =
    FutureProvider.autoDispose<Package8SupportReportArtifactLifecycle>((
      ref,
    ) async {
      final lockCoordinator = await ref.watch(
        runtimeLockCoordinatorProvider.future,
      );

      if (lockCoordinator is! RuntimeDatabaseSessionAccess) {
        throw StateError(
          'Runtime lock coordinator does not expose the open database session.',
        );
      }

      final sessionAccess = lockCoordinator as RuntimeDatabaseSessionAccess;
      final handle = sessionAccess.requireOpenDatabaseHandle();

      if (handle is! DriftRuntimeDatabaseHandle) {
        throw StateError(
          'Runtime database handle is not the production Drift handle.',
        );
      }

      final fileStore = await ref.watch(
        supportReportArtifactFileStoreProvider.future,
      );

      return Package8SupportReportArtifactLifecycle(
        referenceRepository: DriftSupportReportArtifactReferenceRepository(
          handle.database,
        ),
        fileCleanup: fileStore,
      );
    });
final supportReportArtifactExternalOpenerProvider =
    Provider<SupportReportArtifactExternalOpener>((ref) {
      return AndroidSupportReportArtifactExternalOpener();
    });

final supportReportApprovedArtifactOpenServiceProvider =
    FutureProvider.autoDispose<SupportReportApprovedArtifactOpenService>((
      ref,
    ) async {
      final artifactLifecycle = await ref.watch(
        supportReportArtifactLifecycleProvider.future,
      );
      final fileStore = await ref.watch(
        supportReportArtifactFileStoreProvider.future,
      );

      return Package8SupportReportApprovedArtifactOpenService(
        artifactLifecycle: artifactLifecycle,
        bytesReader: VerifiedSupportReportApprovedArtifactBytesReader(
          fileStore: fileStore,
        ),
        externalOpener: ref.watch(supportReportArtifactExternalOpenerProvider),
      );
    });

final supportReportArtifactExternalSaverProvider =
    Provider<SupportReportArtifactExternalSaver>((ref) {
      return AndroidSupportReportArtifactSafSaver();
    });

final supportReportApprovedArtifactSaveServiceProvider =
    FutureProvider.autoDispose<SupportReportApprovedArtifactSaveService>((
      ref,
    ) async {
      final artifactLifecycle = await ref.watch(
        supportReportArtifactLifecycleProvider.future,
      );
      final fileStore = await ref.watch(
        supportReportArtifactFileStoreProvider.future,
      );

      return Package8SupportReportApprovedArtifactSaveService(
        artifactLifecycle: artifactLifecycle,
        bytesReader: VerifiedSupportReportApprovedArtifactBytesReader(
          fileStore: fileStore,
        ),
        externalSaver: ref.watch(supportReportArtifactExternalSaverProvider),
      );
    });

final supportReportArtifactExternalSharerProvider =
    Provider<SupportReportArtifactExternalSharer>((ref) {
      return AndroidSupportReportArtifactExternalSharer();
    });

final supportReportApprovedArtifactShareServiceProvider =
    FutureProvider.autoDispose<SupportReportApprovedArtifactShareService>((
      ref,
    ) async {
      final artifactLifecycle = await ref.watch(
        supportReportArtifactLifecycleProvider.future,
      );
      final fileStore = await ref.watch(
        supportReportArtifactFileStoreProvider.future,
      );

      return Package8SupportReportApprovedArtifactShareService(
        artifactLifecycle: artifactLifecycle,
        bytesReader: VerifiedSupportReportApprovedArtifactBytesReader(
          fileStore: fileStore,
        ),
        externalSharer: ref.watch(supportReportArtifactExternalSharerProvider),
      );
    });

final supportReportStartupCleanupProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final keepAliveLink = ref.keepAlive();

  try {
    final artifactLifecycle = await ref.read(
      supportReportArtifactLifecycleProvider.future,
    );
    return await artifactLifecycle.cleanupOrphans();
  } catch (_) {
    keepAliveLink.close();
    rethrow;
  }
});

final package8WeeklySupportReportApprovalCoordinatorProvider =
    FutureProvider.autoDispose<Package8WeeklySupportReportApprovalCoordinator>((
      ref,
    ) async {
      final lockCoordinator = await ref.watch(
        runtimeLockCoordinatorProvider.future,
      );

      if (lockCoordinator is! RuntimeDatabaseSessionAccess) {
        throw StateError(
          'Runtime lock coordinator does not expose the open database session.',
        );
      }

      final sessionAccess = lockCoordinator as RuntimeDatabaseSessionAccess;
      final handle = sessionAccess.requireOpenDatabaseHandle();

      if (handle is! DriftRuntimeDatabaseHandle) {
        throw StateError(
          'Runtime database handle is not the production Drift handle.',
        );
      }

      final fileStore = await ref.watch(
        supportReportArtifactFileStoreProvider.future,
      );
      final artifactLifecycle = await ref.watch(
        supportReportArtifactLifecycleProvider.future,
      );

      return Package8WeeklySupportReportApprovalCoordinator(
        repository: DriftWeeklySupportReportSnapshotRepository(handle.database),
        artifactPreparer: VerifiedSupportReportExcelArtifactPreparer(
          fileStore: fileStore,
        ),
        artifactVerifier: fileStore,
        artifactLifecycle: artifactLifecycle,
        sourceReloader: ProductionWeeklySupportReportApprovalCandidateReloader(
          sourceRepository: DriftSupportReportSourceRepository(handle.database),
        ),
      );
    });

final package8MonthlySupportReportApprovalCoordinatorProvider =
    FutureProvider.autoDispose<
      Package8MonthlySupportReportApprovalCoordinator
    >((ref) async {
      final lockCoordinator = await ref.watch(
        runtimeLockCoordinatorProvider.future,
      );

      if (lockCoordinator is! RuntimeDatabaseSessionAccess) {
        throw StateError(
          'Runtime lock coordinator does not expose the open database session.',
        );
      }

      final sessionAccess = lockCoordinator as RuntimeDatabaseSessionAccess;
      final handle = sessionAccess.requireOpenDatabaseHandle();

      if (handle is! DriftRuntimeDatabaseHandle) {
        throw StateError(
          'Runtime database handle is not the production Drift handle.',
        );
      }

      final fileStore = await ref.watch(
        supportReportArtifactFileStoreProvider.future,
      );
      final artifactLifecycle = await ref.watch(
        supportReportArtifactLifecycleProvider.future,
      );

      return Package8MonthlySupportReportApprovalCoordinator(
        repository: DriftMonthlySupportReportSnapshotRepository(
          handle.database,
        ),
        artifactPreparer: VerifiedSupportReportExcelArtifactPreparer(
          fileStore: fileStore,
        ),
        artifactVerifier: fileStore,
        artifactLifecycle: artifactLifecycle,
        sourceReloader: ProductionMonthlySupportReportApprovalCandidateReloader(
          weeklyRepository: DriftApprovedWeeklySupportReportsForMonthRepository(
            handle.database,
          ),
          generalCenterNameLoader: (halaqahId) =>
              _loadReportsCenterName(handle: handle, halaqahId: halaqahId),
        ),
      );
    });
