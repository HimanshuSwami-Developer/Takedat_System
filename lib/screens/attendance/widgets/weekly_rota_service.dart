import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';

/// =====================================================
/// WEEKLY ROTA PDF SERVICE
/// Matches exact format of Timegate 02-04-01 report
/// =====================================================

class WeeklyRotaPdfService {
  static final supabase = Supabase.instance.client;

  /// =====================================================
  /// FETCH ATTENDANCE FOR WEEK
  /// =====================================================
  static Future<List<Map<String, dynamic>>> fetchWeeklyAttendance({
    required DateTime weekStart,
    required DateTime weekEnd,
  }) async {
    final response = await supabase
      .from('attendance')
      .select('''
        id,
        user_id,
        mode,
        shift_start,
        shift_end,
        status,
        shift_id,
        users (
          id,
          full_name,
          emp_id,
          email,
          phone,
          company_code
        ),
        shifts (
          id,
          shift_name
        )
      ''')
      .gte('shift_start', weekStart.toIso8601String())
      .lte('shift_start', weekEnd.toIso8601String())
      .order('shift_start', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// =====================================================
  /// GENERATE PDF
  /// =====================================================
  static Future<Uint8List> generateWeeklyRotaPdf({
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<Map<String, dynamic>> records,
    required String companyName,
  }) async {
    final pdf = pw.Document();

    // ── Group by site (shift_name) ──────────────────────
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final record in records) {
      final siteName = record['shifts']?['shift_name'] ?? 'Unknown Site';
      grouped.putIfAbsent(siteName, () => []).add(record);
    }

    final runDate   = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final dateRange =
        '${DateFormat('EEE dd MMM yyyy').format(weekStart)} 00:00 and '
        '${DateFormat('EEE dd MMM yyyy').format(weekEnd)} 23:59';

    final totalPages = 1; // will be set by pdf package

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _buildHeader(
          context:     context,
          runDate:     runDate,
          dateRange:   dateRange,
          companyName: companyName,
        ),
        footer: (context) => _buildFooter(context, runDate),
        build: (context) => _buildBody(grouped, weekStart, weekEnd),
      ),
    );

