import 'package:qurani/features/students/domain/student.dart';

abstract interface class StudentRepository {
  Future<StudentRecord?> findById(int studentId);

  Future<String> supportStatusForHalaqah(int halaqahId);

  Future<StudentProgressPlanRecord?> progressPlanForStudent(int studentId);

  Future<StudentProgressPlanRecord> saveProgressPlan({
    required int studentId,
    required int? currentJuz,
    required String? dailyPlanText,
  });

  Future<List<StudentRecord>> search({
    required int halaqahId,
    required String query,
    bool includeArchived = false,
  });

  Future<List<StudentRecord>> reorderActiveStudents({
    required int halaqahId,
    required List<int> orderedStudentIds,
  });

  Future<List<StudentActivityPeriodRecord>> activityPeriodsForStudent(
    int studentId,
  );

  Future<StudentRecord> create({
    required int halaqahId,
    required StudentWriteData data,
    required String activeFromDate,
  });

  Future<StudentRecord> update({
    required int studentId,
    required StudentWriteData data,
  });

  Future<StudentRecord> archive({
    required int studentId,
    required int openActivityPeriodId,
    required String activeToDate,
    required DateTime archivedAtUtc,
  });

  Future<StudentRecord> reactivate({
    required int studentId,
    required String activeFromDate,
    required int? periodIdToReopen,
  });
}
