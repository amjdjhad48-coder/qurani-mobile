import 'package:qurani/core/security/pin_policy.dart';

final class InitialSetupRequest {
  const InitialSetupRequest({
    required this.teacherName,
    required this.halaqahName,
    required this.centerName,
    required this.hasSupportOrganization,
    required this.supportOrganizationName,
    required this.pin,
  });

  final String teacherName;
  final String halaqahName;
  final String centerName;
  final bool hasSupportOrganization;
  final String? supportOrganizationName;
  final String pin;

  String get normalizedTeacherName => teacherName.trim();

  String get normalizedHalaqahName => halaqahName.trim();

  String get normalizedCenterName => centerName.trim();

  String? get normalizedSupportOrganizationName {
    final value = supportOrganizationName?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String get supportStatus =>
      hasSupportOrganization ? 'pending_activation' : 'disabled';

  void validate() {
    if (normalizedTeacherName.isEmpty) {
      throw ArgumentError.value(
        teacherName,
        'teacherName',
        'Teacher name is required.',
      );
    }

    if (normalizedHalaqahName.isEmpty) {
      throw ArgumentError.value(
        halaqahName,
        'halaqahName',
        'Halaqah name is required.',
      );
    }

    if (normalizedCenterName.isEmpty) {
      throw ArgumentError.value(
        centerName,
        'centerName',
        'Center name is required.',
      );
    }

    final organizationName = normalizedSupportOrganizationName;

    if (hasSupportOrganization && organizationName == null) {
      throw ArgumentError.value(
        supportOrganizationName,
        'supportOrganizationName',
        'Support organization name is required when support is selected.',
      );
    }

    if (!hasSupportOrganization && organizationName != null) {
      throw ArgumentError.value(
        supportOrganizationName,
        'supportOrganizationName',
        'Support organization name must be absent when support is disabled.',
      );
    }

    if (!PinPolicy.isValid(pin)) {
      throw ArgumentError.value(
        pin,
        'pin',
        'PIN must satisfy the approved six-digit PIN policy.',
      );
    }
  }
}