    return pdf.save();
  }

  /// =====================================================
  /// HEADER
  /// =====================================================
  static pw.Widget _buildHeader(
  {
    required pw.Context context,
    required String runDate,
    required String dateRange,
    required String companyName,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Site Schedule',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Report ID : 02-04-01',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Date Range Report using dates between $dateRange',
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Run Date : $runDate by Team Leader',
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.Text(
          'Restrictions :- Employee Pay Code = ${companyName.toLowerCase()}.',
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 4),
      ],
    );
  }

  /// =====================================================
  /// FOOTER
  /// =====================================================
  static pw.Widget _buildFooter(pw.Context context, String runDate) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Timegate Report Number: 02-04-01   Printed on: $runDate',
              style: const pw.TextStyle(fontSize: 7),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ],
        ),
      ],
    );
  }

  /// =====================================================
  /// BODY
  /// =====================================================
  static List<pw.Widget> _buildBody(
    Map<String, List<Map<String, dynamic>>> grouped,
    DateTime weekStart,
    DateTime weekEnd,
  ) {
    final List<pw.Widget> widgets = [];

    // ── Column headers ──────────────────────────────────
    widgets.add(_buildColumnHeader());
    widgets.add(pw.SizedBox(height: 6));

    double grandTotal = 0;

    for (final entry in grouped.entries) {
      final siteName = entry.key;
      final rows     = entry.value;

      // ── Site header ───────────────────────────────────
      widgets.add(_buildSiteHeader(siteName));

      double siteTotal = 0;

      // ── Rows ──────────────────────────────────────────
      for (final record in rows) {
        final user      = record['users'] as Map<String, dynamic>?;
        final payCode   = user?['company_code'] ?? '4YOUSOLUTI';
        final empName   = _formatName(user?['full_name'] ?? '');
        final start     = DateTime.tryParse(record['shift_start'] ?? '');
        final end       = DateTime.tryParse(record['shift_end']   ?? '');
        final hours     = start != null && end != null
            ? end.difference(start).inMinutes / 60
            : 0.0;
        final hrsLabel  = _formatHours(start, end);

        siteTotal  += hours;
        grandTotal += hours;

        widgets.add(_buildDataRow(
          payCode:  payCode,
          empName:  empName,
          day:      start != null ? DateFormat('EEE').format(start) : '',
          date:     start != null ? DateFormat('dd/MM/yyyy').format(start) : '',
          startTime: start != null ? DateFormat('HH:mm').format(start) : '',
          endDate:  end   != null ? DateFormat('dd/MM/yyyy').format(end)  : '',
          endTime:  end   != null ? DateFormat('HH:mm').format(end)       : '',
          hours:    hrsLabel,
        ));
      }

      // ── Site total ────────────────────────────────────
      widgets.add(_buildSiteTotal(_formatHoursFromDouble(siteTotal)));
      widgets.add(pw.SizedBox(height: 10));
    }

    // ── Grand total ────────────────────────────────────
    widgets.add(pw.Divider(thickness: 0.5));
    widgets.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Grand Totals :',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Scheduled Hours   ${_formatHoursFromDouble(grandTotal)}',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return widgets;
  }

  /// =====================================================
  /// COLUMN HEADER ROW
  /// =====================================================
  static pw.Widget _buildColumnHeader() {
    return pw.Container(
      color: PdfColors.grey200,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 2, child: _headerCell('Pay Code')),
          pw.Expanded(flex: 3, child: _headerCell('Employee Name')),
          pw.Expanded(flex: 2, child: _headerCell('Start')),
          pw.Expanded(flex: 2, child: _headerCell('Scheduled Start')),
          pw.Expanded(flex: 2, child: _headerCell('Scheduled Finish')),
          pw.Expanded(flex: 2, child: _headerCell('Hours')),
          pw.Expanded(flex: 1, child: _headerCell('Day')),
        ],
      ),
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  /// =====================================================
  /// SITE HEADER
  /// =====================================================
  static pw.Widget _buildSiteHeader(String siteName) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 6, bottom: 2),
      child: pw.Text(
        'Site : $siteName',
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  /// =====================================================
  /// DATA ROW
  /// =====================================================
  static pw.Widget _buildDataRow({
    required String payCode,
    required String empName,
    required String day,
    required String date,
    required String startTime,
    required String endDate,
    required String endTime,
    required String hours,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 2, child: _dataCell(payCode)),
          pw.Expanded(flex: 3, child: _dataCell(empName)),
          pw.Expanded(flex: 2, child: _dataCell(day)),
          pw.Expanded(flex: 2, child: _dataCell('$date $startTime')),
          pw.Expanded(flex: 2, child: _dataCell('$endDate $endTime')),
          pw.Expanded(flex: 2, child: _dataCell(hours)),
          pw.Expanded(flex: 1, child: _dataCell('')),
        ],
      ),
    );
  }

  static pw.Widget _dataCell(String text) {
    return pw.Text(text, style: const pw.TextStyle(fontSize: 8));
  }

  /// =====================================================
  /// SITE TOTAL ROW
  /// =====================================================
  static pw.Widget _buildSiteTotal(String hours) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 2, left: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Site Totals :',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Scheduled Hours   $hours',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// =====================================================
  /// HELPERS
  /// =====================================================
  static String _formatName(String fullName) {
    // "Vishesh Vishesh" → "Vishesh (4U) Vishesh"
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first} (4U) ${parts.last}';
    }
    return fullName;
  }

  static String _formatHours(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '—';
    final diff  = end.difference(start);
    final hrs   = diff.inHours;
    final mins  = diff.inMinutes % 60;
    if (mins == 0) return '$hrs hrs 0 m';
    return '$hrs hrs $mins m';
  }

  static String _formatHoursFromDouble(double total) {
    final hrs  = total.toInt();
    final mins = ((total - hrs) * 60).round();
    if (mins == 0) return '$hrs hrs 0 m';
    return '$hrs hrs $mins m';
  }

  /// =====================================================
  /// DOWNLOAD
  /// =====================================================
  static void downloadPdf(Uint8List bytes, String filename) {
    final blob   = html.Blob([bytes], 'application/pdf');
    final url    = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}