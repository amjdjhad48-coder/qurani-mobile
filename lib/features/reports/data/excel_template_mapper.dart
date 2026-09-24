import 'package:excel_plus/excel_plus.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class SupportReportExcelVerificationResult {
  const SupportReportExcelVerificationResult.valid()
    : isValid = true,
      reason = null;

  const SupportReportExcelVerificationResult.invalid(this.reason)
    : isValid = false;

  final bool isValid;
  final String? reason;
}

final class ExcelTemplateMapper {
  const ExcelTemplateMapper();

  static const String sheetName = 'تقرير الجهة';
  static const String weeklyTitle = 'تقرير الجهة الأسبوعي';
  static const String monthlyTitle = 'تقرير الجهة الشهري';

  static const String generalSheetName = 'تقرير قرآني';
  static const String generalWeeklyTitle = 'تقرير قرآني الأسبوعي';
  static const String generalMonthlyTitle = 'تقرير قرآني الشهري';

  static const int _headerRow = 7;
  static const int _firstStudentRow = 8;
  static const int _weeklyDayColumns = 4;
  static const int _monthlyDayColumns = 4;

  static const List<String> _supportBaseHeaders = <String>[
    'رقم الطالب لدى الجهة',
    'اسم الطالب',
    'الجزء الحالي',
    'مقرر اليوم',
    'مقرر الشهر (وجه)',
  ];

  static const List<String> _generalBaseHeaders = <String>[
    'اسم الطالب',
    'الجزء الحالي',
    'مقرر اليوم',
  ];

  static const List<String> _supportMonthlyAggregateHeaders = <String>[
    'أيام الغياب',
    'إتمام الهدف',
    'الإنجاز (وجه)',
    'الملاحظات الشهرية',
  ];

  static const List<String> _generalMonthlyAggregateHeaders = <String>[
    'أيام الغياب',
    'الإنجاز (وجه)',
    'الملاحظات الشهرية',
  ];

  String _sheetNameFor(SupportReportContext context) {
    return context == SupportReportContext.general
        ? generalSheetName
        : sheetName;
  }

  String _weeklyTitleFor(SupportReportContext context) {
    return context == SupportReportContext.general
        ? generalWeeklyTitle
        : weeklyTitle;
  }

  String _monthlyTitleFor(SupportReportContext context) {
    return context == SupportReportContext.general
        ? generalMonthlyTitle
        : monthlyTitle;
  }

  List<String> _baseHeadersFor(SupportReportContext context) {
    return context == SupportReportContext.general
        ? _generalBaseHeaders
        : _supportBaseHeaders;
  }

  List<String> _monthlyAggregateHeadersFor(SupportReportContext context) {
    return context == SupportReportContext.general
        ? _generalMonthlyAggregateHeaders
        : _supportMonthlyAggregateHeaders;
  }

  String _organizationLabelFor(SupportReportContext context) {
    return context == SupportReportContext.general ? 'المركز/المسجد' : 'الجهة';
  }

  List<int> buildWeekly(ApprovedWeeklySupportReportSnapshot snapshot) {
    final context = snapshot.header.reportContext;
    final targetSheetName = _sheetNameFor(context);
    final baseHeaders = _baseHeadersFor(context);
    final baseColumns = baseHeaders.length;

    final excel = Excel.createExcel();
    excel.rename('Sheet1', targetSheetName);
    final sheet = excel[targetSheetName];

    sheet.isRTL = true;

    final columnCount =
        baseColumns + (snapshot.days.length * _weeklyDayColumns);

    _writeTitle(
      sheet,
      title: _weeklyTitleFor(context),
      lastColumn: columnCount - 1,
    );
    _writeMetadata(
      sheet,
      header: snapshot.header,
      periodText:
          '${_dateText(snapshot.period.weekStart)} إلى '
          '${_dateText(snapshot.period.weekEnd)}',
      sourceFingerprint: snapshot.sourceFingerprint,
      kindText: 'أسبوعي',
    );

    for (var column = 0; column < baseHeaders.length; column++) {
      _writeHeader(sheet, _headerRow, column, baseHeaders[column]);
    }

    final days = [...snapshot.days]
      ..sort((left, right) => left.localDate.compareTo(right.localDate));

    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final startColumn = baseColumns + (dayIndex * _weeklyDayColumns);
      final prefix =
          '${_weekdayArabic(days[dayIndex].localDate)} '
          '${_dateText(days[dayIndex].localDate)}';

      _writeHeader(sheet, _headerRow, startColumn, '$prefix | الحضور');
      _writeHeader(sheet, _headerRow, startColumn + 1, '$prefix | من/إلى');
      _writeHeader(
        sheet,
        _headerRow,
        startColumn + 2,
        '$prefix | الإنجاز (وجه)',
      );
      _writeHeader(sheet, _headerRow, startColumn + 3, '$prefix | الملاحظات');
    }

