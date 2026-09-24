import 'package:cryptography/cryptography.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/data/excel_template_mapper.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class VerifiedSupportReportExcel {
  VerifiedSupportReportExcel({
    required this.kind,
    required this.fileName,
    required this.sourceFingerprint,
    required this.templateVersion,
    required this.sha256,
    required List<int> bytes,
  }) : bytes = List<int>.unmodifiable(bytes);

  final SupportReportArtifactKind kind;
  final String fileName;
  final String sourceFingerprint;
  final int templateVersion;
  final String sha256;
  final List<int> bytes;

  int get sizeBytes => bytes.length;
}

final class VerifiedSupportReportExcelGenerator {
  const VerifiedSupportReportExcelGenerator({
    this.mapper = const ExcelTemplateMapper(),
    this.verifier = const SupportReportExcelVerifier(),
  });

  final ExcelTemplateMapper mapper;
  final SupportReportExcelVerifier verifier;

  Future<VerifiedSupportReportExcel> generateWeekly(
    ApprovedWeeklySupportReportSnapshot snapshot,
  ) async {
    final bytes = mapper.buildWeekly(snapshot);
    final verification = verifier.verifyWeekly(bytes, snapshot);

    if (!verification.isValid) {
      throw StateError(
        'Generated weekly Excel failed reopen verification: '
        '${verification.reason}',
      );
    }

    return VerifiedSupportReportExcel(
      kind: SupportReportArtifactKind.weekly,
      fileName:
          'qurani_weekly_${_dateText(snapshot.period.weekStart)}_'
          '${_dateText(snapshot.period.weekEnd)}.xlsx',
      sourceFingerprint: snapshot.sourceFingerprint,
      templateVersion: snapshot.header.templateVersion,
      sha256: await _sha256(bytes),
      bytes: bytes,
    );
  }

  Future<VerifiedSupportReportExcel> generateMonthly(
    ApprovedMonthlySupportReportSnapshot snapshot,
  ) async {
    final bytes = mapper.buildMonthly(snapshot);
    final verification = verifier.verifyMonthly(bytes, snapshot);

    if (!verification.isValid) {
      throw StateError(
        'Generated monthly Excel failed reopen verification: '
        '${verification.reason}',
      );
    }

    return VerifiedSupportReportExcel(
      kind: SupportReportArtifactKind.monthly,
      fileName:
          'qurani_monthly_'
          '${snapshot.period.year.toString().padLeft(4, '0')}-'
          '${snapshot.period.month.toString().padLeft(2, '0')}.xlsx',
      sourceFingerprint: snapshot.sourceFingerprint,
      templateVersion: snapshot.header.templateVersion,
      sha256: await _sha256(bytes),
      bytes: bytes,
    );
  }

  Future<VerifiedSupportReportExcel> generateWeeklyCandidate({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
  }) {
    return generateWeekly(
      _weeklyCandidateSnapshot(
        halaqahId: halaqahId,
        projection: projection,
        sourceFingerprint: sourceFingerprint,
      ),
    );
  }

  Future<VerifiedSupportReportExcel> generateMonthlyCandidate({
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
  }) {
    return generateMonthly(
      _monthlyCandidateSnapshot(
        projection: projection,
        sourceFingerprint: sourceFingerprint,
      ),
    );
  }

  SupportReportExcelVerificationResult verifyWeeklyCandidateBytes({
    required List<int> bytes,
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
  }) {
    return verifier.verifyWeekly(
      bytes,
      _weeklyCandidateSnapshot(
        halaqahId: halaqahId,
        projection: projection,
        sourceFingerprint: sourceFingerprint,
      ),
    );
  }

  SupportReportExcelVerificationResult verifyMonthlyCandidateBytes({
    required List<int> bytes,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
  }) {
    return verifier.verifyMonthly(
      bytes,
      _monthlyCandidateSnapshot(
        projection: projection,
        sourceFingerprint: sourceFingerprint,
      ),
    );
  }

