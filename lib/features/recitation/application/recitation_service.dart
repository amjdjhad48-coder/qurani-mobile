import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah_repository.dart';
import 'package:qurani/features/recitation/application/recitation_validator.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';
import 'package:qurani/features/recitation/domain/recitation_repository.dart';

final class RecitationOnHolidayException implements Exception {
  const RecitationOnHolidayException(this.dayDate);

  final String dayDate;

  @override
  String toString() {
    return 'Recitation is not allowed on holiday $dayDate.';
  }
}

final class RecitationService {
  const RecitationService({
    required RecitationRepository repository,
    required DailyHalaqahRepository dailyHalaqahRepository,
    required Clock clock,
    RecitationValidator validator = const RecitationValidator(),
  }) : this._(repository, dailyHalaqahRepository, clock, validator);

  const RecitationService._(
    this._repository,
    this._dailyHalaqahRepository,
    this._clock,
    this._validator,
  );

  final RecitationRepository _repository;
  final DailyHalaqahRepository _dailyHalaqahRepository;
  final Clock _clock;
  final RecitationValidator _validator;

  Future<RecitationRecord> createToday({
    required int halaqahId,
    required int studentId,
    required RecitationWriteData data,
  }) async {
    final validated = _validator.validateAndNormalize(data);
    final dayDate = _localDateText(_clock.todayLocal());

    final existingDay = await _dailyHalaqahRepository.findDay(
      halaqahId: halaqahId,
      dayDate: dayDate,
    );

    if (existingDay?.isHoliday ?? false) {
      throw RecitationOnHolidayException(dayDate);
    }

    await _requireHistoricallyEligibleStudent(
      halaqahId: halaqahId,
      studentId: studentId,
      dayDate: dayDate,
    );

    final day =
        existingDay ??
        await _dailyHalaqahRepository.ensureDay(
          halaqahId: halaqahId,
          dayDate: dayDate,
        );

    if (day.isHoliday) {
      throw RecitationOnHolidayException(day.dayDate);
    }

    return _repository.create(
      dayId: day.id,
      studentId: studentId,
      data: validated,
    );
  }

  Future<RecitationRecord> createForDay({
    required int halaqahId,
    required int dayId,
    required int studentId,
    required RecitationWriteData data,
  }) async {
    final validated = _validator.validateAndNormalize(data);

    final day = await _requiredDayForHalaqah(
      halaqahId: halaqahId,
      dayId: dayId,
    );

    if (day.isHoliday) {
      throw RecitationOnHolidayException(day.dayDate);
    }

    await _requireHistoricallyEligibleStudent(
      halaqahId: halaqahId,
      studentId: studentId,
      dayDate: day.dayDate,
    );

    return _repository.create(
      dayId: day.id,
      studentId: studentId,
      data: validated,
    );
  }

  Future<RecitationRecord> update({
    required int halaqahId,
    required int recitationId,
    required RecitationWriteData data,
  }) async {
    final existing = await _repository.findById(recitationId);

    if (existing == null) {
      throw StateError('Recitation $recitationId was not found.');
    }

    final day = await _requiredDayForHalaqah(
      halaqahId: halaqahId,
      dayId: existing.dayId,
    );

    if (day.isHoliday) {
      throw RecitationOnHolidayException(day.dayDate);
    }

    final validated = _validator.validateAndNormalize(data);

    return _repository.update(recitationId: recitationId, data: validated);
  }

  Future<void> delete({
    required int halaqahId,
    required int recitationId,
  }) async {
    final existing = await _repository.findById(recitationId);

    if (existing == null) {
      throw StateError('Recitation $recitationId was not found.');
    }

    await _requiredDayForHalaqah(halaqahId: halaqahId, dayId: existing.dayId);

    await _repository.deleteById(recitationId);
  }

  Future<List<RecitationRecord>> listForDayStudent({
    required int halaqahId,
    required int dayId,
    required int studentId,
  }) async {
    await _requiredDayForHalaqah(halaqahId: halaqahId, dayId: dayId);

    return _repository.listForDayStudent(dayId: dayId, studentId: studentId);
  }

  Future<RecitationDerivedTotals> totalsForStudent({
    required int halaqahId,
    required int studentId,
  }) {
    return _repository.totalsForStudent(
      halaqahId: halaqahId,
      studentId: studentId,
    );
  }

  Future<RecitationDerivedTotals> totalsForDayStudent({
    required int halaqahId,
    required int dayId,
    required int studentId,
  }) async {
    await _requiredDayForHalaqah(halaqahId: halaqahId, dayId: dayId);

    return _repository.totalsForDayStudent(dayId: dayId, studentId: studentId);
  }

  Future<void> _requireHistoricallyEligibleStudent({
    required int halaqahId,
    required int studentId,
    required String dayDate,
  }) async {
    final students = await _dailyHalaqahRepository.historicallyActiveStudents(
      halaqahId: halaqahId,
      dayDate: dayDate,
    );

    final eligible = students.any((student) => student.id == studentId);

    if (!eligible) {
      throw StateError(
        'Student $studentId was not active in halaqah '
        '$halaqahId on $dayDate.',
      );
    }
  }

  Future<HalaqahDayRecord> _requiredDayForHalaqah({
    required int halaqahId,
    required int dayId,
  }) async {
    final day = await _dailyHalaqahRepository.findDayById(dayId);

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
