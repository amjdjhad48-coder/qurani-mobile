import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_dispatch.dart';

abstract interface class ParentFollowUpExternalGateway {
  Future<ParentFollowUpExternalLaunch> open(
    PreparedParentFollowUpPayload payload,
  );
}
