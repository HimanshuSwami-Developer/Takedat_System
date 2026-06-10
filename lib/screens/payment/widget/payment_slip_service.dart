import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

class PaymentSlipService {
  static Future<void> generateSlip({
    required String employeeName,

    required String employeeId,

    required DateTime shiftStart,

    required DateTime shiftEnd,

    required double cashPayment,

    required double niPayment,

    required double expense,

    required String paymentStatus,
  }) async {
    final pdf = pw.Document();

    final total = cashPayment + niPayment + expense;

    final totalHours = shiftEnd.difference(shiftStart).inHours;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,

        margin: const pw.EdgeInsets.all(32),

        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,

            children: [
              /// HEADER
              pw.Container(
                padding: const pw.EdgeInsets.all(24),

                decoration: pw.BoxDecoration(
                  color: PdfColors.green700,

                  borderRadius: pw.BorderRadius.circular(16),
                ),

                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,

                      children: [
                        pw.Text(
                          "PAYMENT SLIP",

                          style: pw.TextStyle(
                            color: PdfColors.white,

                            fontSize: 26,

                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 6),

                        pw.Text(
                          "Takedat Security",

                          style: const pw.TextStyle(color: PdfColors.white),
                        ),
                      ],
                    ),

                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),

                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,

                        borderRadius: pw.BorderRadius.circular(30),
                      ),

                      child: pw.Text(
                        paymentStatus.toUpperCase(),

                        style: pw.TextStyle(
                          color: PdfColors.green700,

                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 28),

              /// EMPLOYEE DETAILS
              pw.Container(
                padding: const pw.EdgeInsets.all(20),

                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),

                  borderRadius: pw.BorderRadius.circular(14),
                ),

                child: pw.Column(
                  children: [
                    _row("Employee Name", employeeName),

                    _row("Employee ID", employeeId),

                    _row(
                      "Shift Start",

                      DateFormat('dd MMM yyyy hh:mm a').format(shiftStart),
                    ),

                    _row(
                      "Shift End",

                      DateFormat('dd MMM yyyy hh:mm a').format(shiftEnd),
                    ),

                    _row("Total Hours", "$totalHours hrs"),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              /// PAYMENT TABLE
              pw.Text(
                "Payment Summary",

                style: pw.TextStyle(
                  fontSize: 18,

                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 16),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),

                children: [
                  /// HEADER
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.green100,
                    ),

                    children: [_tableHeader("Type"), _tableHeader("Amount")],
                  ),

                  /// CASH
                  _tableRow(
                    "Payment I",
                    "£${cashPayment.toStringAsFixed(2)}",
                  ),

                  /// NI
                  _tableRow("Payment II", "£${niPayment.toStringAsFixed(2)}"),

                  /// EXPENSE
                  _tableRow("Expense", "£${expense.toStringAsFixed(2)}"),

                  /// TOTAL
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),

                    children: [
                      _tableBold("TOTAL"),

                      _tableBold("£${total.toStringAsFixed(2)}"),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              /// FOOTER
              pw.Center(
                child: pw.Text(
                  "Generated on ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}",

                  style: const pw.TextStyle(color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    /// DOWNLOAD / PRINT

    final bytes = await pdf.save();

    /// SAFE FILE NAME
    final safeName = employeeName
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final safeEmpId = employeeId
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');

    final fileName = '${safeName}_${safeEmpId}_$timestamp.pdf';

    final blob = html.Blob([bytes], 'application/pdf');

    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..style.display = 'none'
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// ===================================================
  /// HELPERS
  /// ===================================================

  static pw.Widget _row(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),

      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

        children: [
          pw.Text(title),

          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),

      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.TableRow _tableRow(String title, String amount) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(12), child: pw.Text(title)),

        pw.Padding(
          padding: const pw.EdgeInsets.all(12),

          child: pw.Text(amount),
        ),
      ],
    );
  }

  static pw.Widget _tableBold(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),

      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }
}
