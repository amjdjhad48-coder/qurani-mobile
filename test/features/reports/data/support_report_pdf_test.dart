import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/data/verified_support_report_pdf_generator.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Package 8 verified PDF generation', () {
    test(
      'weekly support PDF comes from approved snapshot and reopens from disk',
      () async {
        const mapper = SupportReportPdfContentMapper();
        const generator = VerifiedSupportReportPdfGenerator();
        final snapshot = _weeklySnapshot(SupportReportContext.support);

        final model = mapper.buildWeekly(snapshot);
        expect(model.title, 'تقرير الجهة الأسبوعي');
        expect(model.sourceFingerprint, snapshot.sourceFingerprint);
        expect(
          _labels(model.students.single.fields),
          contains('رقم الطالب لدى الجهة'),
        );
        expect(
          model.students.single.dayLines.single,
          allOf(contains('حاضر'), contains('البقرة'), contains('1.25')),
        );

        final generated = await generator.generateWeekly(snapshot);

        expect(generated.kind, SupportReportArtifactKind.weekly);
        expect(generated.fileName, 'qurani_weekly_2026-09-12_2026-09-16.pdf');
        expect(generated.sourceFingerprint, snapshot.sourceFingerprint);
        expect(generated.templateVersion, snapshot.header.templateVersion);
        expect(generated.bytes.length, greaterThan(5000));
        expect(ascii.decode(generated.bytes.sublist(0, 5)), '%PDF-');
        expect(
          ascii
              .decode(
                generated.bytes.sublist(
                  generated.bytes.length > 1024
                      ? generated.bytes.length - 1024
                      : 0,
                ),
                allowInvalid: true,
              )
              .contains('%%EOF'),
          isTrue,
        );
        expect(await _sha256(generated.bytes), generated.sha256);

        await _expectDiskPdfReopen(generated.bytes, 'weekly');
      },
    );

    test('weekly general semantic model excludes sponsor-only fields', () {
      const mapper = SupportReportPdfContentMapper();
      final model = mapper.buildWeekly(
        _weeklySnapshot(SupportReportContext.general),
      );
      final labels = _labels(model.students.single.fields);

      expect(model.title, 'تقرير قرآني الأسبوعي');
      expect(
        model.metadata.any((field) => field.label == 'المركز/المسجد'),
        isTrue,
      );
      expect(labels, isNot(contains('رقم الطالب لدى الجهة')));
      expect(labels, isNot(contains('مقرر الشهر (وجه)')));
    });

    test(
      'monthly general PDF comes from approved snapshot and reopens from disk',
      () async {
        const mapper = SupportReportPdfContentMapper();
        const generator = VerifiedSupportReportPdfGenerator();
        final snapshot = _monthlySnapshot(SupportReportContext.general);

        final model = mapper.buildMonthly(snapshot);
        final fields = _labels(model.students.single.fields);
        final aggregates = _labels(model.students.single.aggregates);

        expect(model.title, 'تقرير قرآني الشهري');
        expect(model.sourceFingerprint, snapshot.sourceFingerprint);
        expect(fields, isNot(contains('رقم الطالب لدى الجهة')));
        expect(fields, isNot(contains('مقرر الشهر (وجه)')));
        expect(aggregates, isNot(contains('إتمام الهدف')));
        expect(aggregates, contains('أيام الغياب'));
        expect(aggregates, contains('الإنجاز (وجه)'));

        final generated = await generator.generateMonthly(snapshot);

        expect(generated.kind, SupportReportArtifactKind.monthly);
        expect(generated.fileName, 'qurani_monthly_2026-09.pdf');
        expect(generated.sourceFingerprint, snapshot.sourceFingerprint);
        expect(generated.templateVersion, snapshot.header.templateVersion);
        expect(generated.bytes.length, greaterThan(5000));
        expect(await _sha256(generated.bytes), generated.sha256);

        await _expectDiskPdfReopen(generated.bytes, 'monthly');
      },
    );

    test('monthly support semantic model keeps support overlay fields', () {
      const mapper = SupportReportPdfContentMapper();
      final model = mapper.buildMonthly(
        _monthlySnapshot(SupportReportContext.support),
      );
      final fields = _labels(model.students.single.fields);
      final aggregates = _labels(model.students.single.aggregates);

      expect(model.title, 'تقرير الجهة الشهري');
      expect(fields, contains('رقم الطالب لدى الجهة'));
      expect(fields, contains('مقرر الشهر (وجه)'));
      expect(aggregates, contains('إتمام الهدف'));
    });

    test('PDF verifier rejects non-PDF and missing EOF bytes', () {
      const verifier = SupportReportPdfVerifier();

      expect(verifier.verifyStructure(const <int>[1, 2, 3]).isValid, isFalse);

      final noEof = utf8.encode('%PDF-1.7 fake body without trailer');
      final result = verifier.verifyStructure(noEof);

      expect(result.isValid, isFalse);
      expect(result.reason, contains('EOF'));
    });
  });
}

Set<String> _labels(List<SupportReportPdfField> fields) {
  return fields.map((field) => field.label).toSet();
}

