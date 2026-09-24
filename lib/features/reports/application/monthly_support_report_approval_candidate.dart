import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';

final class MonthlySupportReportApprovalCandidate {
  MonthlySupportReportApprovalCandidate({
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

    if (projection.weeklyInputs.isEmpty) {
      throw StateError(
        'Monthly approval requires approved weekly snapshot inputs.',
      );
    }

    final weeklyReportIds = <int>{};

    for (final input in projection.weeklyInputs) {
      if (!weeklyReportIds.add(input.reportId)) {
        throw StateError(
          'Monthly approval contains duplicate weekly snapshot inputs.',
        );
      }

      if (input.sourceFingerprint.trim().isEmpty) {
        throw StateError(
          'Monthly approval contains a weekly input without fingerprint.',
        );
      }
    }

    for (final day in projection.days) {
      if (!weeklyReportIds.contains(day.sourceWeeklyReportId)) {
        throw StateError(
          'Monthly day does not reference an approved weekly input.',
        );
      }
    }
  }

  final MonthlySupportReportProjection projection;
  final String sourceFingerprint;

  /// True only after explicit confirmation when transient warnings exist.
  final bool warningsConfirmed;

  bool get hasWarnings => projection.missingItems.isNotEmpty;

  bool get warningsAccepted => !hasWarnings || warningsConfirmed;

  PrimaryReportArtifactRequest get artifactRequest {
    return PrimaryReportArtifactRequest(
      kind: SupportReportArtifactKind.monthly,
      sourceFingerprint: sourceFingerprint,
      policyVersion: projection.header.policyVersion,
      templateVersion: projection.header.templateVersion,
    );
  }
}

final class MonthlySupportReportApprovalDecision {
  const MonthlySupportReportApprovalDecision({
    required this.candidate,
    required this.artifactGateResult,
  });

  final MonthlySupportReportApprovalCandidate candidate;
  final PrimaryReportArtifactGateResult artifactGateResult;

  bool get canCommitApproval =>
      candidate.warningsAccepted && artifactGateResult.isSatisfied;
}

final class MonthlySupportReportApprovalCandidateService {
  const MonthlySupportReportApprovalCandidateService({
    this.fingerprint = const MonthlySupportReportSourceFingerprint(),
  });

  final MonthlySupportReportSourceFingerprint fingerprint;

  Future<MonthlySupportReportApprovalCandidate> buildCandidate({
    required MonthlySupportReportProjection projection,
    bool warningsConfirmed = false,
  }) async {
    final sourceFingerprint = await fingerprint.forMonthlyProjection(
      projection,
    );

    return MonthlySupportReportApprovalCandidate(
      projection: projection,
      sourceFingerprint: sourceFingerprint,
      warningsConfirmed: warningsConfirmed,
    );
  }

  Future<MonthlySupportReportApprovalDecision> evaluateForApproval({
    required MonthlySupportReportApprovalCandidate candidate,
    required PrimaryReportArtifactGate artifactGate,
  }) async {
    final artifactResult = await artifactGate.verify(candidate.artifactRequest);

    return MonthlySupportReportApprovalDecision(
      candidate: candidate,
      artifactGateResult: artifactResult,
    );
  }
}

final class MonthlySupportReportSourceFingerprint {
  const MonthlySupportReportSourceFingerprint();

  Future<String> forMonthlyProjection(
    MonthlySupportReportProjection projection,
  ) async {
    final students = projection.students.toList()
      ..sort((left, right) {
        final orderCompare = left.displayOrder.compareTo(right.displayOrder);

        if (orderCompare != 0) {
          return orderCompare;
        }

        return left.sourceStudentId.compareTo(right.sourceStudentId);
      });

    final days = projection.days.toList()
      ..sort((left, right) {
        final dateCompare = left.localDate.compareTo(right.localDate);

        if (dateCompare != 0) {
          return dateCompare;
        }

        return left.sourceWeeklyReportId.compareTo(right.sourceWeeklyReportId);
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
      'kind': 'monthly',
      'halaqahId': projection.halaqahId,
      'monthStart': _dateText(projection.period.monthStart),
      'monthEnd': _dateText(projection.period.monthEnd),
      'header': <String, Object?>{
        'teacherName': projection.header.teacherName,
        'halaqahName': projection.header.halaqahName,
        'organizationName': projection.header.organizationName,
        'reportContext': projection.header.reportContext.storageValue,
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
              'monthlyGoalQuarterFaces': student.monthlyGoalQuarterFaces,
              'achievedQuarterFaces': student.achievedQuarterFaces,
              'absenceDays': student.absenceDays,
              'goalCompleted': student.goalCompleted,
              'note': student.note,
              'displayOrder': student.displayOrder,
            },
          )
          .toList(growable: false),
      'days': days
          .map((day) {
            final entries = day.entries.toList()
              ..sort((left, right) {
                final studentCompare = left.sourceStudentId.compareTo(
                  right.sourceStudentId,
                );

                if (studentCompare != 0) {
                  return studentCompare;
                }

                return left.entryOrder.compareTo(right.entryOrder);
              });

            return <String, Object?>{
              'localDate': _dateText(day.localDate),
              'dayKind': day.dayKind.storageValue,
              'entries': entries
                  .map(
                    (entry) => <String, Object?>{
                      'sourceStudentId': entry.sourceStudentId,
                      'attendanceStatus': entry.attendanceStatus?.storageValue,
                      'achievedQuarterFaces': entry.achievedQuarterFaces,
                      'range': entry.range == null
                          ? null
                          : <String, Object?>{
                              'startSurah': entry.range!.startSurah,
                              'startAyah': entry.range!.startAyah,
                              'endSurah': entry.range!.endSurah,
                              'endAyah': entry.range!.endAyah,
                            },
                      'note': entry.note,
                      'entryOrder': entry.entryOrder,
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
