import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class WeeklySupportReportApprovalCandidate {
  WeeklySupportReportApprovalCandidate({
    required this.projection,
    required this.sourceFingerprint,
    required this.warningsConfirmed,
  }) {
    if (sourceFingerprint.trim().isEmpty) {
      throw ArgumentError.value(
        sourceFingerprint,
        'sourceFingerprint',
        'Source fingerprint must not be empty.',
      );
    }
  }

  final WeeklySupportReportProjection projection;
  final String sourceFingerprint;

  /// True only after an explicit user confirmation when warnings exist.
  final bool warningsConfirmed;

  bool get hasWarnings => projection.missingItems.isNotEmpty;

  bool get warningsAccepted => !hasWarnings || warningsConfirmed;

  PrimaryReportArtifactRequest get artifactRequest {
    return PrimaryReportArtifactRequest(
      kind: SupportReportArtifactKind.weekly,
      sourceFingerprint: sourceFingerprint,
      policyVersion: projection.header.policyVersion,
      templateVersion: projection.header.templateVersion,
    );
  }
}

final class WeeklySupportReportApprovalDecision {
  const WeeklySupportReportApprovalDecision({
    required this.candidate,
    required this.artifactGateResult,
  });

  final WeeklySupportReportApprovalCandidate candidate;
  final PrimaryReportArtifactGateResult artifactGateResult;

  bool get canCommitApproval =>
      candidate.warningsAccepted && artifactGateResult.isSatisfied;
}

final class WeeklySupportReportApprovalCandidateService {
  const WeeklySupportReportApprovalCandidateService({
    this.fingerprint = const SupportReportSourceFingerprint(),
  });

  final SupportReportSourceFingerprint fingerprint;

  Future<WeeklySupportReportApprovalCandidate> buildCandidate({
    required WeeklySupportReportProjection projection,
    bool warningsConfirmed = false,
  }) async {
    final sourceFingerprint = await fingerprint.forWeeklyProjection(projection);

    return WeeklySupportReportApprovalCandidate(
      projection: projection,
      sourceFingerprint: sourceFingerprint,
      warningsConfirmed: warningsConfirmed,
    );
  }

  Future<WeeklySupportReportApprovalDecision> evaluateForApproval({
    required WeeklySupportReportApprovalCandidate candidate,
    required PrimaryReportArtifactGate artifactGate,
  }) async {
    final artifactResult = await artifactGate.verify(candidate.artifactRequest);

    return WeeklySupportReportApprovalDecision(
      candidate: candidate,
      artifactGateResult: artifactResult,
    );
  }
}

final class SupportReportSourceFingerprint {
  const SupportReportSourceFingerprint();

  Future<String> forWeeklyProjection(
    WeeklySupportReportProjection projection,
  ) async {
    final students = projection.students.toList()
      ..sort((left, right) {
        final orderCompare = left.displayOrder.compareTo(right.displayOrder);

        if (orderCompare != 0) {
          return orderCompare;
        }

        return left.sourceStudentId.compareTo(right.sourceStudentId);
      });

    final missingItems = projection.missingItems.toList()
      ..sort((left, right) {
        final studentCompare = left.studentId.compareTo(right.studentId);

        if (studentCompare != 0) {
          return studentCompare;
        }

        final fieldCompare = left.field.name.compareTo(right.field.name);

        if (fieldCompare != 0) {
          return fieldCompare;
        }

        return _dateTextNullable(
          left.localDate,
        ).compareTo(_dateTextNullable(right.localDate));
      });

    final canonical = <String, Object?>{
      'kind': 'weekly',
      'weekStart': _dateText(projection.period.weekStart),
      'weekEnd': _dateText(projection.period.weekEnd),
      'header': <String, Object?>{
        'teacherName': projection.header.teacherName,
        'halaqahName': projection.header.halaqahName,
        'organizationName': projection.header.organizationName,
        'policyVersion': projection.header.policyVersion,
        'templateVersion': projection.header.templateVersion,
      },
      'students': students
          .map(
            (student) => <String, Object?>{
              'sourceStudentId': student.sourceStudentId,
              'supportStudentNumber': student.supportStudentNumber,
              'studentName': student.studentName,
              'currentJuz': student.currentJuz,
              'dailyPlanText': student.dailyPlanText,
              'note': student.note,
              'monthlyGoalQuarterFaces': student.monthlyGoalQuarterFaces,
              'displayOrder': student.displayOrder,
            },
          )
          .toList(growable: false),
      'days': projection.days
          .map((day) {
            final entries = day.entries.toList()
              ..sort(
                (left, right) =>
                    left.sourceStudentId.compareTo(right.sourceStudentId),
              );

            return <String, Object?>{
              'localDate': _dateText(day.localDate),
              'dayKind': day.dayKind.storageValue,
              'entries': entries
                  .map(
                    (entry) => <String, Object?>{
                      'sourceStudentId': entry.sourceStudentId,
                      'attendanceStatus': entry.attendanceStatus?.storageValue,
                      'newMemorizationEntries': entry.newMemorizationEntries
                          .map(
                            (recitation) => <String, Object?>{
                              'achievedQuarterFaces':
                                  recitation.achievedQuarterFaces,
                              'startSurah': recitation.range.startSurah,
                              'startAyah': recitation.range.startAyah,
                              'endSurah': recitation.range.endSurah,
                              'endAyah': recitation.range.endAyah,
                              'note': recitation.note,
                            },
                          )
                          .toList(growable: false),
                    },
                  )
                  .toList(growable: false),
            };
          })
          .toList(growable: false),
      'missingItems': missingItems
          .map(
            (item) => <String, Object?>{
              'studentId': item.studentId,
              'studentName': item.studentName,
              'field': item.field.name,
              'localDate': item.localDate == null
                  ? null
                  : _dateText(item.localDate!),
            },
          )
          .toList(growable: false),
    };

    final encoded = utf8.encode(jsonEncode(canonical));

    final hash = await Sha256().hash(encoded);

    return hash.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

String _dateText(DateTime value) {
  final normalized = SupportReportPolicy.dateOnly(value);

  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}

String _dateTextNullable(DateTime? value) {
  return value == null ? '' : _dateText(value);
}