    final students = [...snapshot.students]
      ..sort((left, right) => left.displayOrder.compareTo(right.displayOrder));

    for (var studentIndex = 0; studentIndex < students.length; studentIndex++) {
      final row = _firstStudentRow + studentIndex;
      final student = students[studentIndex];

      if (context == SupportReportContext.general) {
        _writeBody(sheet, row, 0, student.studentName);
        _writeBody(sheet, row, 1, student.currentJuz);
        _writeBody(sheet, row, 2, student.dailyPlanText ?? '');
      } else {
        _writeBody(sheet, row, 0, student.supportStudentNumber ?? '');
        _writeBody(sheet, row, 1, student.studentName);
        _writeBody(sheet, row, 2, student.currentJuz);
        _writeBody(sheet, row, 3, student.dailyPlanText ?? '');
        _writeBody(
          sheet,
          row,
          4,
          student.monthlyGoalQuarterFaces == null
              ? ''
              : _faces(student.monthlyGoalQuarterFaces!),
        );
      }

      for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
        final startColumn = baseColumns + (dayIndex * _weeklyDayColumns);
        final dayCells = _weeklyDayCells(
          days[dayIndex],
          student.sourceStudentId,
        );

        _writeBody(sheet, row, startColumn, dayCells.attendance);
        _writeBody(sheet, row, startColumn + 1, dayCells.rangeText);
        _writeBody(sheet, row, startColumn + 2, dayCells.achievedFaces);
        _writeBody(sheet, row, startColumn + 3, dayCells.noteText);
      }
    }

    _setWeeklyWidths(sheet, days.length, context);

    final bytes = excel.save();

    if (bytes == null || bytes.isEmpty) {
      throw StateError('Weekly Excel workbook could not be encoded.');
    }

    return List<int>.unmodifiable(bytes);
  }

  List<int> buildMonthly(ApprovedMonthlySupportReportSnapshot snapshot) {
    final context = snapshot.header.reportContext;
    final targetSheetName = _sheetNameFor(context);
    final baseHeaders = _baseHeadersFor(context);
    final baseColumns = baseHeaders.length;
    final aggregateHeaders = _monthlyAggregateHeadersFor(context);

    final excel = Excel.createExcel();
    excel.rename('Sheet1', targetSheetName);
    final sheet = excel[targetSheetName];

    sheet.isRTL = true;

    final days = [...snapshot.days]
      ..sort((left, right) => left.localDate.compareTo(right.localDate));
    final aggregateStart = baseColumns + (days.length * _monthlyDayColumns);
    final columnCount = aggregateStart + aggregateHeaders.length;

    _writeTitle(
      sheet,
      title: _monthlyTitleFor(context),
      lastColumn: columnCount - 1,
    );
    _writeMetadata(
      sheet,
      header: snapshot.header,
      periodText:
          '${_dateText(snapshot.period.monthStart)} إلى '
          '${_dateText(snapshot.period.monthEnd)}',
      sourceFingerprint: snapshot.sourceFingerprint,
      kindText: 'شهري',
    );

    for (var column = 0; column < baseHeaders.length; column++) {
      _writeHeader(sheet, _headerRow, column, baseHeaders[column]);
    }

    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final startColumn = baseColumns + (dayIndex * _monthlyDayColumns);
      final prefix =
          '${_weekdayArabic(days[dayIndex].localDate)} '
          '${_dateText(days[dayIndex].localDate)}';

      _writeHeader(sheet, _headerRow, startColumn, '$prefix | الحضور');
      _writeHeader(sheet, _headerRow, startColumn + 1, '$prefix | من/إلى');
      _writeHeader(
        sheet,
        _headerRow,
        startColumn + 2,
        '$prefix | الإنجاز (وجه)',
      );
      _writeHeader(sheet, _headerRow, startColumn + 3, '$prefix | الملاحظات');
    }

    for (var offset = 0; offset < aggregateHeaders.length; offset++) {
      _writeHeader(
        sheet,
        _headerRow,
        aggregateStart + offset,
        aggregateHeaders[offset],
      );
    }

    final students = [...snapshot.students]
      ..sort((left, right) => left.displayOrder.compareTo(right.displayOrder));

    for (var studentIndex = 0; studentIndex < students.length; studentIndex++) {
      final row = _firstStudentRow + studentIndex;
      final student = students[studentIndex];

      if (context == SupportReportContext.general) {
        _writeBody(sheet, row, 0, student.studentName);
        _writeBody(sheet, row, 1, student.currentJuz);
        _writeBody(sheet, row, 2, student.dailyPlanText ?? '');
      } else {
        _writeBody(sheet, row, 0, student.supportStudentNumber ?? '');
        _writeBody(sheet, row, 1, student.studentName);
        _writeBody(sheet, row, 2, student.currentJuz);
        _writeBody(sheet, row, 3, student.dailyPlanText ?? '');
        _writeBody(
          sheet,
          row,
          4,
          student.monthlyGoalQuarterFaces == null
              ? ''
              : _faces(student.monthlyGoalQuarterFaces!),
        );
      }

      for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
        final startColumn = baseColumns + (dayIndex * _monthlyDayColumns);
        final dayCells = _monthlyDayCells(
          days[dayIndex],
          student.sourceStudentId,
        );

        _writeBody(sheet, row, startColumn, dayCells.attendance);
        _writeBody(sheet, row, startColumn + 1, dayCells.rangeText);
        _writeBody(sheet, row, startColumn + 2, dayCells.achievedFaces);
        _writeBody(sheet, row, startColumn + 3, dayCells.noteText);
      }

      _writeBody(sheet, row, aggregateStart, student.absenceDays);

      if (context == SupportReportContext.general) {
        _writeBody(
          sheet,
          row,
          aggregateStart + 1,
          _faces(student.achievedQuarterFaces),
        );
        _writeBody(sheet, row, aggregateStart + 2, student.note ?? '');
      } else {
        _writeBody(
          sheet,
          row,
          aggregateStart + 1,
          student.goalCompleted == null
              ? ''
              : student.goalCompleted!
              ? 'تم'
              : 'لم يتم',
        );
        _writeBody(
          sheet,
          row,
          aggregateStart + 2,
          _faces(student.achievedQuarterFaces),
        );
        _writeBody(sheet, row, aggregateStart + 3, student.note ?? '');
      }
    }

    _setMonthlyWidths(sheet, days.length, context);

    final bytes = excel.save();

    if (bytes == null || bytes.isEmpty) {
      throw StateError('Monthly Excel workbook could not be encoded.');
    }

    return List<int>.unmodifiable(bytes);
  }

  void _writeTitle(
    Sheet sheet, {
    required String title,
    required int lastColumn,
  }) {
    final first = CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0);
    final last = CellIndex.indexByColumnRow(
      columnIndex: lastColumn,
      rowIndex: 0,
    );

    sheet.merge(first, last, customValue: TextCellValue(title));
    sheet.cell(first).cellStyle = CellStyle(
      bold: true,
      fontSize: 16,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    sheet.setRowHeight(0, 28);
  }

  void _writeMetadata(
    Sheet sheet, {
    required SupportReportHeaderSnapshot header,
    required String periodText,
    required String sourceFingerprint,
    required String kindText,
  }) {
    _writeMetaPair(sheet, 1, 0, 'المعلم', header.teacherName);
    _writeMetaPair(sheet, 1, 2, 'الحلقة', header.halaqahName);
    _writeMetaPair(
      sheet,
      1,
      4,
      _organizationLabelFor(header.reportContext),
      header.organizationName,
    );

    _writeMetaPair(sheet, 2, 0, 'الفترة', periodText);
    _writeMetaPair(sheet, 2, 2, 'نسخة السياسة', header.policyVersion);
    _writeMetaPair(sheet, 2, 4, 'نسخة القالب', header.templateVersion);

    _writeMetaPair(sheet, 3, 0, 'بصمة المصدر', sourceFingerprint);
    _writeMetaPair(sheet, 4, 0, 'نوع التقرير', kindText);
  }

  void _writeMetaPair(
    Sheet sheet,
    int row,
    int column,
    String label,
    Object value,
  ) {
    _writeCell(
      sheet,
      row,
      column,
      label,
      CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
      ),
    );
    _writeCell(
      sheet,
      row,
      column + 1,
      value,
      CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
      ),
    );
  }

  void _writeHeader(Sheet sheet, int row, int column, String value) {
    _writeCell(
      sheet,
      row,
      column,
      value,
      CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      ),
    );
  }

  void _writeBody(Sheet sheet, int row, int column, Object? value) {
    _writeCell(
      sheet,
      row,
      column,
      value,
      CellStyle(
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
      ),
    );
  }

  void _writeCell(
    Sheet sheet,
    int row,
    int column,
    Object? value,
    CellStyle style,
  ) {
    final index = CellIndex.indexByColumnRow(
      columnIndex: column,
      rowIndex: row,
    );

    sheet.updateCell(index, _cellValue(value), cellStyle: style);
  }

  CellValue? _cellValue(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return TextCellValue(value);
    }
    if (value is int) {
      return IntCellValue(value);
    }
    if (value is double) {
      return DoubleCellValue(value);
    }

    throw ArgumentError.value(value, 'value', 'Unsupported Excel cell value');
  }

  void _setWeeklyWidths(
    Sheet sheet,
    int dayCount,
    SupportReportContext context,
  ) {
    final baseWidths = context == SupportReportContext.general
        ? const <double>[28, 14, 22]
        : const <double>[18, 28, 14, 22, 18];

    for (var column = 0; column < baseWidths.length; column++) {
      sheet.setColumnWidth(column, baseWidths[column]);
    }

    for (var dayIndex = 0; dayIndex < dayCount; dayIndex++) {
      final start = baseWidths.length + (dayIndex * _weeklyDayColumns);
      sheet.setColumnWidth(start, 18);
      sheet.setColumnWidth(start + 1, 30);
      sheet.setColumnWidth(start + 2, 18);
      sheet.setColumnWidth(start + 3, 28);
    }
  }

  void _setMonthlyWidths(
    Sheet sheet,
    int dayCount,
    SupportReportContext context,
  ) {
    final baseWidths = context == SupportReportContext.general
        ? const <double>[28, 14, 22]
        : const <double>[18, 28, 14, 22, 18];

    for (var column = 0; column < baseWidths.length; column++) {
      sheet.setColumnWidth(column, baseWidths[column]);
    }

    for (var dayIndex = 0; dayIndex < dayCount; dayIndex++) {
      final start = baseWidths.length + (dayIndex * _monthlyDayColumns);
      sheet.setColumnWidth(start, 18);
      sheet.setColumnWidth(start + 1, 30);
      sheet.setColumnWidth(start + 2, 18);
      sheet.setColumnWidth(start + 3, 28);
    }

    final aggregateStart = baseWidths.length + (dayCount * _monthlyDayColumns);
    final aggregateWidths = context == SupportReportContext.general
        ? const <double>[15, 18, 30]
        : const <double>[15, 16, 18, 30];

    for (var offset = 0; offset < aggregateWidths.length; offset++) {
      sheet.setColumnWidth(aggregateStart + offset, aggregateWidths[offset]);
    }
  }

  _WeeklyDayCells _weeklyDayCells(
    ApprovedWeeklySupportReportDaySnapshot day,
    int sourceStudentId,
  ) {
    if (day.dayKind == SupportReportDayKind.holiday) {
      return const _WeeklyDayCells(
        attendance: 'إجازة',
        rangeText: '',
        achievedFaces: 0,
        noteText: '',
      );
    }

    if (day.dayKind == SupportReportDayKind.missing) {
      return const _WeeklyDayCells(
        attendance: 'بيانات ناقصة',
        rangeText: '',
        achievedFaces: 0,
        noteText: '',
      );
    }

    if (day.dayKind == SupportReportDayKind.notApplicable) {
      return const _WeeklyDayCells(
        attendance: 'غير منطبق',
        rangeText: '',
        achievedFaces: 0,
        noteText: '',
      );
    }

    final entries =
        day.entries
            .where((entry) => entry.sourceStudentId == sourceStudentId)
            .toList()
          ..sort((left, right) => left.entryOrder.compareTo(right.entryOrder));

    SupportReportAttendanceStatus? attendanceStatus;
    var achievedQuarterFaces = 0;
    final ranges = <String>[];
    final notes = <String>[];

    for (final entry in entries) {
      attendanceStatus ??= entry.attendanceStatus;
      achievedQuarterFaces += entry.achievedQuarterFaces;

      if (entry.range != null) {
        ranges.add(_rangeText(entry.range!));
      }

      final note = entry.note?.trim();

      if (note != null && note.isNotEmpty) {
        notes.add(note);
      }
    }

    return _WeeklyDayCells(
      attendance: attendanceStatus == null
          ? 'غير مسجل'
          : _attendanceText(attendanceStatus),
      rangeText: ranges.join('؛ '),
      achievedFaces: _faces(achievedQuarterFaces),
      noteText: notes.join('؛ '),
    );
  }

  _WeeklyDayCells _monthlyDayCells(
    ApprovedMonthlySupportReportDaySnapshot day,
    int sourceStudentId,
  ) {
    if (day.dayKind == SupportReportDayKind.holiday) {
      return const _WeeklyDayCells(
        attendance: 'إجازة',
        rangeText: '',
        achievedFaces: 0,
        noteText: '',
      );
    }

    if (day.dayKind == SupportReportDayKind.missing) {
      return const _WeeklyDayCells(
        attendance: 'بيانات ناقصة',
        rangeText: '',
        achievedFaces: 0,
        noteText: '',
      );
    }

    if (day.dayKind == SupportReportDayKind.notApplicable) {
      return const _WeeklyDayCells(
        attendance: 'غير منطبق',
        rangeText: '',
        achievedFaces: 0,
        noteText: '',
      );
    }

    final entries =
        day.entries
            .where((entry) => entry.sourceStudentId == sourceStudentId)
            .toList()
          ..sort((left, right) => left.entryOrder.compareTo(right.entryOrder));

    SupportReportAttendanceStatus? attendanceStatus;
    var achievedQuarterFaces = 0;
    final ranges = <String>[];
    final notes = <String>[];

    for (final entry in entries) {
      attendanceStatus ??= entry.attendanceStatus;
      achievedQuarterFaces += entry.achievedQuarterFaces;

      if (entry.range != null) {
        ranges.add(_rangeText(entry.range!));
      }

      final note = entry.note?.trim();

      if (note != null && note.isNotEmpty) {
        notes.add(note);
      }
    }

    return _WeeklyDayCells(
      attendance: attendanceStatus == null
          ? 'غير مسجل'
          : _attendanceText(attendanceStatus),
      rangeText: ranges.join('؛ '),
      achievedFaces: _faces(achievedQuarterFaces),
      noteText: notes.join('؛ '),
    );
  }

  String _rangeText(SupportReportQuranRange range) {
    final startName = QuranReferenceData.surahByNumber(
      range.startSurah,
    ).arabicName;
    final endName = QuranReferenceData.surahByNumber(range.endSurah).arabicName;

    if (range.startSurah == range.endSurah) {
      return '$startName ${range.startAyah}–${range.endAyah}';
    }

    return '$startName ${range.startAyah} → '
        '$endName ${range.endAyah}';
  }

  String _attendanceText(SupportReportAttendanceStatus status) {
    return switch (status) {
      SupportReportAttendanceStatus.present => 'حاضر',
      SupportReportAttendanceStatus.absent => 'غائب',
      SupportReportAttendanceStatus.excusedAbsent => 'غائب بعذر',
    };
  }

  String _weekdayArabic(DateTime date) {
    return switch (date.weekday) {
      DateTime.saturday => 'السبت',
      DateTime.sunday => 'الأحد',
      DateTime.monday => 'الاثنين',
      DateTime.tuesday => 'الثلاثاء',
      DateTime.wednesday => 'الأربعاء',
      DateTime.thursday => 'الخميس',
      DateTime.friday => 'الجمعة',
      _ => '',
    };
  }

  String _dateText(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  double _faces(int quarterFaces) => quarterFaces / 4;
}

