import 'package:drift/drift.dart';
import 'package:qurani/features/daily_halaqah/data/tables/halaqah_day_tables.dart';
import 'package:qurani/features/students/data/tables/student_tables.dart';

class ParentFollowUps extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get dayId =>
      integer().references(HalaqahDays, #id, onDelete: KeyAction.restrict)();

  IntColumn get studentId =>
      integer().references(Students, #id, onDelete: KeyAction.restrict)();

  TextColumn get type => text()();

  TextColumn get status => text().withDefault(const Constant('pending'))();

  IntColumn get correctsFollowUpId => integer()
      .references(ParentFollowUps, #id, onDelete: KeyAction.restrict)
      .nullable()();

  TextColumn get attendanceStatusSnapshot => text().nullable()();

  TextColumn get snapshotMessage => text().nullable()();

  TextColumn get channelSnapshot => text().nullable()();

  TextColumn get recipientSnapshot => text().nullable()();

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (type IN ('daily', 'attendance_correction'))",
    "CHECK (status IN ('pending', 'handled'))",
    'CHECK ('
        "(type = 'daily' AND corrects_follow_up_id IS NULL) "
        'OR '
        "(type = 'attendance_correction' "
        'AND corrects_follow_up_id IS NOT NULL)'
        ')',
    'CHECK ('
        'attendance_status_snapshot IS NULL '
        "OR attendance_status_snapshot IN "
        "('present', 'absent', 'excused_absent')"
        ')',
    'CHECK ('
        'channel_snapshot IS NULL '
        "OR channel_snapshot IN ('sms', 'whatsapp')"
        ')',
    'CHECK ('
        'snapshot_message IS NULL '
        'OR length(trim(snapshot_message)) > 0'
        ')',
    'CHECK ('
        'recipient_snapshot IS NULL '
        'OR length(trim(recipient_snapshot)) > 0'
        ')',
    'CHECK ('
        "(status = 'pending' "
        'AND attendance_status_snapshot IS NULL '
        'AND snapshot_message IS NULL '
        'AND channel_snapshot IS NULL '
        'AND recipient_snapshot IS NULL) '
        'OR '
        "(status = 'handled' "
        'AND attendance_status_snapshot IS NOT NULL '
        'AND snapshot_message IS NOT NULL '
        'AND channel_snapshot IS NOT NULL '
        'AND recipient_snapshot IS NOT NULL)'
        ')',
  ];
}
