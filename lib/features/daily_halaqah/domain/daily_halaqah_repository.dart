import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';

abstract interface class DailyHalaqahRepository {
  Future<HalaqahDayRecord> ensureDay({
    required int halaqahId,
    required String dayDate,
  });

  Future<HalaqahDayRecord?> findDay({
    required int halaqahId,
    required String dayDate,
  });

  Future<HalaqahDayRecord?> findDayById(int dayId);

  Future<List<DailyHalaqahStudentRecord>> historicallyActiveStudents({
    required int halaqahId,
    required String dayDate,
  });

  Future<StudentAttendanceRecord> setAttendance({
    required int dayId,
    required int studentId,
    required AttendanceStatus status,
  });

  Future<List<StudentAttendanceRecord>> attendanceForDay(int dayId);

  Future<int> markUnspecifiedPresent({
    required int dayId,
    required List<int> studentIds,
  });

  Future<HalaqahDayRecord> closeDay(int dayId);

  Future<List<HalaqahDayRecord>> markHolidayRange({
    required int halaqahId,
    required List<String> dayDates,
  });

  Future<List<HalaqahDayHistoryItem>> dayHistory({required int halaqahId});
}
