import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/attendance/widgets/weekly_rota_service.dart';

class WeeklyRotaDownloadButton extends StatefulWidget {
  const WeeklyRotaDownloadButton({super.key});

  @override
  State<WeeklyRotaDownloadButton> createState() =>
      _WeeklyRotaDownloadButtonState();
}

class _WeeklyRotaDownloadButtonState extends State<WeeklyRotaDownloadButton> {
  bool _isGenerating = false;

  DateTimeRange _getWeekRange(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return DateTimeRange(
      start: DateTime(monday.year, monday.month, monday.day),
      end: DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59),
    );
  }

  Future<void> _showWeekPicker() async {
    DateTime selectedDate = DateTime.now();
    DateTimeRange weekRange = _getWeekRange(selectedDate);

    // null = ALL companies (default). A code = that company only.
    String? selectedCompanyCode;

    final result = await showModalBottomSheet<_RotaSelection>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final fmt = DateFormat('EEE, dd MMM');
          final fmtFull = DateFormat('dd MMM yyyy');
          final weekStart = weekRange.start;
          final weekEnd = weekRange.end;
          final days =
              List.generate(7, (i) => weekStart.add(Duration(days: i)));

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle ──
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title row ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.picture_as_pdf_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Rota Report',
                            style: AppTextStyles.label.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        Text('Select the week to export',
                            style: AppTextStyles.small
                                .copyWith(color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Week card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('WC ${fmtFull.format(weekStart)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                          '${fmt.format(weekStart)}  →  ${fmt.format(weekEnd)}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: days.map((day) {
                          final isToday =
                              DateFormat('yyyyMMdd').format(day) ==
                                  DateFormat('yyyyMMdd')
                                      .format(DateTime.now());
                          return Column(
                            children: [
                              Text(DateFormat('E').format(day)[0],
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text('${day.day}',
                                      style: TextStyle(
                                          color: isToday
                                              ? AppColors.primary
                                              : Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Navigation row ──
                Row(
                  children: [
                    _NavBtn(
                      icon: Icons.chevron_left_rounded,
                      label: 'Prev',
                      onTap: () => setSheetState(() {
                        selectedDate =
                            selectedDate.subtract(const Duration(days: 7));
                        weekRange = _getWeekRange(selectedDate);
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            helpText: 'Pick any day in the week',
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                    primary: AppColors.primary),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              selectedDate = picked;
                              weekRange = _getWeekRange(picked);
                            });
                          }
                        },
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text('Pick Date',
                                  style: AppTextStyles.label.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _NavBtn(
                      icon: Icons.chevron_right_rounded,
                      label: 'Next',
                      onTap: () => setSheetState(() {
                        selectedDate =
                            selectedDate.add(const Duration(days: 7));
                        weekRange = _getWeekRange(selectedDate);
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Company selector ──────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Company',
                    style: AppTextStyles.small.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: selectedCompanyCode,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary),
                      borderRadius: BorderRadius.circular(12),
                      style: AppTextStyles.label.copyWith(
                          color: Colors.black87, fontSize: 14),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.apartment_rounded,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              const Text('All companies'),
                            ],
                          ),
                        ),
                        ...WeeklyRotaPdfService.companies.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c['code'],
                            child: Row(
                              children: [
                                Icon(Icons.business_rounded,
                                    size: 18, color: Colors.grey.shade500),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    c['label']!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          setSheetState(() => selectedCompanyCode = val),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Action buttons ──
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Text('Cancel',
                                style: AppTextStyles.label
                                    .copyWith(color: Colors.black54)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(
                          ctx,
                          _RotaSelection(
                            range: weekRange,
                            companyCode: selectedCompanyCode,
                          ),
                        ),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download_rounded,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Download PDF',
                                  style: AppTextStyles.label.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    if (result != null) {
      await _generateAndDownload(result.range, result.companyCode);
    }
  }

  Future<void> _generateAndDownload(
    DateTimeRange weekRange,
    String? companyCode,
  ) async {
    setState(() => _isGenerating = true);

    try {
      final records = await WeeklyRotaPdfService.fetchWeeklyAttendance(
        weekStart: weekRange.start,
        weekEnd: weekRange.end,
        companyCode: companyCode, // null => all
      );

      if (records.isEmpty) {
        if (!mounted) return;
        _snack(
          companyCode == null
              ? 'No attendance records found for this week.'
              : 'No records for ${WeeklyRotaPdfService.labelForCode(companyCode)} this week.',
          Colors.orange.shade600,
        );
        return;
      }

      // Header restriction line: specific pay code, or "all" when unfiltered.
      final payCodeRestriction = companyCode == null
          ? 'all'
          : companyCode.toLowerCase();

      final pdfBytes = await WeeklyRotaPdfService.generateWeeklyRotaPdf(
        weekStart: weekRange.start,
        weekEnd: weekRange.end,
        records: records,
        payCodeRestriction: payCodeRestriction,
      );

      final companyTag = companyCode == null
          ? 'All'
          : companyCode
              .split('_')
              .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
              .join('');
      final filename =
          'Weekly_Rota_${companyTag}_WC_${DateFormat('dd_MMM_yyyy').format(weekRange.start)}.pdf';

      WeeklyRotaPdfService.downloadPdf(pdfBytes, filename);

      if (!mounted) return;
      _snack('Downloaded: $filename', Colors.green.shade600,
          leading: Icons.check_circle);
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e', Colors.red.shade600);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _snack(String msg, Color bg, {IconData? leading}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (leading != null) ...[
              Icon(leading, color: Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isGenerating ? null : _showWeekPicker,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: _isGenerating
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.picture_as_pdf_rounded),
      label: Text(_isGenerating ? 'Generating...' : 'Weekly Rota',
          style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

/// Result payload returned from the bottom sheet.
class _RotaSelection {
  final DateTimeRange range;
  final String? companyCode; // null = all
  const _RotaSelection({required this.range, required this.companyCode});
}

// ── Nav button widget ──
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}