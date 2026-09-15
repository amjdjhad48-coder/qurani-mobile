import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_repository.dart';

final class EndDayAndPrepareParentFollowUps {
  const EndDayAndPrepareParentFollowUps({
    required ParentFollowUpRepository repository,
  }) : this._(repository);

  const EndDayAndPrepareParentFollowUps._(this._repository);

  final ParentFollowUpRepository _repository;

  Future<EndDayAndPrepareParentFollowUpsResult> call({
    required int halaqahId,
    required int dayId,
  }) {
    return _repository.endDayAndPrepareDailyFollowUps(
      halaqahId: halaqahId,
      dayId: dayId,
    );
  }
}
