import 'package:qurani/core/shared/clock.dart';

final class FakeClock implements Clock {
  FakeClock({required DateTime nowUtc, required DateTime todayLocal})
    : _nowUtc = nowUtc.toUtc(),
      _todayLocal = DateTime(todayLocal.year, todayLocal.month, todayLocal.day);

  final DateTime _nowUtc;
  final DateTime _todayLocal;

  @override
  DateTime nowUtc() => _nowUtc;

  @override
  DateTime todayLocal() => _todayLocal;
}
