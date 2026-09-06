import 'package:drift/drift.dart';

class Halaqahs extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get teacherName => text().withLength(min: 1, max: 200)();

  TextColumn get halaqahName => text().withLength(min: 1, max: 200)();

  TextColumn get centerName => text().withLength(min: 1, max: 200)();

  DateTimeColumn get createdAtUtc => dateTime()();

  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (length(trim(teacher_name)) > 0)',
    'CHECK (length(trim(halaqah_name)) > 0)',
    'CHECK (length(trim(center_name)) > 0)',
  ];
}

class SupportProgramSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get halaqahId =>
      integer().references(Halaqahs, #id, onDelete: KeyAction.restrict)();

  TextColumn get status => text()();

  TextColumn get organizationName => text().nullable()();

  DateTimeColumn get createdAtUtc => dateTime()();

  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {halaqahId},
  ];

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (status IN ('disabled', 'pending_activation', 'enabled'))",
    "CHECK ("
        "(status = 'disabled' AND organization_name IS NULL) OR "
        "(status IN ('pending_activation', 'enabled') "
        "AND organization_name IS NOT NULL "
        "AND length(trim(organization_name)) > 0)"
        ")",
  ];
}

class SupportProgramPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get halaqahId =>
      integer().references(Halaqahs, #id, onDelete: KeyAction.restrict)();

  TextColumn get organizationName => text().withLength(min: 1, max: 200)();

  DateTimeColumn get startedAtUtc => dateTime()();

  DateTimeColumn get endedAtUtc => dateTime().nullable()();

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (length(trim(organization_name)) > 0)',
    'CHECK (ended_at_utc IS NULL OR ended_at_utc > started_at_utc)',
  ];
}
