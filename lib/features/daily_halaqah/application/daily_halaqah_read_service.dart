import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah_repository.dart';

final class DailyHalaqahReadService {
  const DailyHalaqahReadService(this._repository);

  final DailyHalaqahRepository _repository;

  Future<List<HalaqahDayHistoryItem>> history({required int halaqahId}) async {
    final items = await _repository.dayHistory(halaqahId: halaqahId);

    return List<HalaqahDayHistoryItem>.unmodifiable(items);
  }

  Future<HalaqahDaySummary> summary({
    required int halaqahId,
    required int dayId,
  }) async {
    final day = await _repository.findDayById(dayId);

    if (day == null) {
      throw StateError('Halaqah day $dayId was not found.');
    }

    if (day.halaqahId != halaqahId) {
      throw StateError(
        'Halaqah day $dayId does not belong to halaqah $halaqahId.',
      );
    }

    if (day.isHoliday) {
      return HalaqahDaySummary(
        day: day,
        students: const <DayStudentSummary>[],
        attendance: const AttendanceSummaryCounts.zero(),
      );
    }

    final students = await _repository.historicallyActiveStudents(
      halaqahId: halaqahId,
      dayDate: day.dayDate,
    );

    final attendanceRecords = await _repository.attendanceForDay(dayId);

    final attendanceByStudent = <int, AttendanceStatus>{
      for (final record in attendanceRecords) record.studentId: record.status,
    };

    final studentSummaries = students
        .map(
          (student) => DayStudentSummary(
            student: student,
            attendanceStatus: attendanceByStudent[student.id],
          ),
        )
        .toList(growable: false);

    var presentCount = 0;
    var absentCount = 0;
    var excusedAbsentCount = 0;
    var unsetCount = 0;

    for (final student in studentSummaries) {
      switch (student.attendanceStatus) {
        case AttendanceStatus.present:
          presentCount++;
        case AttendanceStatus.absent:
          absentCount++;
        case AttendanceStatus.excusedAbsent:
          excusedAbsentCount++;
        case null:
          unsetCount++;
      }
    }

    return HalaqahDaySummary(
      day: day,
      students: List<DayStudentSummary>.unmodifiable(studentSummaries),
      attendance: AttendanceSummaryCounts(
        totalStudents: studentSummaries.length,
        presentCount: presentCount,
        absentCount: absentCount,
        excusedAbsentCount: excusedAbsentCount,
        unsetCount: unsetCount,
      ),
    );
  }
}
