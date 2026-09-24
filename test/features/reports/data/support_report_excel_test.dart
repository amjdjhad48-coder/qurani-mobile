import 'dart:io';

import 'package:excel_plus/excel_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/data/excel_template_mapper.dart';
import 'package:qurani/features/reports/data/verified_support_report_excel_generator.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  group('Package 8 ExcelTemplateMapper', () {
    test('weekly workbook is real RTL XLSX and round-trips report fields', () {
      const mapper = ExcelTemplateMapper();
      const verifier = SupportReportExcelVerifier();
      final snapshot = _weeklySnapshot();

      final bytes = mapper.buildWeekly(snapshot);

      expect(bytes.length, greaterThan(1000));
      expect(bytes[0], 0x50);
      expect(bytes[1], 0x4b);

      final reopened = Excel.decodeBytes(bytes);
      expect(
        reopened.tables.containsKey(ExcelTemplateMapper.sheetName),
        isTrue,
      );

      final sheet = reopened[ExcelTemplateMapper.sheetName];

      expect(sheet.isRTL, isTrue);
      expect(_textAt(sheet, 0, 0), ExcelTemplateMapper.weeklyTitle);
      expect(_textAt(sheet, 1, 1), 'المعلم أحمد');
      expect(_textAt(sheet, 1, 3), 'حلقة النور');
      expect(_textAt(sheet, 1, 5), 'جهة الخير');
      expect(_textAt(sheet, 3, 1), 'weekly-source-abc');
      expect(_textAt(sheet, 7, 0), 'رقم الطالب لدى الجهة');
      expect(_textAt(sheet, 7, 1), 'اسم الطالب');
      expect(_textAt(sheet, 7, 5), 'السبت 2026-09-12 | الحضور');
      expect(_textAt(sheet, 8, 0), '001');
      expect(_textAt(sheet, 8, 1), 'علي محمد');
      expect(_numberAt(sheet, 8, 4), 20);
      expect(_textAt(sheet, 8, 5), 'حاضر');
      expect(_textAt(sheet, 8, 6), 'البقرة 1–5؛ البقرة 6–10');
      expect(_numberAt(sheet, 8, 7), 2);
      expect(_textAt(sheet, 8, 8), 'جيد');
      expect(_textAt(sheet, 9, 1), 'سارة علي');

      final allText = sheet.rows
          .expand((row) => row)
          .whereType<Data>()
          .map((cell) => _cellText(cell.value))
          .join('|');

      expect(allText, isNot(contains('التقييم')));
      expect(allText, isNot(contains('عدد الأخطاء')));
      expect(allText, isNot(contains('معرّف التقرير')));
      expect(allText, isNot(contains('اعتمد في')));
      expect(verifier.verifyWeekly(bytes, snapshot).isValid, isTrue);
    });

    test('monthly workbook round-trips aggregate support fields', () {
      const mapper = ExcelTemplateMapper();
      const verifier = SupportReportExcelVerifier();
      final snapshot = _monthlySnapshot();

      final bytes = mapper.buildMonthly(snapshot);
      final reopened = Excel.decodeBytes(bytes);
      final sheet = reopened[ExcelTemplateMapper.sheetName];

      expect(sheet.isRTL, isTrue);
      expect(_textAt(sheet, 0, 0), ExcelTemplateMapper.monthlyTitle);
      expect(_textAt(sheet, 3, 1), 'monthly-source-xyz');
      expect(_textAt(sheet, 7, 5), 'السبت 2026-09-12 | الحضور');
      expect(_textAt(sheet, 7, 6), 'السبت 2026-09-12 | من/إلى');
      expect(_textAt(sheet, 7, 9), 'أيام الغياب');
      expect(_textAt(sheet, 7, 10), 'إتمام الهدف');
      expect(_textAt(sheet, 8, 0), '001');
      expect(_textAt(sheet, 8, 1), 'علي محمد');
      expect(_numberAt(sheet, 8, 4), 20);
      expect(_textAt(sheet, 8, 5), 'حاضر');
      expect(_textAt(sheet, 8, 6), 'البقرة 1–5');
      expect(_numberAt(sheet, 8, 7), 2);
      expect(_textAt(sheet, 8, 8), 'تفصيل شهري');
      expect(_numberAt(sheet, 8, 9), 2);
      expect(_textAt(sheet, 8, 10), 'تم');
      expect(_numberAt(sheet, 8, 11), 20);
      expect(_textAt(sheet, 8, 12), 'أتم الهدف');
      expect(_textAt(sheet, 9, 5), 'حاضر');
      expect(_textAt(sheet, 9, 10), 'لم يتم');
      expect(_numberAt(sheet, 9, 11), 10.5);

      final allText = sheet.rows
          .expand((row) => row)
          .whereType<Data>()
          .map((cell) => _cellText(cell.value))
          .join('|');
      expect(allText, isNot(contains('معرّف التقرير')));
      expect(allText, isNot(contains('اعتمد في')));

      expect(verifier.verifyMonthly(bytes, snapshot).isValid, isTrue);
    });

    test(
      'general weekly workbook removes sponsor-only columns and metadata',
      () {
        const mapper = ExcelTemplateMapper();
        const verifier = SupportReportExcelVerifier();
        final snapshot = _weeklySnapshot(general: true);

        final bytes = mapper.buildWeekly(snapshot);
        final reopened = Excel.decodeBytes(bytes);

        expect(
          reopened.tables.containsKey(ExcelTemplateMapper.generalSheetName),
          isTrue,
        );
        expect(
          reopened.tables.containsKey(ExcelTemplateMapper.sheetName),
          isFalse,
        );

        final sheet = reopened[ExcelTemplateMapper.generalSheetName];

        expect(sheet.isRTL, isTrue);
        expect(_textAt(sheet, 0, 0), ExcelTemplateMapper.generalWeeklyTitle);
        expect(_textAt(sheet, 1, 4), 'المركز/المسجد');
        expect(_textAt(sheet, 1, 5), 'مركز النور');
        expect(_textAt(sheet, 7, 0), 'اسم الطالب');
        expect(_textAt(sheet, 7, 1), 'الجزء الحالي');
        expect(_textAt(sheet, 7, 2), 'مقرر اليوم');
        expect(_textAt(sheet, 7, 3), 'السبت 2026-09-12 | الحضور');
        expect(_textAt(sheet, 8, 0), 'علي محمد');
        expect(_numberAt(sheet, 8, 1), 5);
        expect(_textAt(sheet, 8, 2), 'نصف وجه');
        expect(_textAt(sheet, 8, 3), 'حاضر');

        final allText = sheet.rows
            .expand((row) => row)
            .whereType<Data>()
            .map((cell) => _cellText(cell.value))
            .join('|');

        expect(allText, isNot(contains('رقم الطالب لدى الجهة')));
        expect(allText, isNot(contains('مقرر الشهر (وجه)')));
        expect(allText, isNot(contains('جهة الخير')));
        expect(allText, isNot(contains('001')));
        expect(verifier.verifyWeekly(bytes, snapshot).isValid, isTrue);
      },
    );

    test(
      'general monthly workbook keeps core aggregates without sponsor policy',
      () {
        const mapper = ExcelTemplateMapper();
        const verifier = SupportReportExcelVerifier();
        final snapshot = _monthlySnapshot(general: true);

        final bytes = mapper.buildMonthly(snapshot);
        final reopened = Excel.decodeBytes(bytes);
        final sheet = reopened[ExcelTemplateMapper.generalSheetName];

        expect(sheet.isRTL, isTrue);
        expect(_textAt(sheet, 0, 0), ExcelTemplateMapper.generalMonthlyTitle);
        expect(_textAt(sheet, 1, 4), 'المركز/المسجد');
        expect(_textAt(sheet, 1, 5), 'مركز النور');
        expect(_textAt(sheet, 7, 0), 'اسم الطالب');
        expect(_textAt(sheet, 7, 1), 'الجزء الحالي');
        expect(_textAt(sheet, 7, 2), 'مقرر اليوم');
        expect(_textAt(sheet, 7, 3), 'السبت 2026-09-12 | الحضور');
        expect(_textAt(sheet, 7, 7), 'أيام الغياب');
        expect(_textAt(sheet, 7, 8), 'الإنجاز (وجه)');
        expect(_textAt(sheet, 7, 9), 'الملاحظات الشهرية');
        expect(_textAt(sheet, 8, 0), 'علي محمد');
        expect(_numberAt(sheet, 8, 7), 2);
        expect(_numberAt(sheet, 8, 8), 20);
        expect(_textAt(sheet, 8, 9), 'أتم الهدف');

        final allText = sheet.rows
            .expand((row) => row)
            .whereType<Data>()
            .map((cell) => _cellText(cell.value))
            .join('|');

        expect(allText, isNot(contains('رقم الطالب لدى الجهة')));
        expect(allText, isNot(contains('مقرر الشهر (وجه)')));
        expect(allText, isNot(contains('إتمام الهدف')));
        expect(allText, isNot(contains('جهة الخير')));
        expect(allText, isNot(contains('001')));
        expect(verifier.verifyMonthly(bytes, snapshot).isValid, isTrue);
      },
    );
  });

  group('Package 8 verified Excel generator', () {
    test(
      'weekly bytes survive actual disk close/reopen and keep their hash',
      () async {
        final snapshot = _weeklySnapshot();
        const generator = VerifiedSupportReportExcelGenerator();
        const verifier = SupportReportExcelVerifier();

        final generated = await generator.generateWeekly(snapshot);

        expect(generated.kind, SupportReportArtifactKind.weekly);
        expect(generated.fileName, 'qurani_weekly_2026-09-12_2026-09-16.xlsx');
        expect(generated.sourceFingerprint, snapshot.sourceFingerprint);
        expect(generated.templateVersion, snapshot.header.templateVersion);
        expect(generated.sha256, hasLength(64));
        expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(generated.sha256), isTrue);
        expect(generated.sizeBytes, generated.bytes.length);

        final temp = await Directory.systemTemp.createTemp(
          'qurani_p8_weekly_excel_',
        );

        try {
          final file = File(
            '${temp.path}${Platform.pathSeparator}${generated.fileName}',
          );
          await file.writeAsBytes(generated.bytes, flush: true);

          final reopenedBytes = await file.readAsBytes();

          expect(
            verifier.verifyWeekly(reopenedBytes, snapshot).isValid,
            isTrue,
          );
        } finally {
          await temp.delete(recursive: true);
        }
      },
    );

    test(
      'monthly generator verifies real XLSX and exposes artifact metadata',
      () async {
        final snapshot = _monthlySnapshot();
        const generator = VerifiedSupportReportExcelGenerator();

        final generated = await generator.generateMonthly(snapshot);

        expect(generated.kind, SupportReportArtifactKind.monthly);
        expect(generated.fileName, 'qurani_monthly_2026-09.xlsx');
        expect(generated.sourceFingerprint, 'monthly-source-xyz');
        expect(generated.templateVersion, 1);
        expect(generated.sha256, hasLength(64));
        expect(generated.sizeBytes, greaterThan(1000));
      },
    );

    test(
      'verifier rejects a workbook whose source fingerprint was changed',
      () {
        final snapshot = _weeklySnapshot();
        const mapper = ExcelTemplateMapper();
        const verifier = SupportReportExcelVerifier();

        final bytes = mapper.buildWeekly(snapshot);
        final workbook = Excel.decodeBytes(bytes);
        final sheet = workbook[ExcelTemplateMapper.sheetName];

        sheet.updateCell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3),
          TextCellValue('tampered-fingerprint'),
        );

        final tampered = workbook.save();

        expect(tampered, isNotNull);

        final result = verifier.verifyWeekly(tampered!, snapshot);

        expect(result.isValid, isFalse);
        expect(result.reason, contains('B4'));
      },
    );

    test('verifier rejects unreadable bytes', () {
      const verifier = SupportReportExcelVerifier();

      final result = verifier.verifyMonthly(const <int>[
        1,
        2,
        3,
        4,
      ], _monthlySnapshot());

      expect(result.isValid, isFalse);
      expect(result.reason, contains('reopen failed'));
    });
  });
}

