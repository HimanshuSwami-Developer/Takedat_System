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

class _WeeklyRotaDownloadButtonState
    extends State<WeeklyRotaDownloadButton> {

  bool _isGenerating = false;

  DateTimeRange _getWeekRange(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return DateTimeRange(
      start: DateTime(monday.year, monday.month, monday.day),
      end:   DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59),
    );
  }

  Future<void> _showWeekPicker() async {
    DateTime selectedDate = DateTime.now();
    DateTimeRange weekRange = _getWeekRange(selectedDate);

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {

          final fmt      = DateFormat('EEE, dd MMM');
          final fmtFull  = DateFormat('dd MMM yyyy');
          final weekStart = weekRange.start;
          final weekEnd   = weekRange.end;

          // Days of week for mini display
          final days = List.generate(7, (i) =>
            weekStart.add(Duration(days: i)));

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Handle ───────────────────────────
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

                // ── Title row ─────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Rota Report',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Select the week to export',
                          style: AppTextStyles.small.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Week card ─────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
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
                      // WC label
                      Text(
                        'WC ${fmtFull.format(weekStart)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fmt.format(weekStart)}  →  ${fmt.format(weekEnd)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Days strip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: days.map((day) {
                          final isToday = DateFormat('yyyyMMdd').format(day) ==
                              DateFormat('yyyyMMdd').format(DateTime.now());
                          return Column(
                            children: [
                              Text(
                                DateFormat('E').format(day)[0],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: isToday
                                          ? AppColors.primary
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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

                // ── Navigation row ────────────────────
                Row(
                  children: [

                    // Prev week
                    _NavBtn(
                      icon: Icons.chevron_left_rounded,
                      label: 'Prev',
                      onTap: () => setSheetState(() {
                        selectedDate = selectedDate
                            .subtract(const Duration(days: 7));
                        weekRange = _getWeekRange(selectedDate);
                      }),
                    ),

                    const SizedBox(width: 10),

                    // Pick date
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
                                  primary: AppColors.primary,
                                ),
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
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pick Date',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Next week
                    _NavBtn(
                      icon: Icons.chevron_right_rounded,
                      label: 'Next',
                      onTap: () => setSheetState(() {
                        selectedDate = selectedDate
                            .add(const Duration(days: 7));
                        weekRange = _getWeekRange(selectedDate);
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Action buttons ────────────────────
                Row(
                  children: [

                    // Cancel
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, false),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.label.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Download
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, true),
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
                              const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Download PDF',
                                style: AppTextStyles.label.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

    if (confirmed == true) {
      await _generateAndDownload(weekRange);
    }
  }

  Future<void> _generateAndDownload(DateTimeRange weekRange) async {
    setState(() => _isGenerating = true);

    try {
      final records = await WeeklyRotaPdfService.fetchWeeklyAttendance(
        weekStart: weekRange.start,
        weekEnd:   weekRange.end,
      );

      if (records.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No attendance records found for this week.'),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      final pdfBytes = await WeeklyRotaPdfService.generateWeeklyRotaPdf(
        weekStart:   weekRange.start,
        weekEnd:     weekRange.end,
        records:     records,
        companyName: '4YOUSOLUTIONS',
      );

      final filename =
          'Weekly_Rota_WC_${DateFormat('dd_MMM_yyyy').format(weekRange.start)}.pdf';
      WeeklyRotaPdfService.downloadPdf(pdfBytes, filename);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Downloaded: $filename'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isGenerating ? null : _showWeekPicker,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: _isGenerating
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.picture_as_pdf_rounded),
      label: Text(
        _isGenerating ? 'Generating...' : 'Weekly Rota',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Nav button widget ─────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}