ApprovedWeeklySupportReportSnapshot _weeklySnapshot(
  SupportReportContext context,
) {
  final support = context == SupportReportContext.support;
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));

  return ApprovedWeeklySupportReportSnapshot(
    reportId: 71,
    halaqahId: 3,
    period: period,
    header: SupportReportHeaderSnapshot(
      teacherName: 'المعلم أحمد',
      halaqahName: 'حلقة الفجر',
      organizationName: support ? 'الجهة الداعمة' : 'مسجد النور',
      reportContext: context,
      policyVersion: 1,
      templateVersion: 1,
    ),
    sourceFingerprint: support
        ? 'weekly-support-approved-fingerprint'
        : 'weekly-general-approved-fingerprint',
    approvedAtUtc: DateTime.utc(2026, 9, 17, 10, 30),
    students: <ApprovedWeeklySupportReportStudentSnapshot>[
      ApprovedWeeklySupportReportStudentSnapshot(
        snapshotRowId: 101,
        sourceStudentId: 11,
        studentName: 'علي محمد',
        supportStudentNumber: support ? '001' : null,
        currentJuz: 5,
        dailyPlanText: 'نصف وجه',
        monthlyGoalQuarterFaces: support ? 80 : null,
        note: 'ملاحظة الطالب',
        displayOrder: 1,
      ),
    ],
    days: <ApprovedWeeklySupportReportDaySnapshot>[
      ApprovedWeeklySupportReportDaySnapshot(
        snapshotRowId: 201,
        localDate: DateTime(2026, 9, 12),
        dayKind: SupportReportDayKind.normal,
        entries: const <ApprovedWeeklySupportReportDayEntrySnapshot>[
          ApprovedWeeklySupportReportDayEntrySnapshot(
            snapshotRowId: 301,
            sourceStudentId: 11,
            attendanceStatus: SupportReportAttendanceStatus.present,
            achievedQuarterFaces: 5,
            range: SupportReportQuranRange(
              startSurah: 2,
              startAyah: 1,
              endSurah: 2,
              endAyah: 5,
            ),
            note: 'متقن',
            entryOrder: 1,
          ),
        ],
      ),
    ],
  );
}

ApprovedMonthlySupportReportSnapshot _monthlySnapshot(
  SupportReportContext context,
) {
  final support = context == SupportReportContext.support;
  final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));

  return ApprovedMonthlySupportReportSnapshot(
    reportId: 81,
    halaqahId: 3,
    period: period,
    header: SupportReportHeaderSnapshot(
      teacherName: 'المعلم أحمد',
      halaqahName: 'حلقة الفجر',
      organizationName: support ? 'الجهة الداعمة' : 'مسجد النور',
      reportContext: context,
      policyVersion: 1,
      templateVersion: 1,
    ),
    sourceFingerprint: support
        ? 'monthly-support-approved-fingerprint'
        : 'monthly-general-approved-fingerprint',
    approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
    students: <ApprovedMonthlySupportReportStudentSnapshot>[
      ApprovedMonthlySupportReportStudentSnapshot(
        snapshotRowId: 401,
        sourceStudentId: 11,
        studentName: 'علي محمد',
        supportStudentNumber: support ? '001' : null,
        currentJuz: 5,
        dailyPlanText: 'نصف وجه',
        monthlyGoalQuarterFaces: support ? 80 : null,
        achievedQuarterFaces: 42,
        absenceDays: 2,
        goalCompleted: support ? false : null,
        note: 'متابعة شهرية',
        displayOrder: 1,
      ),
    ],
    days: <ApprovedMonthlySupportReportDaySnapshot>[
      ApprovedMonthlySupportReportDaySnapshot(
        snapshotRowId: 501,
        sourceWeeklyReportId: 61,
        localDate: DateTime(2026, 9, 12),
        dayKind: SupportReportDayKind.normal,
        entries: const <ApprovedMonthlySupportReportDayEntrySnapshot>[
          ApprovedMonthlySupportReportDayEntrySnapshot(
            snapshotRowId: 601,
            sourceStudentId: 11,
            attendanceStatus: SupportReportAttendanceStatus.present,
            achievedQuarterFaces: 8,
            range: SupportReportQuranRange(
              startSurah: 2,
              startAyah: 6,
              endSurah: 2,
              endAyah: 10,
            ),
            note: 'جيد',
            entryOrder: 1,
          ),
        ],
      ),
    ],
  );
}

Future<String> _sha256(List<int> bytes) async {
  final hash = await Sha256().hash(bytes);
  return hash.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}

Future<void> _expectDiskPdfReopen(List<int> bytes, String label) async {
  final root = await Directory.systemTemp.createTemp('qurani_p8_pdf_${label}_');

  try {
    final file = File(
      '${root.path}${Platform.pathSeparator}approved_report.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);

    expect(await file.exists(), isTrue);
    expect(await file.length(), bytes.length);

    final reopenedBytes = await file.readAsBytes();
    expect(reopenedBytes, orderedEquals(bytes));

    final parsed = await PDFParser(ByteStream(reopenedBytes)).parse();
    final catalog = await parsed.catalog;
    final pages = await catalog.getPages();

    expect(pages.pageCount, greaterThanOrEqualTo(1));
    expect(pages.getPageAtIndex(0).runtimeType.toString(), isNotEmpty);
  } finally {
    await root.delete(recursive: true);
  }
}
