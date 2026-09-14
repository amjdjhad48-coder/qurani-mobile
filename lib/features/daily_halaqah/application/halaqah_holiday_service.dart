import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah_repository.dart';

final class HalaqahHolidayService {
  const HalaqahHolidayService(this._repository);

  final DailyHalaqahRepository _repository;

  Future<HalaqahDayRecord> markDay({
    required int halaqahId,
    required DateTime localDate,
  }) async {
    final days = await markRange(
      halaqahId: halaqahId,
      startLocalDate: localDate,
      endLocalDate: localDate,
    );

    return days.single;
  }

  Future<List<HalaqahDayRecord>> markRange({
    required int halaqahId,
    required DateTime startLocalDate,
    required DateTime endLocalDate,
  }) {
    final start = _dateOnly(startLocalDate);
    final end = _dateOnly(endLocalDate);

    if (end.isBefore(start)) {
      throw ArgumentError.value(
        endLocalDate,
        'endLocalDate',
        'Holiday range end must not be before start.',
      );
    }

    final dayDates = <String>[];
    var cursor = start;

    while (!cursor.isAfter(end)) {
      dayDates.add(_localDateText(cursor));

      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }

    return _repository.markHolidayRange(
      halaqahId: halaqahId,
      dayDates: dayDates,
    );
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String _localDateText(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