  Future<String> _sha256(List<int> bytes) async {
    final hash = await Sha256().hash(bytes);

    return hash.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  String _dateText(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

ApprovedWeeklySupportReportSnapshot _weeklyCandidateSnapshot({
  required int halaqahId,
  required WeeklySupportReportProjection projection,
  required String sourceFingerprint,
}) {
  if (halaqahId <= 0) {
    throw ArgumentError.value(
      halaqahId,
      'halaqahId',
      'Halaqah id must be positive.',
    );
  }

  final fingerprint = sourceFingerprint.trim();

  if (fingerprint.isEmpty) {
    throw ArgumentError.value(
      sourceFingerprint,
      'sourceFingerprint',
      'Candidate source fingerprint must not be empty.',
    );
  }

  var daySnapshotRowId = 1;
  var entrySnapshotRowId = 1;

  return ApprovedWeeklySupportReportSnapshot(
    reportId: 0,
    halaqahId: halaqahId,
    period: projection.period,
    header: projection.header,
    sourceFingerprint: fingerprint,
    approvedAtUtc: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    students: projection.students.map(
      (student) => ApprovedWeeklySupportReportStudentSnapshot(
        snapshotRowId: student.sourceStudentId,
        sourceStudentId: student.sourceStudentId,
        supportStudentNumber: student.supportStudentNumber,
        studentName: student.studentName,
        currentJuz: student.currentJuz,
        dailyPlanText: student.dailyPlanText,
        monthlyGoalQuarterFaces: student.monthlyGoalQuarterFaces,
        note: student.note,
        displayOrder: student.displayOrder,
      ),
    ),
    days: projection.days.map((day) {
      final entries = <ApprovedWeeklySupportReportDayEntrySnapshot>[];

      for (final entry in day.entries) {
        final recitations = entry.newMemorizationEntries;

        if (recitations.isEmpty) {
          entries.add(
            ApprovedWeeklySupportReportDayEntrySnapshot(
              snapshotRowId: entrySnapshotRowId++,
              sourceStudentId: entry.sourceStudentId,
              attendanceStatus: entry.attendanceStatus,
              achievedQuarterFaces: 0,
              range: null,
              note: null,
              entryOrder: 1,
            ),
          );
          continue;
        }

        for (var index = 0; index < recitations.length; index++) {
          final recitation = recitations[index];

          entries.add(
            ApprovedWeeklySupportReportDayEntrySnapshot(
              snapshotRowId: entrySnapshotRowId++,
              sourceStudentId: entry.sourceStudentId,
              attendanceStatus: index == 0 ? entry.attendanceStatus : null,
              achievedQuarterFaces: recitation.achievedQuarterFaces,
              range: recitation.range,
              note: recitation.note,
              entryOrder: index + 1,
            ),
          );
        }
      }

      return ApprovedWeeklySupportReportDaySnapshot(
        snapshotRowId: daySnapshotRowId++,
        localDate: day.localDate,
        dayKind: day.dayKind,
        entries: entries,
      );
    }),
  );
}

ApprovedMonthlySupportReportSnapshot _monthlyCandidateSnapshot({
  required MonthlySupportReportProjection projection,
  required String sourceFingerprint,
}) {
  final fingerprint = sourceFingerprint.trim();

  if (fingerprint.isEmpty) {
    throw ArgumentError.value(
      sourceFingerprint,
      'sourceFingerprint',
      'Candidate source fingerprint must not be empty.',
    );
  }

  var daySnapshotRowId = 1;
  var entrySnapshotRowId = 1;

  return ApprovedMonthlySupportReportSnapshot(
    reportId: 0,
    halaqahId: projection.halaqahId,
    period: projection.period,
    header: projection.header,
    sourceFingerprint: fingerprint,
    approvedAtUtc: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    students: projection.students.map(
      (student) => ApprovedMonthlySupportReportStudentSnapshot(
        snapshotRowId: student.sourceStudentId,
        sourceStudentId: student.sourceStudentId,
        supportStudentNumber: student.supportStudentNumber,
        studentName: student.studentName,
        currentJuz: student.currentJuz,
        dailyPlanText: student.dailyPlanText,
        monthlyGoalQuarterFaces: student.monthlyGoalQuarterFaces,
        achievedQuarterFaces: student.achievedQuarterFaces,
        absenceDays: student.absenceDays,
        goalCompleted: student.goalCompleted,
        note: student.note,
        displayOrder: student.displayOrder,
      ),
    ),
    days: projection.days.map(
      (day) => ApprovedMonthlySupportReportDaySnapshot(
        snapshotRowId: daySnapshotRowId++,
        sourceWeeklyReportId: day.sourceWeeklyReportId,
        localDate: day.localDate,
        dayKind: day.dayKind,
        entries: day.entries.map(
          (entry) => ApprovedMonthlySupportReportDayEntrySnapshot(
            snapshotRowId: entrySnapshotRowId++,
            sourceStudentId: entry.sourceStudentId,
            attendanceStatus: entry.attendanceStatus,
            achievedQuarterFaces: entry.achievedQuarterFaces,
            range: entry.range,
            note: entry.note,
            entryOrder: entry.entryOrder,
          ),
        ),
      ),
    ),
  );
}
