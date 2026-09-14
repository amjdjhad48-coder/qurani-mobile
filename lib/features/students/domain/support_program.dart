final class SupportProgramState {
  const SupportProgramState({
    required this.halaqahId,
    required this.status,
    required this.organizationName,
  });

  final int halaqahId;
  final String status;
  final String? organizationName;

  bool get isDisabled => status == 'disabled';

  bool get isPendingActivation => status == 'pending_activation';

  bool get isEnabled => status == 'enabled';
}

final class StudentSupportGap {
  const StudentSupportGap({required this.studentId, required this.studentName});

  final int studentId;
  final String studentName;
}

final class SupportActivationCheck {
  const SupportActivationCheck({
    required this.state,
    required this.missingStudentNumbers,
  });

  final SupportProgramState state;
  final List<StudentSupportGap> missingStudentNumbers;

  bool get canActivate =>
      state.isPendingActivation && missingStudentNumbers.isEmpty;
}
