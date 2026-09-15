import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';

final class ParentFollowUpRecipientResolution {
  const ParentFollowUpRecipientResolution({
    required this.studentId,
    required this.recipient,
    required this.allowedChannels,
  });

  final int studentId;
  final String? recipient;
  final List<ParentFollowUpChannel> allowedChannels;

  bool get requiresPhoneFix => recipient == null;

  bool allows(ParentFollowUpChannel channel) {
    return allowedChannels.contains(channel);
  }

  String requireRecipient(ParentFollowUpChannel channel) {
    final value = recipient;

    if (value == null) {
      throw ParentFollowUpPhoneFixRequiredException(studentId);
    }

    if (!allows(channel)) {
      throw ParentFollowUpChannelNotAllowedException(
        studentId: studentId,
        channel: channel,
      );
    }

    return value;
  }
}

final class ParentFollowUpPhoneFixRequiredException implements Exception {
  const ParentFollowUpPhoneFixRequiredException(this.studentId);

  final int studentId;
}

final class ParentFollowUpChannelNotAllowedException implements Exception {
  const ParentFollowUpChannelNotAllowedException({
    required this.studentId,
    required this.channel,
  });

  final int studentId;
  final ParentFollowUpChannel channel;
}

final class ParentFollowUpExternalLaunch {
  const ParentFollowUpExternalLaunch({
    required this.channel,
    required this.launched,
    required this.action,
    required this.uriScheme,
    required this.recipient,
  });

  final ParentFollowUpChannel channel;
  final bool launched;
  final String action;
  final String uriScheme;
  final String recipient;
}

final class ParentFollowUpDispatchSession {
  const ParentFollowUpDispatchSession({
    required this.payload,
    required this.launch,
  });

  final PreparedParentFollowUpPayload payload;
  final ParentFollowUpExternalLaunch launch;
}
