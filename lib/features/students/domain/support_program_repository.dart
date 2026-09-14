import 'package:qurani/features/students/domain/support_program.dart';

abstract interface class SupportProgramRepository {
  Future<SupportProgramState> getState(int halaqahId);

  Future<SupportActivationCheck> checkActivation(int halaqahId);

  Future<SupportProgramState> beginActivation({
    required int halaqahId,
    required String organizationName,
    required DateTime updatedAtUtc,
  });

  Future<SupportProgramState> activate({
    required int halaqahId,
    required DateTime activatedAtUtc,
  });

  Future<SupportProgramState> disable({
    required int halaqahId,
    required DateTime disabledAtUtc,
  });
}