final class SupportReportExcelVerifier {
  const SupportReportExcelVerifier();

  SupportReportExcelVerificationResult verifyWeekly(
    List<int> bytes,
    ApprovedWeeklySupportReportSnapshot snapshot,
  ) {
    try {
      const mapper = ExcelTemplateMapper();
      final context = snapshot.header.reportContext;
      final targetSheetName = mapper._sheetNameFor(context);
      final baseHeaders = mapper._baseHeadersFor(context);
      final baseColumns = baseHeaders.length;

      final excel = Excel.decodeBytes(bytes);

      if (!excel.tables.containsKey(targetSheetName)) {
        return const SupportReportExcelVerificationResult.invalid(
          'Expected report sheet was not found.',
        );
      }

      final sheet = excel[targetSheetName];

      if (!sheet.isRTL) {
        return const SupportReportExcelVerificationResult.invalid(
          'Report sheet is not RTL.',
        );
      }

      final metadataFailure = _verifyMetadata(
        sheet,
        title: mapper._weeklyTitleFor(context),
        header: snapshot.header,
        periodText:
            '${_dateText(snapshot.period.weekStart)} إلى '
            '${_dateText(snapshot.period.weekEnd)}',
        sourceFingerprint: snapshot.sourceFingerprint,
        kindText: 'أسبوعي',
      );

      if (metadataFailure != null) {
        return SupportReportExcelVerificationResult.invalid(metadataFailure);
      }

      for (var column = 0; column < baseHeaders.length; column++) {
        final failure = _expectText(
          sheet,
          ExcelTemplateMapper._headerRow,
          column,
          baseHeaders[column],
        );

        if (failure != null) {
          return SupportReportExcelVerificationResult.invalid(failure);
        }
      }

      final days = [...snapshot.days]
        ..sort((left, right) => left.localDate.compareTo(right.localDate));

      for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
        final start =
            baseColumns + (dayIndex * ExcelTemplateMapper._weeklyDayColumns);
        final prefix =
            '${_weekdayArabic(days[dayIndex].localDate)} '
            '${_dateText(days[dayIndex].localDate)}';

        final expectedHeaders = <String>[
          '$prefix | الحضور',
          '$prefix | من/إلى',
          '$prefix | الإنجاز (وجه)',
          '$prefix | الملاحظات',
        ];

        for (var offset = 0; offset < expectedHeaders.length; offset++) {
          final failure = _expectText(
            sheet,
            ExcelTemplateMapper._headerRow,
            start + offset,
            expectedHeaders[offset],
          );

          if (failure != null) {
            return SupportReportExcelVerificationResult.invalid(failure);
          }
        }
      }

      final students = [
        ...snapshot.students,
      ]..sort((left, right) => left.displayOrder.compareTo(right.displayOrder));

      for (
        var studentIndex = 0;
        studentIndex < students.length;
        studentIndex++
      ) {
        final row = ExcelTemplateMapper._firstStudentRow + studentIndex;
        final student = students[studentIndex];

        final baseFailures = context == SupportReportContext.general
            ? <String?>[
                _expectText(sheet, row, 0, student.studentName),
                student.currentJuz == null
                    ? _expectBlank(sheet, row, 1)
                    : _expectNumber(
                        sheet,
                        row,
                        1,
                        student.currentJuz!.toDouble(),
                      ),
                _expectText(sheet, row, 2, student.dailyPlanText ?? ''),
              ]
            : <String?>[
                _expectText(sheet, row, 0, student.supportStudentNumber ?? ''),
                _expectText(sheet, row, 1, student.studentName),
                student.currentJuz == null
                    ? _expectBlank(sheet, row, 2)
                    : _expectNumber(
                        sheet,
                        row,
                        2,
                        student.currentJuz!.toDouble(),
                      ),
                _expectText(sheet, row, 3, student.dailyPlanText ?? ''),
                student.monthlyGoalQuarterFaces == null
                    ? _expectBlank(sheet, row, 4)
                    : _expectNumber(
                        sheet,
                        row,
                        4,
                        mapper._faces(student.monthlyGoalQuarterFaces!),
                      ),
              ];

        for (final failure in baseFailures) {
          if (failure != null) {
            return SupportReportExcelVerificationResult.invalid(failure);
          }
        }

        for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
          final start =
              baseColumns + (dayIndex * ExcelTemplateMapper._weeklyDayColumns);
          final expected = mapper._weeklyDayCells(
            days[dayIndex],
            student.sourceStudentId,
          );

          final failures = <String?>[
            _expectText(sheet, row, start, expected.attendance),
            _expectText(sheet, row, start + 1, expected.rangeText),
            _expectNumber(sheet, row, start + 2, expected.achievedFaces),
            _expectText(sheet, row, start + 3, expected.noteText),
          ];

          for (final failure in failures) {
            if (failure != null) {
              return SupportReportExcelVerificationResult.invalid(failure);
            }
          }
        }
      }

