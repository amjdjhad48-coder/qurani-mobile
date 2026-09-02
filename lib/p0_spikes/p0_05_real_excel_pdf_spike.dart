import 'dart:typed_data';

import 'package:excel_plus/excel_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final class P005RealExcelPdfSpike {
  const P005RealExcelPdfSpike._();

  static const String sheetName = 'تقرير';
  static const String reportTitle = 'تقرير قرآني التجريبي';

  static Uint8List buildArabicExcel() {
    final excel = Excel.createExcel();
    excel.rename('Sheet1', sheetName);

    final sheet = excel[sheetName];
    sheet.isRTL = true;

    final titleStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      textWrapping: TextWrapping.WrapText,
      bold: true,
      fontSize: 16,
    );

    final headerStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      textWrapping: TextWrapping.WrapText,
      bold: true,
    );

    final bodyStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      textWrapping: TextWrapping.WrapText,
    );

    sheet.updateCell(
      CellIndex.indexByString('A1'),
      TextCellValue(reportTitle),
      cellStyle: titleStyle,
    );

    sheet.updateCell(
      CellIndex.indexByString('A2'),
      TextCellValue('اسم الطالب'),
      cellStyle: headerStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('B2'),
      TextCellValue('الإنجاز'),
      cellStyle: headerStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('C2'),
      TextCellValue('الحضور'),
      cellStyle: headerStyle,
    );

    sheet.updateCell(
      CellIndex.indexByString('A3'),
      TextCellValue('أحمد محمد'),
      cellStyle: bodyStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('B3'),
      DoubleCellValue(12.5),
      cellStyle: bodyStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('C3'),
      TextCellValue('حاضر'),
      cellStyle: bodyStyle,
    );

    sheet.updateCell(
      CellIndex.indexByString('A4'),
      TextCellValue('محمد علي'),
      cellStyle: bodyStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('B4'),
      DoubleCellValue(10),
      cellStyle: bodyStyle,
    );
    sheet.updateCell(
      CellIndex.indexByString('C4'),
      TextCellValue('غائب بعذر'),
      cellStyle: bodyStyle,
    );

    sheet.setColumnWidth(0, 28);
    sheet.setColumnWidth(1, 16);
    sheet.setColumnWidth(2, 18);

    final encoded = excel.encode();
    if (encoded == null) {
      throw StateError('excel_plus returned null XLSX bytes.');
    }

    return Uint8List.fromList(encoded);
  }

  static Future<Uint8List> buildArabicPdf({
    required Uint8List regularFontBytes,
    required Uint8List boldFontBytes,
  }) async {
    final regularFont = pw.Font.ttf(ByteData.sublistView(regularFontBytes));
    final boldFont = pw.Font.ttf(ByteData.sublistView(boldFontBytes));

    final document = pw.Document(
      title: reportTitle,
      creator: 'Qurani P0-05 real file spike',
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Text(
            reportTitle,
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: const ['اسم الطالب', 'الإنجاز', 'الحضور'],
            data: const [
              ['أحمد محمد', '12.5', 'حاضر'],
              ['محمد علي', '10', 'غائب بعذر'],
            ],
            headerStyle: pw.TextStyle(
              font: boldFont,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: pw.TextStyle(font: regularFont),
            headerAlignment: pw.Alignment.centerRight,
            cellAlignment: pw.Alignment.centerRight,
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'هذا ملف PDF عربي حقيقي للتحقق من اتجاه النص والخط وفتح الملف.',
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(font: regularFont, fontSize: 13),
          ),
        ],
      ),
    );

    return Uint8List.fromList(await document.save());
  }
}
