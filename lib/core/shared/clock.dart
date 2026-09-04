abstract interface class Clock {
  DateTime nowUtc();

  DateTime todayLocal();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  DateTime todayLocal() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