      final nextStudentRow =
          ExcelTemplateMapper._firstStudentRow + students.length;
      final studentNameColumn = context == SupportReportContext.general ? 0 : 1;
      final extraStudentFailure = _expectBlank(
        sheet,
        nextStudentRow,
        studentNameColumn,
      );

      if (extraStudentFailure != null) {
        return const SupportReportExcelVerificationResult.invalid(
          'Unexpected extra student row exists.',
        );
      }

      return const SupportReportExcelVerificationResult.valid();
    } catch (error) {
      return SupportReportExcelVerificationResult.invalid(
        'Weekly Excel reopen failed: $error',
      );
    }
  }

  SupportReportExcelVerificationResult verifyMonthly(
    List<int> bytes,
    ApprovedMonthlySupportReportSnapshot snapshot,
  ) {
    try {
      const mapper = ExcelTemplateMapper();
      final context = snapshot.header.reportContext;
      final targetSheetName = mapper._sheetNameFor(context);
      final baseHeaders = mapper._baseHeadersFor(context);
      final baseColumns = baseHeaders.length;
      final aggregateHeaders = mapper._monthlyAggregateHeadersFor(context);

      final excel = Excel.decodeBytes(bytes);

      if (!excel.tables.containsKey(targetSheetName)) {
        return const SupportReportExcelVerificationResult.invalid(
          'Expected report sheet was not found.',
        );
      }

      final sheet = excel[targetSheetName];

      if (!sheet.isRTL) {
        return const SupportReportExcelVerificationResult.invalid(
          'Report sheet is not RTL.',
        );
      }

      final metadataFailure = _verifyMetadata(
        sheet,
        title: mapper._monthlyTitleFor(context),
        header: snapshot.header,
        periodText:
            '${_dateText(snapshot.period.monthStart)} إلى '
            '${_dateText(snapshot.period.monthEnd)}',
        sourceFingerprint: snapshot.sourceFingerprint,
        kindText: 'شهري',
      );

      if (metadataFailure != null) {
        return SupportReportExcelVerificationResult.invalid(metadataFailure);
      }

      for (var column = 0; column < baseHeaders.length; column++) {
        final failure = _expectText(
          sheet,
          ExcelTemplateMapper._headerRow,
          column,
          baseHeaders[column],
        );

        if (failure != null) {
          return SupportReportExcelVerificationResult.invalid(failure);
        }
      }

      final days = [...snapshot.days]
        ..sort((left, right) => left.localDate.compareTo(right.localDate));

      for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
        final start =
            baseColumns + (dayIndex * ExcelTemplateMapper._monthlyDayColumns);
        final prefix =
            '${_weekdayArabic(days[dayIndex].localDate)} '
            '${_dateText(days[dayIndex].localDate)}';
        final expectedHeaders = <String>[
          '$prefix | الحضور',
          '$prefix | من/إلى',
          '$prefix | الإنجاز (وجه)',
          '$prefix | الملاحظات',
        ];

        for (var offset = 0; offset < expectedHeaders.length; offset++) {
          final failure = _expectText(
            sheet,
            ExcelTemplateMapper._headerRow,
            start + offset,
            expectedHeaders[offset],
          );

          if (failure != null) {
            return SupportReportExcelVerificationResult.invalid(failure);
          }
        }
      }

      final aggregateStart =
          baseColumns + (days.length * ExcelTemplateMapper._monthlyDayColumns);

      for (var offset = 0; offset < aggregateHeaders.length; offset++) {
        final failure = _expectText(
          sheet,
          ExcelTemplateMapper._headerRow,
          aggregateStart + offset,
          aggregateHeaders[offset],
        );

        if (failure != null) {
          return SupportReportExcelVerificationResult.invalid(failure);
        }
      }

      final students = [
        ...snapshot.students,
      ]..sort((left, right) => left.displayOrder.compareTo(right.displayOrder));

      for (
        var studentIndex = 0;
        studentIndex < students.length;
        studentIndex++
      ) {
        final row = ExcelTemplateMapper._firstStudentRow + studentIndex;
        final student = students[studentIndex];

        final baseFailures = context == SupportReportContext.general
            ? <String?>[
                _expectText(sheet, row, 0, student.studentName),
                student.currentJuz == null
                    ? _expectBlank(sheet, row, 1)
                    : _expectNumber(
                        sheet,
                        row,
                        1,
                        student.currentJuz!.toDouble(),
                      ),
                _expectText(sheet, row, 2, student.dailyPlanText ?? ''),
              ]
            : <String?>[
                _expectText(sheet, row, 0, student.supportStudentNumber ?? ''),
                _expectText(sheet, row, 1, student.studentName),
                student.currentJuz == null
                    ? _expectBlank(sheet, row, 2)
                    : _expectNumber(
                        sheet,
                        row,
                        2,
                        student.currentJuz!.toDouble(),
                      ),
                _expectText(sheet, row, 3, student.dailyPlanText ?? ''),
                student.monthlyGoalQuarterFaces == null
                    ? _expectBlank(sheet, row, 4)
                    : _expectNumber(
                        sheet,
                        row,
                        4,
                        mapper._faces(student.monthlyGoalQuarterFaces!),
                      ),
              ];

        for (final failure in baseFailures) {
          if (failure != null) {
            return SupportReportExcelVerificationResult.invalid(failure);
          }
        }

        for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
          final start =
              baseColumns + (dayIndex * ExcelTemplateMapper._monthlyDayColumns);
          final expected = mapper._monthlyDayCells(
            days[dayIndex],
            student.sourceStudentId,
          );
          final failures = <String?>[
            _expectText(sheet, row, start, expected.attendance),
            _expectText(sheet, row, start + 1, expected.rangeText),
            _expectNumber(sheet, row, start + 2, expected.achievedFaces),
            _expectText(sheet, row, start + 3, expected.noteText),
          ];

          for (final failure in failures) {
            if (failure != null) {
              return SupportReportExcelVerificationResult.invalid(failure);
            }
          }
        }

        final aggregateFailures = context == SupportReportContext.general
            ? <String?>[
                _expectNumber(
                  sheet,
                  row,
                  aggregateStart,
                  student.absenceDays.toDouble(),
                ),
                _expectNumber(
                  sheet,
                  row,
                  aggregateStart + 1,
                  mapper._faces(student.achievedQuarterFaces),
                ),
                _expectText(sheet, row, aggregateStart + 2, student.note ?? ''),
              ]
            : <String?>[
                _expectNumber(
                  sheet,
                  row,
                  aggregateStart,
                  student.absenceDays.toDouble(),
                ),
                _expectText(
                  sheet,
                  row,
                  aggregateStart + 1,
                  student.goalCompleted == null
                      ? ''
                      : student.goalCompleted!
                      ? 'تم'
                      : 'لم يتم',
                ),
                _expectNumber(
                  sheet,
                  row,
                  aggregateStart + 2,
                  mapper._faces(student.achievedQuarterFaces),
                ),
                _expectText(sheet, row, aggregateStart + 3, student.note ?? ''),
              ];

        for (final failure in aggregateFailures) {
          if (failure != null) {
            return SupportReportExcelVerificationResult.invalid(failure);
          }
        }
      }

      final nextStudentRow =
          ExcelTemplateMapper._firstStudentRow + students.length;
      final studentNameColumn = context == SupportReportContext.general ? 0 : 1;
      final extraStudentFailure = _expectBlank(
        sheet,
        nextStudentRow,
        studentNameColumn,
      );

      if (extraStudentFailure != null) {
        return const SupportReportExcelVerificationResult.invalid(
          'Unexpected extra student row exists.',
        );
      }

      return const SupportReportExcelVerificationResult.valid();
    } catch (error) {
      return SupportReportExcelVerificationResult.invalid(
        'Monthly Excel reopen failed: $error',
      );
    }
  }

  String? _verifyMetadata(
    Sheet sheet, {
    required String title,
    required SupportReportHeaderSnapshot header,
    required String periodText,
    required String sourceFingerprint,
    required String kindText,
  }) {
    const mapper = ExcelTemplateMapper();
    final failures = <String?>[
      _expectText(sheet, 0, 0, title),
      _expectText(sheet, 1, 0, 'المعلم'),
      _expectText(sheet, 1, 1, header.teacherName),
      _expectText(sheet, 1, 2, 'الحلقة'),
      _expectText(sheet, 1, 3, header.halaqahName),
      _expectText(
        sheet,
        1,
        4,
        mapper._organizationLabelFor(header.reportContext),
      ),
      _expectText(sheet, 1, 5, header.organizationName),
      _expectText(sheet, 2, 0, 'الفترة'),
      _expectText(sheet, 2, 1, periodText),
      _expectText(sheet, 2, 2, 'نسخة السياسة'),
      _expectNumber(sheet, 2, 3, header.policyVersion.toDouble()),
      _expectText(sheet, 2, 4, 'نسخة القالب'),
      _expectNumber(sheet, 2, 5, header.templateVersion.toDouble()),
      _expectText(sheet, 3, 0, 'بصمة المصدر'),
      _expectText(sheet, 3, 1, sourceFingerprint),
      _expectText(sheet, 4, 0, 'نوع التقرير'),
      _expectText(sheet, 4, 1, kindText),
    ];

    for (final failure in failures) {
      if (failure != null) {
        return failure;
      }
    }

    return null;
  }

  String? _expectText(Sheet sheet, int row, int column, String expected) {
    final actual = _textAt(sheet, row, column);

    if (actual != expected) {
      return 'Cell ${_cellLabel(row, column)} expected "$expected" '
          'but found "$actual".';
    }

    return null;
  }

  String? _expectNumber(Sheet sheet, int row, int column, double expected) {
    final actual = _numberAt(sheet, row, column);

    if (actual == null || (actual - expected).abs() > 0.000001) {
      return 'Cell ${_cellLabel(row, column)} expected numeric $expected '
          'but found ${_textAt(sheet, row, column)}.';
    }

    return null;
  }

  String? _expectBlank(Sheet sheet, int row, int column) {
    final value = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
        .value;

    if (value != null && _textAt(sheet, row, column).isNotEmpty) {
      return 'Cell ${_cellLabel(row, column)} expected blank.';
    }

    return null;
  }

  String _textAt(Sheet sheet, int row, int column) {
    final value = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
        .value;

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

  String _cellLabel(int row, int column) {
    return CellIndex.indexByColumnRow(
      columnIndex: column,
      rowIndex: row,
    ).cellId;
  }

  String _weekdayArabic(DateTime date) {
    return switch (date.weekday) {
      DateTime.saturday => 'السبت',
      DateTime.sunday => 'الأحد',
      DateTime.monday => 'الاثنين',
      DateTime.tuesday => 'الثلاثاء',
      DateTime.wednesday => 'الأربعاء',
      DateTime.thursday => 'الخميس',
      DateTime.friday => 'الجمعة',
      _ => '',
    };
  }

  String _dateText(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

final class _WeeklyDayCells {
  const _WeeklyDayCells({
    required this.attendance,
    required this.rangeText,
    required this.achievedFaces,
    required this.noteText,
  });

  final String attendance;
  final String rangeText;
  final double achievedFaces;
  final String noteText;
}
