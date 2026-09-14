import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/domain/support_program.dart';
import 'package:qurani/features/students/domain/support_program_repository.dart';

final class SupportProgramService {
  const SupportProgramService(this._repository, this._clock);

  final SupportProgramRepository _repository;
  final Clock _clock;

  Future<SupportProgramState> getState(int halaqahId) {
    return _repository.getState(halaqahId);
  }

  Future<SupportProgramState> beginActivation({
    required int halaqahId,
    required String organizationName,
  }) {
    final normalizedOrganizationName = organizationName.trim();

    if (normalizedOrganizationName.isEmpty) {
      throw ArgumentError.value(
        organizationName,
        'organizationName',
        'Support organization name must not be empty.',
      );
    }

    return _repository.beginActivation(
      halaqahId: halaqahId,
      organizationName: normalizedOrganizationName,
      updatedAtUtc: _clock.nowUtc(),
    );
  }

  Future<SupportActivationCheck> checkActivation(int halaqahId) {
    return _repository.checkActivation(halaqahId);
  }

  Future<SupportProgramState> activate({
    required int halaqahId,
    required bool confirmed,
  }) async {
    if (!confirmed) {
      throw ArgumentError(
        'Explicit support activation confirmation is required.',
      );
    }

    return _repository.activate(
      halaqahId: halaqahId,
      activatedAtUtc: _clock.nowUtc(),
    );
  }

  Future<SupportProgramState> disable(int halaqahId) {
    return _repository.disable(
      halaqahId: halaqahId,
      disabledAtUtc: _clock.nowUtc(),
    );
  }
}
