import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_message_builder.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_repository.dart';

final class ParentFollowUpService {
  const ParentFollowUpService({
    required ParentFollowUpRepository repository,
    ParentFollowUpMessageBuilder messageBuilder =
        const ParentFollowUpMessageBuilder(),
  }) : this._(repository, messageBuilder);

  const ParentFollowUpService._(this._repository, this._messageBuilder);

  final ParentFollowUpRepository _repository;
  final ParentFollowUpMessageBuilder _messageBuilder;

  Future<List<ParentFollowUpRecord>> listForDay(int dayId) {
    return _repository.listForDay(dayId);
  }

  Future<ParentFollowUpRecord> requiredFollowUp(int followUpId) async {
    final followUp = await _repository.findById(followUpId);

    if (followUp == null) {
      throw StateError('Parent follow up $followUpId was not found.');
    }

    return followUp;
  }

  Future<AttendanceCorrectionReconciliationResult>
  setAttendanceAndReconcileCorrection({
    required int halaqahId,
    required int dayId,
    required int studentId,
    required AttendanceStatus status,
  }) {
    return _repository.setAttendanceAndReconcileCorrection(
      halaqahId: halaqahId,
      dayId: dayId,
      studentId: studentId,
      status: status,
    );
  }

  Future<String> previewMessage(int followUpId) async {
    final followUp = await requiredFollowUp(followUpId);

    if (followUp.isHandled) {
      return followUp.handledSnapshot!.message;
    }

    if (followUp.isDaily) {
      final input = await _repository.loadLiveDailyPreview(followUpId);

      return _messageBuilder.buildDaily(input);
    }

    if (followUp.isAttendanceCorrection) {
      final input = await _repository.loadLiveAttendanceCorrectionPreview(
        followUpId,
      );

      return _messageBuilder.buildAttendanceCorrection(input);
    }

    throw StateError('Unsupported parent follow up type for $followUpId.');
  }

  Future<PreparedParentFollowUpPayload> preparePayload({
    required int followUpId,
    required ParentFollowUpChannel channel,
    required String recipient,
  }) async {
    final followUp = await requiredFollowUp(followUpId);

    if (!followUp.isPending) {
      throw StateError(
        'Only a pending parent follow up can prepare a new payload.',
      );
    }

    final normalizedRecipient = recipient.trim();

    if (normalizedRecipient.isEmpty) {
      throw ArgumentError.value(
        recipient,
        'recipient',
        'Recipient must not be blank.',
      );
    }

    late final ParentFollowUpAttendanceStatus attendanceStatus;
    late final String message;

    if (followUp.isDaily) {
      final input = await _repository.loadLiveDailyPreview(followUpId);

      attendanceStatus = input.attendanceStatus;
      message = _messageBuilder.buildDaily(input);
    } else if (followUp.isAttendanceCorrection) {
      final input = await _repository.loadLiveAttendanceCorrectionPreview(
        followUpId,
      );

      attendanceStatus = input.currentStatus;
      message = _messageBuilder.buildAttendanceCorrection(input);
    } else {
      throw StateError('Unsupported parent follow up type for $followUpId.');
    }

    return PreparedParentFollowUpPayload(
      followUpId: followUpId,
      attendanceStatus: attendanceStatus,
      message: message,
      channel: channel,
      recipient: normalizedRecipient,
    );
  }

  Future<ParentFollowUpRecord> confirmHandled(
    PreparedParentFollowUpPayload payload,
  ) {
    return _repository.markHandled(
      followUpId: payload.followUpId,
      snapshot: payload.toHandledSnapshot(),
    );
  }
}
