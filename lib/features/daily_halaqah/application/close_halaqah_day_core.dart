import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah_repository.dart';

final class IncompleteAttendanceException implements Exception {
  IncompleteAttendanceException(Iterable<int> missingStudentIds)
    : missingStudentIds = List<int>.unmodifiable(missingStudentIds);

  final List<int> missingStudentIds;

  int get missingCount => missingStudentIds.length;
}

final class CloseHalaqahDayCore {
  const CloseHalaqahDayCore(this._repository);

  final DailyHalaqahRepository _repository;

  Future<HalaqahDayRecord> call({
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
      throw StateError('A holiday cannot be closed as an active halaqah day.');
    }

    if (day.isClosed) {
      return day;
    }

    if (!day.isOpen) {
      throw StateError('Halaqah day $dayId is not open.');
    }

    final students = await _repository.historicallyActiveStudents(
      halaqahId: halaqahId,
      dayDate: day.dayDate,
    );

    final attendance = await _repository.attendanceForDay(dayId);

    final specifiedStudentIds = attendance
        .map((record) => record.studentId)
        .toSet();

    final missingStudentIds = students
        .where((student) => !specifiedStudentIds.contains(student.id))
        .map((student) => student.id)
        .toList(growable: false);

    if (missingStudentIds.isNotEmpty) {
      throw IncompleteAttendanceException(missingStudentIds);
    }

    return _repository.closeDay(dayId);
  }
}
