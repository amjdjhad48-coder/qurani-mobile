import 'package:drift/drift.dart';
import 'package:qurani/features/setup/data/tables/setup_tables.dart';
import 'package:qurani/features/students/data/tables/student_tables.dart';

class HalaqahDays extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get halaqahId =>
      integer().references(Halaqahs, #id, onDelete: KeyAction.restrict)();

  TextColumn get dayDate => text().withLength(min: 10, max: 10)();

  TextColumn get status => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {halaqahId, dayDate},
  ];

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (status IN ('open', 'closed', 'holiday'))",
  ];
}

class AttendanceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get dayId =>
      integer().references(HalaqahDays, #id, onDelete: KeyAction.restrict)();

  IntColumn get studentId =>
      integer().references(Students, #id, onDelete: KeyAction.restrict)();

  TextColumn get status => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {dayId, studentId},
  ];

  @override
  List<String> get customConstraints => const <String>[
    // Persisted token follows the approved Phase 5 data design.
    "CHECK (status IN ('present', 'absent', 'excused_absent'))",
  ];
}
