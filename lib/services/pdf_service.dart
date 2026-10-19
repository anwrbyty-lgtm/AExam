import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/exam_data.dart';

class PdfService {
  static Future<Uint8List> generateExam(ExamData data) async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(await rootBundle.load("assets/fonts/Cairo-Regular.ttf"));
    final fontBold = pw.Font.ttf(await rootBundle.load("assets/fonts/Cairo-Bold.ttf"));
    final logoImage = pw.MemoryImage(
      (await rootBundle.load("assets/images/logo.png")).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (pw.Context context) {
          return [
            pw.Table(
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      alignment: pw.Alignment.center,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text("الجمهورية اليمنية", style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text("وزارة التربية والتعليم", style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.Text("مكتب التربية والتعليم / حضرموت", style: const pw.TextStyle(fontSize: 8)),
                          pw.Text("ادارة التربية والتعليم / حجر", style: const pw.TextStyle(fontSize: 8)),
                          pw.Text("مجمع ٣٠ نوفمبر", style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text("بسم الله الرحمن الرحيم", style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Image(logoImage, height: 40),
                        ],
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildHeaderRow("المادة:", data.subject),
                          _buildHeaderRow("الاختبار:", data.examType),
                          _buildHeaderRow("الصف:", data.grade),
                          _buildHeaderRow("الزمن:", data.duration),
                          _buildHeaderRow("الفترة:", data.period),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Table(
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text("اسم الطالب", style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      alignment: pw.Alignment.center,
                      child: pw.Text("درجة الطالب", style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      alignment: pw.Alignment.center,
                      child: pw.Text("18", style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            _buildQuestionTitle("السؤال الأول: ضع علامة صح أو خطأ", "6 درجات"),
            pw.Table(
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF9E6)),
                  children: [
                    _buildTableHeader("#"),
                    _buildTableHeader("العبارة"),
                    _buildTableHeader("الإجابة"),
                  ],
                ),
                ...data.trueFalseQuestions.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  return pw.TableRow(
                    children: [
                      _buildTableCell(index.toString(), isCenter: true),
                      _buildTableCell(entry.value.text),
                      _buildTableCell("(    )", isCenter: true),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 15),
            if (data.mcqQuestions.isNotEmpty) ...[
              _buildQuestionTitle("السؤال الثاني: اختر الإجابة الصحيحة", "3 درجات"),
              ...data.mcqQuestions.asMap().entries.map((entry) {
                int index = entry.key + 1;
                final q = entry.value;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 5),
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(5),
                        color: const PdfColor.fromInt(0xFFF5F5F5),
                        child: pw.Text("$index- ${q.text}", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          pw.Text("أ) ${q.options.isNotEmpty ? q.options[0] : ''}"),
                          pw.Text("ب) ${q.options.length > 1 ? q.options[1] : ''}"),
                          pw.Text("ج) ${q.options.length > 2 ? q.options[2] : ''}"),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ];
        },
      ),
    );
    return pdf.save();
  }

  static pw.Widget _buildHeaderRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.Container(width: 60, alignment: pw.Alignment.centerRight, child: pw.Text(value, style: const pw.TextStyle(fontSize: 9))),
      ],
    );
  }

  static pw.Widget _buildQuestionTitle(String title, String grade) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 1), color: const PdfColor.fromInt(0xFFFFF9E6)),
          child: pw.Text(title, style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 1), color: const PdfColor.fromInt(0xFFFFF9E6)),
          child: pw.Text(grade, style: const pw.TextStyle(fontSize: 9)),
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isCenter = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: isCenter ? pw.Alignment.center : pw.Alignment.centerRight,
      child: pw.Text(text),
    );
  }
}
