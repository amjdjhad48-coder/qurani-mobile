import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';

final class ParentFollowUpIncompleteAttendanceException implements Exception {
  ParentFollowUpIncompleteAttendanceException(Iterable<int> missingStudentIds)
    : missingStudentIds = List<int>.unmodifiable(missingStudentIds);

  final List<int> missingStudentIds;

  int get missingCount => missingStudentIds.length;
}

final class EndDayAndPrepareParentFollowUpsResult {
  EndDayAndPrepareParentFollowUpsResult({
    required this.day,
    required Iterable<ParentFollowUpRecord> followUps,
  }) : followUps = List<ParentFollowUpRecord>.unmodifiable(followUps);

  final HalaqahDayRecord day;
  final List<ParentFollowUpRecord> followUps;
}

final class AttendanceCorrectionReconciliationResult {
  const AttendanceCorrectionReconciliationResult({
    required this.attendance,
    required this.pendingCorrection,
  });

  final StudentAttendanceRecord attendance;
  final ParentFollowUpRecord? pendingCorrection;
}

abstract interface class ParentFollowUpRepository {
  Future<EndDayAndPrepareParentFollowUpsResult> endDayAndPrepareDailyFollowUps({
    required int halaqahId,
    required int dayId,
  });

  Future<ParentFollowUpRecord?> findById(int followUpId);

  Future<List<ParentFollowUpRecord>> listForDay(int dayId);

  Future<ParentFollowUpDailyPreviewInput> loadLiveDailyPreview(int followUpId);

  Future<ParentFollowUpAttendanceCorrectionInput>
  loadLiveAttendanceCorrectionPreview(int followUpId);

  Future<AttendanceCorrectionReconciliationResult>
  setAttendanceAndReconcileCorrection({
    required int halaqahId,
    required int dayId,
    required int studentId,
    required AttendanceStatus status,
  });

  Future<ParentFollowUpRecord> markHandled({
    required int followUpId,
    required ParentFollowUpHandledSnapshot snapshot,
  });
}
