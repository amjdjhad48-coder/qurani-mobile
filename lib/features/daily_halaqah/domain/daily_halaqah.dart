enum AttendanceStatus {
  present('present'),
  absent('absent'),
  excusedAbsent('excused_absent');

  const AttendanceStatus(this.storageValue);

  final String storageValue;

  static AttendanceStatus fromStorage(String value) {
    return switch (value) {
      'present' => AttendanceStatus.present,
      'absent' => AttendanceStatus.absent,
      'excused_absent' => AttendanceStatus.excusedAbsent,
      _ => throw StateError('Unsupported attendance status: $value'),
    };
  }
}

final class HalaqahDayRecord {
  const HalaqahDayRecord({
    required this.id,
    required this.halaqahId,
    required this.dayDate,
    required this.status,
  });

  final int id;
  final int halaqahId;
  final String dayDate;
  final String status;

  bool get isOpen => status == 'open';
  bool get isClosed => status == 'closed';
  bool get isHoliday => status == 'holiday';
}

final class DailyHalaqahStudentRecord {
  const DailyHalaqahStudentRecord({
    required this.id,
    required this.studentName,
    required this.displayOrder,
  });

  final int id;
  final String studentName;
  final int displayOrder;
}

final class StudentAttendanceRecord {
  const StudentAttendanceRecord({
    required this.id,
    required this.dayId,
    required this.studentId,
    required this.status,
  });

  final int id;
  final int dayId;
  final int studentId;
  final AttendanceStatus status;
}

final class DailyHalaqahSession {
  const DailyHalaqahSession({required this.day, required this.students});

  final HalaqahDayRecord day;
  final List<DailyHalaqahStudentRecord> students;
}

final class HolidayConflictException implements Exception {
  HolidayConflictException(Iterable<String> conflictingDayDates)
    : conflictingDayDates = List<String>.unmodifiable(conflictingDayDates);

  final List<String> conflictingDayDates;
}

final class AttendanceSummaryCounts {
  const AttendanceSummaryCounts({
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.excusedAbsentCount,
    required this.unsetCount,
  });

  const AttendanceSummaryCounts.zero()
    : totalStudents = 0,
      presentCount = 0,
      absentCount = 0,
      excusedAbsentCount = 0,
      unsetCount = 0;

  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int excusedAbsentCount;
  final int unsetCount;
}

final class HalaqahDayHistoryItem {
  const HalaqahDayHistoryItem({required this.day, required this.attendance});

  final HalaqahDayRecord day;
  final AttendanceSummaryCounts attendance;
}

final class DayStudentSummary {
  const DayStudentSummary({
    required this.student,
    required this.attendanceStatus,
  });

  final DailyHalaqahStudentRecord student;
  final AttendanceStatus? attendanceStatus;

  bool get isAttendanceUnset => attendanceStatus == null;
}

final class HalaqahDaySummary {
  const HalaqahDaySummary({
    required this.day,
    required this.students,
    required this.attendance,
  });

  final HalaqahDayRecord day;
  final List<DayStudentSummary> students;
  final AttendanceSummaryCounts attendance;
}
