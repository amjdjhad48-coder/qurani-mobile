import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/shared/clock.dart';

import '../../helpers/fake_clock.dart';

void main() {
  group('SystemClock', () {
    test('nowUtc returns a UTC timestamp', () {
      const clock = SystemClock();

      final value = clock.nowUtc();

      expect(value.isUtc, isTrue);
    });

    test('todayLocal returns the local calendar date at midnight', () {
      const clock = SystemClock();

      final today = clock.todayLocal();

      expect(today.isUtc, isFalse);
      expect(today.hour, 0);
      expect(today.minute, 0);
      expect(today.second, 0);
      expect(today.millisecond, 0);
      expect(today.microsecond, 0);

      final currentLocal = DateTime.now();
      expect(today.year, currentLocal.year);
      expect(today.month, currentLocal.month);
      expect(today.day, currentLocal.day);
    });
  });

  group('FakeClock', () {
    test('returns the fixed UTC instant deterministically', () {
      final clock = FakeClock(
        nowUtc: DateTime.parse('2026-09-03T07:15:30+03:00'),
        todayLocal: DateTime(2026, 9, 3, 14, 45),
      );

      expect(clock.nowUtc(), DateTime.utc(2026, 9, 3, 4, 15, 30));
      expect(clock.nowUtc().isUtc, isTrue);
    });

    test('returns a normalized fixed local calendar date', () {
      final clock = FakeClock(
        nowUtc: DateTime.utc(2026, 9, 2, 22, 30),
        todayLocal: DateTime(2026, 9, 3, 8, 20, 10),
      );

      expect(clock.todayLocal(), DateTime(2026, 9, 3));
      expect(clock.todayLocal().isUtc, isFalse);
    });

    test('separates event time from the local business date', () {
      final clock = FakeClock(
        nowUtc: DateTime.utc(2026, 9, 2, 22, 30),
        todayLocal: DateTime(2026, 9, 3),
      );

      expect(clock.nowUtc(), DateTime.utc(2026, 9, 2, 22, 30));
      expect(clock.todayLocal(), DateTime(2026, 9, 3));
    });
  });
}
