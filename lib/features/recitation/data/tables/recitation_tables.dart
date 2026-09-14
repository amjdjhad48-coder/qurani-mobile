import 'package:drift/drift.dart';
import 'package:qurani/features/daily_halaqah/data/tables/halaqah_day_tables.dart';
import 'package:qurani/features/students/data/tables/student_tables.dart';

class Recitations extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get dayId =>
      integer().references(HalaqahDays, #id, onDelete: KeyAction.restrict)();

  IntColumn get studentId =>
      integer().references(Students, #id, onDelete: KeyAction.restrict)();

  TextColumn get type => text()();

  IntColumn get startSurah => integer()();

  IntColumn get startAyah => integer()();

  IntColumn get endSurah => integer()();

  IntColumn get endAyah => integer()();

  IntColumn get facesQuarterAchieved => integer()();

  TextColumn get evaluation => text()();

  IntColumn get errorCount => integer().withDefault(const Constant(0))();

  TextColumn get note => text().nullable()();

  IntColumn get plannedStartSurah => integer().nullable()();

  IntColumn get plannedStartAyah => integer().nullable()();

  IntColumn get plannedEndSurah => integer().nullable()();

  IntColumn get plannedEndAyah => integer().nullable()();

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (type IN ('new_memorization', 'revision'))",
    'CHECK (start_surah BETWEEN 1 AND 114)',
    'CHECK (end_surah BETWEEN 1 AND 114)',
    'CHECK (start_ayah >= 1)',
    'CHECK (end_ayah >= 1)',
    'CHECK (faces_quarter_achieved > 0)',
    "CHECK (evaluation IN ('talqin', 'excellent', 'very_good', 'good', 'acceptable', 'weak'))",
    'CHECK (error_count >= 0)',
    'CHECK ('
        '(planned_start_surah IS NULL '
        'AND planned_start_ayah IS NULL '
        'AND planned_end_surah IS NULL '
        'AND planned_end_ayah IS NULL) '
        'OR '
        '(planned_start_surah IS NOT NULL '
        'AND planned_start_ayah IS NOT NULL '
        'AND planned_end_surah IS NOT NULL '
        'AND planned_end_ayah IS NOT NULL)'
        ')',
    'CHECK (planned_start_surah IS NULL '
        'OR planned_start_surah BETWEEN 1 AND 114)',
    'CHECK (planned_end_surah IS NULL '
        'OR planned_end_surah BETWEEN 1 AND 114)',
    'CHECK (planned_start_ayah IS NULL OR planned_start_ayah >= 1)',
    'CHECK (planned_end_ayah IS NULL OR planned_end_ayah >= 1)',
  ];
}