ApprovedWeeklySupportReportSnapshot _weeklySnapshot({bool general = false}) {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));

  return ApprovedWeeklySupportReportSnapshot(
    reportId: 71,
    halaqahId: 3,
    period: period,
    header: SupportReportHeaderSnapshot(
      reportContext: general
          ? SupportReportContext.general
          : SupportReportContext.support,
      teacherName: 'المعلم أحمد',
      halaqahName: 'حلقة النور',
      organizationName: general ? 'مركز النور' : 'جهة الخير',
      policyVersion: 1,
      templateVersion: 1,
    ),
    sourceFingerprint: 'weekly-source-abc',
    approvedAtUtc: DateTime.utc(2026, 9, 17, 10, 30),
    students: <ApprovedWeeklySupportReportStudentSnapshot>[
      ApprovedWeeklySupportReportStudentSnapshot(
        snapshotRowId: 101,
        sourceStudentId: 11,
        studentName: 'علي محمد',
        supportStudentNumber: general ? null : '001',
        currentJuz: 5,
        dailyPlanText: 'نصف وجه',
        monthlyGoalQuarterFaces: general ? null : 80,
        note: 'ملاحظة علي',
        displayOrder: 1,
      ),
      ApprovedWeeklySupportReportStudentSnapshot(
        snapshotRowId: 102,
        sourceStudentId: 12,
        studentName: 'سارة علي',
        supportStudentNumber: general ? null : '002',
        currentJuz: 6,
        monthlyGoalQuarterFaces: general ? null : 80,
        displayOrder: 2,
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
            note: 'جيد',
            entryOrder: 1,
          ),
          ApprovedWeeklySupportReportDayEntrySnapshot(
            snapshotRowId: 302,
            sourceStudentId: 11,
            attendanceStatus: null,
            achievedQuarterFaces: 3,
            range: SupportReportQuranRange(
              startSurah: 2,
              startAyah: 6,
              endSurah: 2,
              endAyah: 10,
            ),
            note: null,
            entryOrder: 2,
          ),
          ApprovedWeeklySupportReportDayEntrySnapshot(
            snapshotRowId: 303,
            sourceStudentId: 12,
            attendanceStatus: SupportReportAttendanceStatus.absent,
            achievedQuarterFaces: 0,
            range: null,
            note: 'غياب',
            entryOrder: 1,
          ),
        ],
      ),
      ApprovedWeeklySupportReportDaySnapshot(
        snapshotRowId: 202,
        localDate: DateTime(2026, 9, 13),
        dayKind: SupportReportDayKind.holiday,
        entries: const <ApprovedWeeklySupportReportDayEntrySnapshot>[],
      ),
      ApprovedWeeklySupportReportDaySnapshot(
        snapshotRowId: 203,
        localDate: DateTime(2026, 9, 14),
        dayKind: SupportReportDayKind.missing,
        entries: const <ApprovedWeeklySupportReportDayEntrySnapshot>[],
      ),
      ApprovedWeeklySupportReportDaySnapshot(
        snapshotRowId: 204,
        localDate: DateTime(2026, 9, 15),
        dayKind: SupportReportDayKind.normal,
        entries: const <ApprovedWeeklySupportReportDayEntrySnapshot>[
          ApprovedWeeklySupportReportDayEntrySnapshot(
            snapshotRowId: 304,
            sourceStudentId: 12,
            attendanceStatus: SupportReportAttendanceStatus.excusedAbsent,
            achievedQuarterFaces: 0,
            range: null,
            note: 'عذر',
            entryOrder: 1,
          ),
        ],
      ),
      ApprovedWeeklySupportReportDaySnapshot(
        snapshotRowId: 205,
        localDate: DateTime(2026, 9, 16),
        dayKind: SupportReportDayKind.notApplicable,
        entries: const <ApprovedWeeklySupportReportDayEntrySnapshot>[],
      ),
    ],
  );
}

