import 'package:qurani/features/parent_follow_up/application/parent_follow_up_recipient_policy.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_service.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_dispatch.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_external_gateway.dart';
import 'package:qurani/features/students/domain/student.dart';

final class ParentFollowUpDispatchService {
  const ParentFollowUpDispatchService({
    required ParentFollowUpService parentFollowUpService,
    required ParentFollowUpRecipientPolicy recipientPolicy,
    required ParentFollowUpExternalGateway externalGateway,
  }) : this._(parentFollowUpService, recipientPolicy, externalGateway);

  const ParentFollowUpDispatchService._(
    this._parentFollowUpService,
    this._recipientPolicy,
    this._externalGateway,
  );

  final ParentFollowUpService _parentFollowUpService;
  final ParentFollowUpRecipientPolicy _recipientPolicy;
  final ParentFollowUpExternalGateway _externalGateway;

  Future<ParentFollowUpDispatchSession> open({
    required int followUpId,
    required StudentRecord student,
    required ParentFollowUpChannel channel,
  }) async {
    final followUp = await _parentFollowUpService.requiredFollowUp(followUpId);

    if (followUp.studentId != student.id) {
      throw StateError(
        'Parent follow up $followUpId belongs to student '
        '${followUp.studentId}, not ${student.id}.',
      );
    }

    if (!followUp.isPending) {
      throw StateError('Only a pending parent follow up can be sent.');
    }

    final recipientResolution = _recipientPolicy.resolve(
      studentId: student.id,
      countryCode: student.guardianCountryCode,
      nationalNumber: student.guardianNationalNumber,
    );

    final recipient = recipientResolution.requireRecipient(channel);

    final payload = await _parentFollowUpService.preparePayload(
      followUpId: followUpId,
      channel: channel,
      recipient: recipient,
    );

    final launch = await _externalGateway.open(payload);

    if (!launch.launched) {
      throw StateError('External messaging application was not launched.');
    }

    if (launch.channel != payload.channel ||
        launch.recipient != payload.recipient) {
      throw StateError(
        'External launch does not match '
        'the prepared parent follow up payload.',
      );
    }

    return ParentFollowUpDispatchSession(payload: payload, launch: launch);
  }

  Future<ParentFollowUpRecord> confirmReturn({
    required ParentFollowUpDispatchSession session,
    required bool didSend,
  }) async {
    if (!didSend) {
      return _parentFollowUpService.requiredFollowUp(
        session.payload.followUpId,
      );
    }

    return _parentFollowUpService.confirmHandled(session.payload);
  }
}
