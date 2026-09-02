import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dart_pdf_reader/dart_pdf_reader.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/p0_spikes/p0_05_real_excel_pdf_spike.dart';

String _textAt(Sheet sheet, String address) {
  final value = sheet.cell(CellIndex.indexByString(address)).value;
  if (value is TextCellValue) {
    return value.value.text ?? value.toString();
  }
  return value?.toString() ?? '';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('P0-05 generates and reopens real Arabic XLSX and PDF files', () async {
    final outputDir = Directory(
      '${Directory.current.path}${Platform.pathSeparator}build'
      '${Platform.pathSeparator}p0_05_probe',
    );

    if (await outputDir.exists()) {
      await outputDir.delete(recursive: true);
    }
    await outputDir.create(recursive: true);

    final regularData = await rootBundle.load(
      'assets/p0_spikes/p0_05/fonts/Amiri-Regular.ttf',
    );
    final boldData = await rootBundle.load(
      'assets/p0_spikes/p0_05/fonts/Amiri-Bold.ttf',
    );

    expect(regularData.lengthInBytes, greaterThan(100000));
    expect(boldData.lengthInBytes, greaterThan(100000));

    final xlsxBytes = P005RealExcelPdfSpike.buildArabicExcel();
    expect(xlsxBytes.length, greaterThan(1000));
    expect(xlsxBytes[0], 0x50);
    expect(xlsxBytes[1], 0x4b);

    final xlsxFile = File(
      '${outputDir.path}${Platform.pathSeparator}qurani_arabic_report_probe.xlsx',
    );
    await xlsxFile.writeAsBytes(xlsxBytes, flush: true);

    expect(await xlsxFile.exists(), isTrue);
    expect(await xlsxFile.length(), xlsxBytes.length);

    final xlsxDiskBytes = await xlsxFile.readAsBytes();
    final reopened = Excel.decodeBytes(xlsxDiskBytes);

    expect(
      reopened.tables.containsKey(P005RealExcelPdfSpike.sheetName),
      isTrue,
    );

    final sheet = reopened[P005RealExcelPdfSpike.sheetName];

    expect(sheet.isRTL, isTrue);
    expect(_textAt(sheet, 'A1'), P005RealExcelPdfSpike.reportTitle);
    expect(_textAt(sheet, 'A2'), 'اسم الطالب');
    expect(_textAt(sheet, 'A3'), 'أحمد محمد');
    expect(_textAt(sheet, 'C3'), 'حاضر');
    expect(_textAt(sheet, 'A4'), 'محمد علي');
    expect(_textAt(sheet, 'C4'), 'غائب بعذر');

    final numericB3 = sheet.cell(CellIndex.indexByString('B3')).value;
    expect(numericB3, isA<DoubleCellValue>());
    expect((numericB3! as DoubleCellValue).value, 12.5);

    final xlsxArchive = ZipDecoder().decodeBytes(xlsxDiskBytes);

    var rawRtl = false;
    var rawArabicTitle = false;
    var rawArabicStudent = false;

    for (final entry in xlsxArchive.files) {
      if (!entry.isFile || !entry.name.endsWith('.xml')) {
        continue;
      }

      final xml = utf8.decode(entry.content, allowMalformed: true);

      if (entry.name.startsWith('xl/worksheets/') &&
          (xml.contains('rightToLeft="1"') ||
              xml.contains('rightToLeft="true"'))) {
        rawRtl = true;
      }

      if (xml.contains(P005RealExcelPdfSpike.reportTitle)) {
        rawArabicTitle = true;
      }

      if (xml.contains('أحمد محمد')) {
        rawArabicStudent = true;
      }
    }

    expect(rawRtl, isTrue);
    expect(rawArabicTitle, isTrue);
    expect(rawArabicStudent, isTrue);

    final pdfBytes = await P005RealExcelPdfSpike.buildArabicPdf(
      regularFontBytes: regularData.buffer.asUint8List(
        regularData.offsetInBytes,
        regularData.lengthInBytes,
      ),
      boldFontBytes: boldData.buffer.asUint8List(
        boldData.offsetInBytes,
        boldData.lengthInBytes,
      ),
    );

    expect(pdfBytes.length, greaterThan(5000));
    expect(ascii.decode(pdfBytes.sublist(0, 5)), '%PDF-');

    final pdfTailStart = pdfBytes.length > 128 ? pdfBytes.length - 128 : 0;
    final pdfTail = ascii.decode(
      pdfBytes.sublist(pdfTailStart),
      allowInvalid: true,
    );
    expect(pdfTail.contains('%%EOF'), isTrue);

    final pdfFile = File(
      '${outputDir.path}${Platform.pathSeparator}qurani_arabic_report_probe.pdf',
    );
    await pdfFile.writeAsBytes(pdfBytes, flush: true);

    expect(await pdfFile.exists(), isTrue);
    expect(await pdfFile.length(), pdfBytes.length);

    final pdfDiskBytes = await pdfFile.readAsBytes();
    final parsed = await PDFParser(ByteStream(pdfDiskBytes)).parse();
    final catalog = await parsed.catalog;
    final pages = await catalog.getPages();

    expect(pages.pageCount, greaterThanOrEqualTo(1));
    expect(pages.getPageAtIndex(0).runtimeType.toString(), isNotEmpty);

    // Evidence markers are intentionally printed for the P0-05 gate transcript.
    // The file contents above are also asserted structurally before these markers.
    // ignore: avoid_print
    print('P0_05_PROJECT_XLSX_FILE=${xlsxFile.path}');
    // ignore: avoid_print
    print('P0_05_PROJECT_XLSX_BYTES=${await xlsxFile.length()}');
    // ignore: avoid_print
    print('P0_05_PROJECT_XLSX_PROGRAMMATIC_REOPEN=PASS');
    // ignore: avoid_print
    print('P0_05_PROJECT_XLSX_ARABIC_VALUES_ROUNDTRIP=PASS');
    // ignore: avoid_print
    print('P0_05_PROJECT_XLSX_RTL_ROUNDTRIP=PASS');
    // ignore: avoid_print
    print('P0_05_PROJECT_XLSX_RAW_OOXML_RTL=PASS');
    // ignore: avoid_print
    print('P0_05_PROJECT_XLSX_RAW_OOXML_ARABIC=PASS');

    // ignore: avoid_print
    print('P0_05_PROJECT_PDF_FILE=${pdfFile.path}');
    // ignore: avoid_print
    print('P0_05_PROJECT_PDF_BYTES=${await pdfFile.length()}');
    // ignore: avoid_print
    print('P0_05_PROJECT_PDF_PROGRAMMATIC_REOPEN=PASS');
    // ignore: avoid_print
    print('P0_05_PROJECT_PDF_PAGE_TREE_VALID=PASS');
    // ignore: avoid_print
    print('P0_05_PROJECT_PDF_ARABIC_AMIRI_BUILD=PASS');
    // ignore: avoid_print
    print('QURANI_P0_05_PROJECT_GENERATE_REOPEN_PROOF_OK');
  });
}