ApprovedMonthlySupportReportSnapshot _monthlySnapshot({bool general = false}) {
  final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 1));

  return ApprovedMonthlySupportReportSnapshot(
    reportId: 81,
    halaqahId: 3,
    period: period,
    header: SupportReportHeaderSnapshot(
      reportContext: general
          ? SupportReportContext.general
          : SupportReportContext.support,
      teacherName: 'المعلم أحمد',
      halaqahName: 'حلقة النور',
      organizationName: general ? 'مركز النور' : 'جهة الخير',
      policyVersion: 1,
      templateVersion: 1,
    ),
    sourceFingerprint: 'monthly-source-xyz',
    approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
    students: <ApprovedMonthlySupportReportStudentSnapshot>[
      ApprovedMonthlySupportReportStudentSnapshot(
        snapshotRowId: 401,
        sourceStudentId: 11,
        studentName: 'علي محمد',
        supportStudentNumber: general ? null : '001',
        currentJuz: 5,
        dailyPlanText: 'نصف وجه',
        monthlyGoalQuarterFaces: general ? null : 80,
        achievedQuarterFaces: 80,
        absenceDays: 2,
        goalCompleted: general ? null : true,
        note: 'أتم الهدف',
        displayOrder: 1,
      ),
      ApprovedMonthlySupportReportStudentSnapshot(
        snapshotRowId: 402,
        sourceStudentId: 12,
        studentName: 'سارة علي',
        supportStudentNumber: general ? null : '002',
        currentJuz: 6,
        dailyPlanText: 'وجه',
        monthlyGoalQuarterFaces: general ? null : 80,
        achievedQuarterFaces: 42,
        absenceDays: 3,
        goalCompleted: general ? null : false,
        note: 'متابعة',
        displayOrder: 2,
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
              startAyah: 1,
              endSurah: 2,
              endAyah: 5,
            ),
            note: 'تفصيل شهري',
            entryOrder: 1,
          ),
          ApprovedMonthlySupportReportDayEntrySnapshot(
            snapshotRowId: 602,
            sourceStudentId: 12,
            attendanceStatus: SupportReportAttendanceStatus.present,
            achievedQuarterFaces: 4,
            range: SupportReportQuranRange(
              startSurah: 2,
              startAyah: 6,
              endSurah: 2,
              endAyah: 10,
            ),
            note: null,
            entryOrder: 1,
          ),
        ],
      ),
    ],
  );
}

String _textAt(Sheet sheet, int row, int column) {
  final value = sheet
      .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
      .value;

  return _cellText(value);
}

String _cellText(CellValue? value) {
  if (value is TextCellValue) {
    return (value.value.text ?? value.toString()).trim();
  }

  return value?.toString().trim() ?? '';
}

double? _numberAt(Sheet sheet, int row, int column) {
  final value = sheet
      .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
      .value;

  if (value is IntCellValue) {
    return value.value.toDouble();
  }

  if (value is DoubleCellValue) {
    return value.value;
  }

  return null;
}
