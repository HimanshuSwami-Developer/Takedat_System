import 'dart:typed_data';
import 'dart:html' as html;

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

  /// Master list of companies (kept in one place so the UI and the
  /// service agree on codes/labels).
  static const List<Map<String, String>> companies = [
    {'code': 'valeron_protection_group', 'label': 'Valeron Protection Group'},
    {'code': 'tybar_security', 'label': 'Tybar Security'},
    {'code': 'gough_and_kelly', 'label': 'Gough & Kelly'},
  ];

  static String labelForCode(String? code) {
    return companies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'label': code ?? ''},
    )['label']!;
  }

  /// =====================================================
  /// FETCH ATTENDANCE FOR WEEK
  ///
  /// [companyCode] == null  -> ALL companies (default)
  /// [companyCode] != null  -> only that company's rows
  /// =====================================================
  static Future<List<Map<String, dynamic>>> fetchWeeklyAttendance({
    required DateTime weekStart,
    required DateTime weekEnd,
    String? companyCode, // null = all companies
  }) async {
    var query = supabase
        .from('attendance')
        .select('''
          id,
          user_id,
          mode,
          shift_start,
          shift_end,
          status,
          shift_id,
          users!inner (
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
        .lte('shift_start', weekEnd.toIso8601String());

    // Filter by company only when a specific one is chosen.
    // users!inner above guarantees the join filter actually excludes rows.
    if (companyCode != null) {
      query = query.eq('users.company_code', companyCode);
    }

    final response = await query.order('shift_start', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// =====================================================
  /// GENERATE PDF
  /// =====================================================
  static Future<Uint8List> generateWeeklyRotaPdf({
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<Map<String, dynamic>> records,
    required String payCodeRestriction, // shown in the header line
  }) async {
    final pdf = pw.Document();

    // ── Group by site (shift_name), then sort sites A→Z ──
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final record in records) {
      final siteName = record['shifts']?['shift_name'] ?? 'Unknown Site';
      grouped.putIfAbsent(siteName, () => []).add(record);
    }
    final sortedSites = grouped.keys.toList()..sort();

    // Sort each site's rows by shift_start (defensive; query already orders).
    for (final rows in grouped.values) {
      rows.sort((a, b) {
        final sa = DateTime.tryParse(a['shift_start'] ?? '') ?? DateTime(1900);
        final sb = DateTime.tryParse(b['shift_start'] ?? '') ?? DateTime(1900);
        return sa.compareTo(sb);
      });
    }

    final now = DateTime.now();
    final runDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
    final printedOn =
        '${DateFormat('dd/MM/yyyy').format(now)} at: ${DateFormat('HH:mm:ss').format(now)}';
    final dateRange =
        '${DateFormat('EEE dd MMM yyyy').format(weekStart)} 00:00 and '
        '${DateFormat('EEE dd MMM yyyy').format(weekEnd)} 23:59';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 24),
        header: (context) => _buildHeader(
          runDate: runDate,
          dateRange: dateRange,
          payCodeRestriction: payCodeRestriction,
        ),
        footer: (context) => _buildFooter(context, printedOn),
        build: (context) =>
            _buildBody(grouped, sortedSites),
      ),
    );

    return pdf.save();
  }

  /// =====================================================
  /// HEADER
  /// =====================================================
  static pw.Widget _buildHeader({
    required String runDate,
    required String dateRange,
    required String payCodeRestriction,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Site Schedule',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Report ID : 02-04-01',
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Date Range Report using dates between $dateRange',
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.Text('Run Date : $runDate by Team Leader',
            style: const pw.TextStyle(fontSize: 8)),
        pw.Text(
          'Restrictions :- Employee Pay Code = $payCodeRestriction.',
          style: const pw.TextStyle(fontSize: 8),
        ),
        pw.SizedBox(height: 6),
        pw.Divider(thickness: 0.5, height: 0.5),
        pw.SizedBox(height: 4),
      ],
    );
  }

  /// =====================================================
  /// FOOTER
  /// =====================================================
  static pw.Widget _buildFooter(pw.Context context, String printedOn) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, height: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Timegate Report Number: 02-04-01   Printed on: $printedOn',
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
    List<String> sortedSites,
  ) {
    final List<pw.Widget> widgets = [];

    // Column header row (repeats visually at the top of the content).
    widgets.add(_buildColumnHeader());
    widgets.add(pw.SizedBox(height: 4));

    double grandTotalMinutes = 0;

    for (final siteName in sortedSites) {
      final rows = grouped[siteName]!;

      widgets.add(_buildSiteHeader(siteName));

      double siteMinutes = 0;

      for (final record in rows) {
        final user = record['users'] as Map<String, dynamic>?;
        final payCode = _payCodeToken(user?['company_code']);
        final empName = _formatName(user?['full_name'] ?? '');
        final start = DateTime.tryParse(record['shift_start'] ?? '');
        final end = DateTime.tryParse(record['shift_end'] ?? '');

        final minutes = (start != null && end != null)
            ? end.difference(start).inMinutes.toDouble()
            : 0.0;

        siteMinutes += minutes;
        grandTotalMinutes += minutes;

        widgets.add(_buildDataRow(
          payCode: payCode,
          empName: empName,
          day: start != null ? DateFormat('EEE').format(start) : '',
          schedStart: start != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(start)
              : '',
          schedFinish:
              end != null ? DateFormat('dd/MM/yyyy HH:mm').format(end) : '',
          hours: _minutesToLabel(minutes),
        ));
      }

      widgets.add(_buildSiteTotal(_minutesToLabel(siteMinutes)));
      widgets.add(pw.SizedBox(height: 10));
    }

    // ── Grand total ──
    widgets.add(pw.Divider(thickness: 0.5, height: 0.5));
    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 2, left: 4, right: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Grand Totals :',
                style: pw.TextStyle(
                    fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Text(
              'Scheduled Hours   ${_minutesToLabel(grandTotalMinutes)}',
              style:
                  pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    return widgets;
  }

  /// =====================================================
  /// COLUMN HEADER ROW
  ///  Pay Code | Employee Name | Start | Scheduled Start | Scheduled Finish | Hours
  /// =====================================================
  static pw.Widget _buildColumnHeader() {
    return pw.Container(
      color: PdfColors.grey200,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 3, child: _headerCell('Pay Code')),
          pw.Expanded(flex: 4, child: _headerCell('Employee Name')),
          pw.Expanded(flex: 2, child: _headerCell('Start')),
          pw.Expanded(flex: 3, child: _headerCell('Scheduled Start')),
          pw.Expanded(flex: 3, child: _headerCell('Scheduled Finish')),
          pw.Expanded(flex: 3, child: _headerCell('Hours')),
        ],
      ),
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Text(text,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold));
  }

  /// =====================================================
  /// SITE HEADER
  /// =====================================================
  static pw.Widget _buildSiteHeader(String siteName) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 6, bottom: 2),
      child: pw.Text('Site : $siteName',
          style:
              pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
    );
  }

  /// =====================================================
  /// DATA ROW
  /// =====================================================
  static pw.Widget _buildDataRow({
    required String payCode,
    required String empName,
    required String day,
    required String schedStart,
    required String schedFinish,
    required String hours,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 4),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 3, child: _dataCell(payCode)),
          pw.Expanded(flex: 4, child: _dataCell(empName)),
          pw.Expanded(flex: 2, child: _dataCell(day)),
          pw.Expanded(flex: 3, child: _dataCell(schedStart)),
          pw.Expanded(flex: 3, child: _dataCell(schedFinish)),
          pw.Expanded(flex: 3, child: _dataCell(hours)),
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
      padding: const pw.EdgeInsets.only(top: 3, bottom: 2, left: 4, right: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Site Totals :',
              style:
                  pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.Text('Scheduled Hours   $hours',
              style:
                  pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  /// =====================================================
  /// HELPERS
  /// =====================================================

  /// Timegate prints a 10-char pay-code token (e.g. 4YOUSOLUTI).
  /// Derive it from company_code; falls back to a sane default.
  static String _payCodeToken(String? companyCode) {
    if (companyCode == null || companyCode.isEmpty) return '4YOUSOLUTI';
    final upper = companyCode.replaceAll('_', '').toUpperCase();
    return upper.length >= 10 ? upper.substring(0, 10) : upper;
  }

  /// "Vishesh Vishesh" → "Vishesh (4U) Vishesh"
  static String _formatName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first} (4U) ${parts.last}';
    }
    return fullName;
  }

  /// Minutes → "9 hrs 0 m" / "4 hrs 30 m"
  static String _minutesToLabel(double totalMinutes) {
    final total = totalMinutes.round();
    final hrs = total ~/ 60;
    final mins = total % 60;
    return '$hrs hrs $mins m';
  }

  /// =====================================================
  /// DOWNLOAD
  /// =====================================================
  static void downloadPdf(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}