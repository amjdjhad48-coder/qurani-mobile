import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah_repository.dart';

final class DailyHalaqahService {
  const DailyHalaqahService({
    required DailyHalaqahRepository repository,
    required Clock clock,
  }) : this._(repository, clock);

  const DailyHalaqahService._(this._repository, this._clock);

  final DailyHalaqahRepository _repository;
  final Clock _clock;

  Future<HalaqahDayRecord> ensureToday({required int halaqahId}) {
    return _repository.ensureDay(
      halaqahId: halaqahId,
      dayDate: _localDateText(_clock.todayLocal()),
    );
  }

  Future<HalaqahDayRecord?> findToday({required int halaqahId}) {
    return _repository.findDay(
      halaqahId: halaqahId,
      dayDate: _localDateText(_clock.todayLocal()),
    );
  }

  Future<DailyHalaqahSession> startToday({required int halaqahId}) async {
    final day = await ensureToday(halaqahId: halaqahId);

    final students = await _repository.historicallyActiveStudents(
      halaqahId: halaqahId,
      dayDate: day.dayDate,
    );

    return DailyHalaqahSession(
      day: day,
      students: List<DailyHalaqahStudentRecord>.unmodifiable(students),
    );
  }

  Future<List<DailyHalaqahStudentRecord>> studentsActiveOn({
    required int halaqahId,
    required DateTime localDate,
  }) {
    return _repository.historicallyActiveStudents(
      halaqahId: halaqahId,
      dayDate: _localDateText(localDate),
    );
  }

  Future<StudentAttendanceRecord> setAttendance({
    required int halaqahId,
    required int dayId,
    required int studentId,
    required AttendanceStatus status,
  }) async {
    final day = await _requiredDayForHalaqah(
      halaqahId: halaqahId,
      dayId: dayId,
    );

    if (day.isHoliday) {
      throw StateError('Attendance cannot be recorded for a holiday.');
    }

    final students = await _repository.historicallyActiveStudents(
      halaqahId: halaqahId,
      dayDate: day.dayDate,
    );

    final eligible = students.any((student) => student.id == studentId);

    if (!eligible) {
      throw StateError('Student $studentId was not active on ${day.dayDate}.');
    }

    return _repository.setAttendance(
      dayId: dayId,
      studentId: studentId,
      status: status,
    );
  }

  Future<List<StudentAttendanceRecord>> attendanceForDay({
    required int halaqahId,
    required int dayId,
  }) async {
    await _requiredDayForHalaqah(halaqahId: halaqahId, dayId: dayId);

    return _repository.attendanceForDay(dayId);
  }

  Future<int> markAllPresent({
    required int halaqahId,
    required int dayId,
  }) async {
    final day = await _requiredDayForHalaqah(
      halaqahId: halaqahId,
      dayId: dayId,
    );

    if (day.isHoliday) {
      throw StateError('Attendance cannot be recorded for a holiday.');
    }

    final students = await _repository.historicallyActiveStudents(
      halaqahId: halaqahId,
      dayDate: day.dayDate,
    );

    return _repository.markUnspecifiedPresent(
      dayId: dayId,
      studentIds: students.map((student) => student.id).toList(growable: false),
    );
  }

  Future<HalaqahDayRecord> _requiredDayForHalaqah({
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

    return day;
  }

  String _localDateText(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
