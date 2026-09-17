import 'package:drift/drift.dart';
import 'package:qurani/features/setup/data/tables/setup_tables.dart';
import 'package:qurani/features/students/data/tables/student_tables.dart';

class SupportWeeklyReports extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get halaqahId =>
      integer().references(Halaqahs, #id, onDelete: KeyAction.restrict)();

  TextColumn get weekStartDate => text().withLength(min: 10, max: 10)();

  TextColumn get weekEndDate => text().withLength(min: 10, max: 10)();

  TextColumn get status => text()();

  TextColumn get teacherNameSnapshot => text().withLength(min: 1, max: 200)();

  TextColumn get halaqahNameSnapshot => text().withLength(min: 1, max: 200)();

  TextColumn get organizationNameSnapshot =>
      text().withLength(min: 1, max: 200)();

  IntColumn get policyVersion => integer()();

  IntColumn get templateVersion => integer()();

  TextColumn get sourceFingerprint => text().nullable()();

  DateTimeColumn get approvedAtUtc => dateTime().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{halaqahId, weekStartDate},
  ];

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (status IN ('draft', 'approved'))",
    'CHECK (week_end_date >= week_start_date)',
    'CHECK (length(trim(teacher_name_snapshot)) > 0)',
    'CHECK (length(trim(halaqah_name_snapshot)) > 0)',
    'CHECK (length(trim(organization_name_snapshot)) > 0)',
    'CHECK (policy_version > 0)',
    'CHECK (template_version > 0)',
    'CHECK ('
        "(status = 'draft' "
        'AND source_fingerprint IS NULL '
        'AND approved_at_utc IS NULL) '
        'OR '
        "(status = 'approved' "
        'AND source_fingerprint IS NOT NULL '
        'AND length(trim(source_fingerprint)) > 0 '
        'AND approved_at_utc IS NOT NULL)'
        ')',
  ];
}

class SupportWeeklyReportStudents extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get reportId => integer().references(
    SupportWeeklyReports,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get sourceStudentId =>
      integer().references(Students, #id, onDelete: KeyAction.restrict)();

  TextColumn get supportStudentNumberSnapshot => text().nullable()();

  TextColumn get studentNameSnapshot => text().withLength(min: 1, max: 200)();

  IntColumn get currentJuzSnapshot => integer().nullable()();

  TextColumn get dailyPlanTextSnapshot => text().nullable()();

  IntColumn get monthlyGoalQuarterFacesSnapshot => integer()();

  TextColumn get studentNoteSnapshot => text().nullable()();

  IntColumn get displayOrderSnapshot => integer()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{reportId, sourceStudentId},
  ];

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (length(trim(student_name_snapshot)) > 0)',
    'CHECK (current_juz_snapshot IS NULL '
        'OR current_juz_snapshot BETWEEN 1 AND 30)',
    'CHECK (support_student_number_snapshot IS NULL '
        'OR length(trim(support_student_number_snapshot)) > 0)',
    'CHECK (daily_plan_text_snapshot IS NULL '
        'OR length(trim(daily_plan_text_snapshot)) > 0)',
    'CHECK (monthly_goal_quarter_faces_snapshot > 0)',
    'CHECK (display_order_snapshot > 0)',
  ];
}

class SupportWeeklyReportDays extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get reportId => integer().references(
    SupportWeeklyReports,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get dayDate => text().withLength(min: 10, max: 10)();

  TextColumn get dayKind => text()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{reportId, dayDate},
  ];

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (day_kind IN "
        "('normal', 'holiday', 'missing', 'not_applicable'))",
  ];
}

class SupportWeeklyReportDayEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get reportDayId => integer().references(
    SupportWeeklyReportDays,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get reportStudentId => integer().references(
    SupportWeeklyReportStudents,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get attendanceStatusSnapshot => text().nullable()();

  IntColumn get achievedQuarterFaces =>
      integer().withDefault(const Constant(0))();

  IntColumn get startSurahSnapshot => integer().nullable()();

  IntColumn get startAyahSnapshot => integer().nullable()();

  IntColumn get endSurahSnapshot => integer().nullable()();

  IntColumn get endAyahSnapshot => integer().nullable()();

  TextColumn get noteSnapshot => text().nullable()();

  IntColumn get entryOrder => integer()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{reportDayId, reportStudentId, entryOrder},
  ];

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (attendance_status_snapshot IS NULL '
        "OR attendance_status_snapshot IN "
        "('present', 'absent', 'excused_absent'))",
    'CHECK (achieved_quarter_faces >= 0)',
    'CHECK (entry_order > 0)',
    'CHECK ('
        '(start_surah_snapshot IS NULL '
        'AND start_ayah_snapshot IS NULL '
        'AND end_surah_snapshot IS NULL '
        'AND end_ayah_snapshot IS NULL) '
        'OR '
        '(start_surah_snapshot IS NOT NULL '
        'AND start_ayah_snapshot IS NOT NULL '
        'AND end_surah_snapshot IS NOT NULL '
        'AND end_ayah_snapshot IS NOT NULL)'
        ')',
    'CHECK (start_surah_snapshot IS NULL '
        'OR start_surah_snapshot BETWEEN 1 AND 114)',
    'CHECK (end_surah_snapshot IS NULL '
        'OR end_surah_snapshot BETWEEN 1 AND 114)',
    'CHECK (start_ayah_snapshot IS NULL '
        'OR start_ayah_snapshot >= 1)',
    'CHECK (end_ayah_snapshot IS NULL '
        'OR end_ayah_snapshot >= 1)',
    'CHECK ('
        '(start_surah_snapshot IS NULL '
        'AND achieved_quarter_faces = 0) '
        'OR '
        '(start_surah_snapshot IS NOT NULL '
        'AND achieved_quarter_faces > 0)'
        ')',
  ];
}

class SupportMonthlyReports extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get halaqahId =>
      integer().references(Halaqahs, #id, onDelete: KeyAction.restrict)();

  TextColumn get monthStartDate => text().withLength(min: 10, max: 10)();

  TextColumn get monthEndDate => text().withLength(min: 10, max: 10)();

  TextColumn get status => text()();

  TextColumn get teacherNameSnapshot => text().withLength(min: 1, max: 200)();

  TextColumn get halaqahNameSnapshot => text().withLength(min: 1, max: 200)();

  TextColumn get organizationNameSnapshot =>
      text().withLength(min: 1, max: 200)();

  IntColumn get policyVersion => integer()();

  IntColumn get templateVersion => integer()();

  TextColumn get sourceFingerprint => text().nullable()();

  DateTimeColumn get approvedAtUtc => dateTime().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{halaqahId, monthStartDate},
  ];

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (status IN ('draft', 'approved'))",
    'CHECK (month_end_date >= month_start_date)',
    'CHECK (length(trim(teacher_name_snapshot)) > 0)',
    'CHECK (length(trim(halaqah_name_snapshot)) > 0)',
    'CHECK (length(trim(organization_name_snapshot)) > 0)',
    'CHECK (policy_version > 0)',
    'CHECK (template_version > 0)',
    'CHECK ('
        "(status = 'draft' "
        'AND source_fingerprint IS NULL '
        'AND approved_at_utc IS NULL) '
        'OR '
        "(status = 'approved' "
        'AND source_fingerprint IS NOT NULL '
        'AND length(trim(source_fingerprint)) > 0 '
        'AND approved_at_utc IS NOT NULL)'
        ')',
  ];
}

class SupportMonthlyReportStudents extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get reportId => integer().references(
    SupportMonthlyReports,
    #id,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get sourceStudentId =>
      integer().references(Students, #id, onDelete: KeyAction.restrict)();

  TextColumn get supportStudentNumberSnapshot => text().nullable()();

  TextColumn get studentNameSnapshot => text().withLength(min: 1, max: 200)();

  IntColumn get currentJuzSnapshot => integer().nullable()();

  TextColumn get dailyPlanTextSnapshot => text().nullable()();

  IntColumn get monthlyGoalQuarterFacesSnapshot => integer()();

  IntColumn get achievedQuarterFaces => integer()();

  IntColumn get absenceDays => integer()();

  BoolColumn get goalCompleted => boolean()();

  TextColumn get noteSnapshot => text().nullable()();

  IntColumn get displayOrderSnapshot => integer()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{reportId, sourceStudentId},
  ];

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (length(trim(student_name_snapshot)) > 0)',
    'CHECK (current_juz_snapshot IS NULL '
        'OR current_juz_snapshot BETWEEN 1 AND 30)',
    'CHECK (support_student_number_snapshot IS NULL '
        'OR length(trim(support_student_number_snapshot)) > 0)',
    'CHECK (daily_plan_text_snapshot IS NULL '
        'OR length(trim(daily_plan_text_snapshot)) > 0)',
    'CHECK (monthly_goal_quarter_faces_snapshot > 0)',
    'CHECK (achieved_quarter_faces >= 0)',
    'CHECK (absence_days >= 0)',
    'CHECK (display_order_snapshot > 0)',
  ];
}
