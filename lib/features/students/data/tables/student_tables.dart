import 'package:drift/drift.dart';
import 'package:qurani/features/setup/data/tables/setup_tables.dart';

class Students extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get halaqahId =>
      integer().references(Halaqahs, #id, onDelete: KeyAction.restrict)();

  TextColumn get studentName => text()();

  TextColumn get fatherName => text()();

  IntColumn get ageYears => integer()();

  TextColumn get guardianCountryCode => text().withLength(min: 4, max: 4)();

  TextColumn get guardianNationalNumber => text()();

  TextColumn get previousMemorizationText => text()();

  TextColumn get note => text().nullable()();

  TextColumn get supportStudentNumber => text().nullable()();

  IntColumn get displayOrder => integer()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get archivedAtUtc => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {halaqahId, supportStudentNumber},
  ];

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (length(trim(student_name)) > 0)',
    'CHECK (length(trim(father_name)) > 0)',
    "CHECK (guardian_country_code IN ('+967', '+966'))",
    'CHECK (length(trim(guardian_national_number)) > 0)',
    'CHECK (length(trim(previous_memorization_text)) > 0)',
    'CHECK ('
        'support_student_number IS NULL '
        'OR length(trim(support_student_number)) > 0'
        ')',
  ];
}

class StudentProgressPlans extends Table {
  IntColumn get studentId =>
      integer().references(Students, #id, onDelete: KeyAction.restrict)();

  IntColumn get currentJuz => integer().nullable()();

  TextColumn get dailyPlanText => text().nullable()();

  @override
  Set<Column> get primaryKey => {studentId};

  @override
  List<String> get customConstraints => const <String>[
    'CHECK ('
        'current_juz IS NULL '
        'OR (current_juz >= 1 AND current_juz <= 30)'
        ')',
  ];
}

class StudentActivityPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get studentId =>
      integer().references(Students, #id, onDelete: KeyAction.restrict)();

  TextColumn get activeFromDate => text().withLength(min: 10, max: 10)();

  TextColumn get activeToDate =>
      text().withLength(min: 10, max: 10).nullable()();

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (active_to_date IS NULL OR active_to_date >= active_from_date)',
  ];
}
