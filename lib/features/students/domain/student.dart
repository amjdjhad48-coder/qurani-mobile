import 'package:qurani/features/students/domain/phone_number_policy.dart';

final class CreateStudentRequest {
  const CreateStudentRequest({
    required this.halaqahId,
    required this.studentName,
    required this.fatherName,
    required this.ageYears,
    required this.guardianCountry,
    required this.guardianPhoneInput,
    required this.previousMemorizationText,
    this.note,
    this.supportStudentNumber,
  });

  final int halaqahId;
  final String studentName;
  final String fatherName;
  final int ageYears;
  final GuardianPhoneCountry guardianCountry;
  final String guardianPhoneInput;
  final String previousMemorizationText;
  final String? note;
  final String? supportStudentNumber;
}

final class EditStudentRequest {
  const EditStudentRequest({
    required this.studentId,
    required this.studentName,
    required this.fatherName,
    required this.ageYears,
    required this.guardianCountry,
    required this.guardianPhoneInput,
    required this.previousMemorizationText,
    this.note,
    this.supportStudentNumber,
  });

  final int studentId;
  final String studentName;
  final String fatherName;
  final int ageYears;
  final GuardianPhoneCountry guardianCountry;
  final String guardianPhoneInput;
  final String previousMemorizationText;
  final String? note;
  final String? supportStudentNumber;
}

final class StudentWriteData {
  const StudentWriteData({
    required this.studentName,
    required this.fatherName,
    required this.ageYears,
    required this.guardianCountryCode,
    required this.guardianNationalNumber,
    required this.previousMemorizationText,
    required this.note,
    required this.supportStudentNumber,
  });

  final String studentName;
  final String fatherName;
  final int ageYears;
  final String guardianCountryCode;
  final String guardianNationalNumber;
  final String previousMemorizationText;
  final String? note;
  final String? supportStudentNumber;
}

final class StudentRecord {
  const StudentRecord({
    required this.id,
    required this.halaqahId,
    required this.studentName,
    required this.fatherName,
    required this.ageYears,
    required this.guardianCountryCode,
    required this.guardianNationalNumber,
    required this.previousMemorizationText,
    required this.note,
    required this.supportStudentNumber,
    required this.displayOrder,
    required this.isActive,
    required this.archivedAtUtc,
  });

  final int id;
  final int halaqahId;
  final String studentName;
  final String fatherName;
  final int ageYears;
  final String guardianCountryCode;
  final String guardianNationalNumber;
  final String previousMemorizationText;
  final String? note;
  final String? supportStudentNumber;
  final int displayOrder;
  final bool isActive;
  final DateTime? archivedAtUtc;
}

final class StudentActivityPeriodRecord {
  const StudentActivityPeriodRecord({
    required this.id,
    required this.studentId,
    required this.activeFromDate,
    required this.activeToDate,
  });

  final int id;
  final int studentId;
  final String activeFromDate;
  final String? activeToDate;

  bool get isOpen => activeToDate == null;
}

final class UpdateStudentProgressPlanRequest {
  const UpdateStudentProgressPlanRequest({
    required this.studentId,
    this.currentJuz,
    this.dailyPlanText,
  });

  final int studentId;
  final int? currentJuz;
  final String? dailyPlanText;
}

final class StudentProgressPlanRecord {
  const StudentProgressPlanRecord({
    required this.studentId,
    required this.currentJuz,
    required this.dailyPlanText,
  });

  final int studentId;
  final int? currentJuz;
  final String? dailyPlanText;
}
