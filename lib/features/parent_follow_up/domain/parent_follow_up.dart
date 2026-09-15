import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

enum ParentFollowUpType {
  daily('daily'),
  attendanceCorrection('attendance_correction');

  const ParentFollowUpType(this.storageValue);

  final String storageValue;

  static ParentFollowUpType fromStorage(String value) {
    return switch (value) {
      'daily' => ParentFollowUpType.daily,
      'attendance_correction' => ParentFollowUpType.attendanceCorrection,
      _ => throw StateError('Unsupported parent follow up type: $value'),
    };
  }
}

enum ParentFollowUpStatus {
  pending('pending'),
  handled('handled');

  const ParentFollowUpStatus(this.storageValue);

  final String storageValue;

  static ParentFollowUpStatus fromStorage(String value) {
    return switch (value) {
      'pending' => ParentFollowUpStatus.pending,
      'handled' => ParentFollowUpStatus.handled,
      _ => throw StateError('Unsupported parent follow up status: $value'),
    };
  }
}

enum ParentFollowUpChannel {
  sms('sms'),
  whatsapp('whatsapp');

  const ParentFollowUpChannel(this.storageValue);

  final String storageValue;

  static ParentFollowUpChannel fromStorage(String value) {
    return switch (value) {
      'sms' => ParentFollowUpChannel.sms,
      'whatsapp' => ParentFollowUpChannel.whatsapp,
      _ => throw StateError('Unsupported parent follow up channel: $value'),
    };
  }
}

enum ParentFollowUpAttendanceStatus {
  present('present', 'حاضر'),
  absent('absent', 'غائب'),
  excusedAbsent('excused_absent', 'غائب بعذر');

  const ParentFollowUpAttendanceStatus(this.storageValue, this.arabicLabel);

  final String storageValue;
  final String arabicLabel;

  static ParentFollowUpAttendanceStatus fromStorage(String value) {
    return switch (value) {
      'present' => ParentFollowUpAttendanceStatus.present,
      'absent' => ParentFollowUpAttendanceStatus.absent,
      'excused_absent' => ParentFollowUpAttendanceStatus.excusedAbsent,
      _ => throw StateError(
        'Unsupported parent follow up attendance status: $value',
      ),
    };
  }
}

final class ParentFollowUpHandledSnapshot {
  const ParentFollowUpHandledSnapshot({
    required this.attendanceStatus,
    required this.message,
    required this.channel,
    required this.recipient,
  });

  final ParentFollowUpAttendanceStatus attendanceStatus;
  final String message;
  final ParentFollowUpChannel channel;
  final String recipient;
}

final class ParentFollowUpRecord {
  const ParentFollowUpRecord({
    required this.id,
    required this.dayId,
    required this.studentId,
    required this.type,
    required this.status,
    required this.correctsFollowUpId,
    required this.handledSnapshot,
  });

  final int id;
  final int dayId;
  final int studentId;
  final ParentFollowUpType type;
  final ParentFollowUpStatus status;
  final int? correctsFollowUpId;
  final ParentFollowUpHandledSnapshot? handledSnapshot;

  bool get isPending => status == ParentFollowUpStatus.pending;

  bool get isHandled => status == ParentFollowUpStatus.handled;

  bool get isDaily => type == ParentFollowUpType.daily;

  bool get isAttendanceCorrection =>
      type == ParentFollowUpType.attendanceCorrection;
}

final class ParentFollowUpRecitationPreview {
  const ParentFollowUpRecitationPreview({
    required this.type,
    required this.actualRange,
    required this.facesQuarterAchieved,
    required this.evaluation,
    this.note,
  });

  final RecitationType type;
  final QuranRange actualRange;
  final int facesQuarterAchieved;
  final RecitationEvaluation evaluation;
  final String? note;

  bool get isNewMemorization => type == RecitationType.newMemorization;
}

final class ParentFollowUpDailyPreviewInput {
  const ParentFollowUpDailyPreviewInput({
    required this.studentName,
    required this.dayDate,
    required this.attendanceStatus,
    required this.recitations,
    required this.teacherName,
    required this.halaqahName,
    this.centerName,
  });

  final String studentName;
  final String dayDate;
  final ParentFollowUpAttendanceStatus attendanceStatus;
  final List<ParentFollowUpRecitationPreview> recitations;
  final String teacherName;
  final String halaqahName;
  final String? centerName;
}

final class ParentFollowUpAttendanceCorrectionInput {
  const ParentFollowUpAttendanceCorrectionInput({
    required this.studentName,
    required this.dayDate,
    required this.previousStatus,
    required this.currentStatus,
    required this.teacherName,
    required this.halaqahName,
    this.centerName,
  });

  final String studentName;
  final String dayDate;
  final ParentFollowUpAttendanceStatus previousStatus;
  final ParentFollowUpAttendanceStatus currentStatus;
  final String teacherName;
  final String halaqahName;
  final String? centerName;
}

final class PreparedParentFollowUpPayload {
  const PreparedParentFollowUpPayload({
    required this.followUpId,
    required this.attendanceStatus,
    required this.message,
    required this.channel,
    required this.recipient,
  });

  final int followUpId;
  final ParentFollowUpAttendanceStatus attendanceStatus;
  final String message;
  final ParentFollowUpChannel channel;
  final String recipient;

  ParentFollowUpHandledSnapshot toHandledSnapshot() {
    return ParentFollowUpHandledSnapshot(
      attendanceStatus: attendanceStatus,
      message: message,
      channel: channel,
      recipient: recipient,
    );
  }
}
