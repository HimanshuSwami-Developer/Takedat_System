import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/models/shift_model.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_date_picker.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_dropdown.dart';
import 'package:takedat_app/screens/attendance/widgets/search_employee.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';

class AddAttendanceShiftSheet extends StatefulWidget {
  final Map<String, dynamic>? attendance;
  final List<ShiftModel> shifts;
  final Function(Map<String, dynamic>) onSave;

  const AddAttendanceShiftSheet({
    super.key,
    this.attendance,
    required this.shifts,
    required this.onSave,
  });

  @override
  State<AddAttendanceShiftSheet> createState() =>
      _AddAttendanceShiftSheetState();
}

class _AddAttendanceShiftSheetState extends State<AddAttendanceShiftSheet> {
  EmployeeSearchModel? _selectedEmployee;
  String trackingMode = "Static";
  String? selectedShift;
  String attendanceStatus = "Present";
  DateTime? startDate;
  DateTime? endDate;

  bool get isEditing => widget.attendance != null;

  @override
  void initState() {
    super.initState();
    final att = widget.attendance;

    if (att != null) {
      trackingMode = _capitalise(att["mode"]?.toString() ?? "Static");
      selectedShift = att["shift"];

      if (selectedShift == null) {
        final available = _shiftsForMode(trackingMode);
        selectedShift =
            available.isNotEmpty ? available.first.shiftName : null;
      }

      attendanceStatus = _capitalise(att["status"]?.toString() ?? "Present");

      // ── Parse dates ──────────────────────────────────────────
      // Priority 1: dedicated DateTime / ISO fields saved on last edit
      // Priority 2: split from the card "time" display string
      //             format → "15 May 2026 9:00 AM - 16 May 2026 9:00 AM"
      startDate = _parseDate(att["shiftStart"]);
      endDate   = _parseDate(att["shiftEnd"]);

      if (startDate == null || endDate == null) {
        final parsed = _parseDateRangeString(att["time"]?.toString());
        startDate ??= parsed.$1;
        endDate   ??= parsed.$2;
      }

      // ── Employee ─────────────────────────────────────────────
      final String? empId   =
          att["userId"]?.toString() ?? att["empId"]?.toString();
      final String? empName = att["name"]?.toString();

      if (empId != null && empName != null) {
        _selectedEmployee = EmployeeSearchModel(id: empId, name: empName);
      }
    } else {
      final available = _shiftsForMode(trackingMode);
      selectedShift =
          available.isNotEmpty ? available.first.shiftName : null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  List<ShiftModel> _shiftsForMode(String mode) => widget.shifts
      .where((s) => s.shiftType.toLowerCase() == mode.toLowerCase())
      .toList();

  String _capitalise(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  /// Parses a single date value — handles:
  ///   • DateTime object
  ///   • ISO string   "2026-05-15T09:00:00"
  ///   • Card format  "15 May 2026 9:00 AM"
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    // ISO
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {}

    // Card display formats
    for (final fmt in [
      'dd MMM yyyy h:mm a',
      'dd MMM yyyy hh:mm a',
      'd MMM yyyy h:mm a',
      'd MMM yyyy hh:mm a',
    ]) {
      try {
        return DateFormat(fmt).parseLoose(raw).toLocal();
      } catch (_) {}
    }

    return null;
  }

  /// Splits "15 May 2026 9:00 AM - 16 May 2026 9:00 AM" → (start, end)
  (DateTime?, DateTime?) _parseDateRangeString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return (null, null);
    final parts = raw.split(' - ');
    if (parts.length != 2) return (null, null);
    return (_parseDate(parts[0].trim()), _parseDate(parts[1].trim()));
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Wrap(
          children: [
            // ── Handle ────────────────────────────────────────
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Header ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? "Edit Attendance" : "Add Attendance",
                  style: AppTextStyles.label
                      .copyWith(fontSize: 18, color: Colors.black),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Employee Search ───────────────────────────────
            EmployeeSearchField(
              label: "Employee",
              hint: "Search employee...",
              initialValue: _selectedEmployee,
              onSelected: (emp) => setState(() => _selectedEmployee = emp),
            ),

            const SizedBox(height: 14),

            // ── Tracking Mode ─────────────────────────────────
            CustomDropdown<String>(
              label: "Tracking Mode",
              hint: "Select Tracking Mode",
              icon: Icons.track_changes,
              value: trackingMode,
              items: const ["Static", "Event"],
              onChanged: (value) {
                final mode = value!;
                final filtered = _shiftsForMode(mode);
                setState(() {
                  trackingMode = mode;
                  selectedShift = filtered.isNotEmpty
                      ? filtered.first.shiftName
                      : null;
                });
              },
            ),

            const SizedBox(height: 14),

            // ── Shift Name ────────────────────────────────────
            CustomDropdown<String>(
              label: "Shift Name",
              hint: "Select Shift",
              icon: Icons.schedule,
              value: selectedShift,
              items: _shiftsForMode(trackingMode)
                  .map((e) => e.shiftName)
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedShift = value!),
            ),

            const SizedBox(height: 14),

            // ── Shift Start (pre-filled) ──────────────────────
            CustomDateField(
              label: "Shift Start",
              hint: "Select start date",
              icon: Icons.calendar_today,
              showTime: true,
              initialDate: startDate,     // ✅ parsed from time string
              onDateSelected: (date) => setState(() => startDate = date),
            ),

            const SizedBox(height: 14),

            // ── Shift End (pre-filled) ────────────────────────
            CustomDateField(
              label: "Shift End",
              hint: "Select end date",
              icon: Icons.calendar_today,
              showTime: true,
              initialDate: endDate,       // ✅ parsed from time string
              onDateSelected: (date) => setState(() => endDate = date),
            ),

            const SizedBox(height: 14),

            // ── Attendance Status ─────────────────────────────
            CustomDropdown<String>(
              label: "Attendance Status",
              hint: "Select Status",
              icon: Icons.check_circle,
              value: attendanceStatus,
              items: const ["Present", "Absent"],
              onChanged: (value) =>
                  setState(() => attendanceStatus = value!),
            ),

            const SizedBox(height: 24),

            // ── Validation hint ───────────────────────────────
            if (_selectedEmployee == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      "Please select an employee to continue",
                      style: AppTextStyles.small
                          .copyWith(color: Colors.orange),
                    ),
                  ],
                ),
              ),

            // ── Save / Update ─────────────────────────────────
            CustomButton(
              text: isEditing ? "Update Attendance" : "Save Attendance",
              icon: Icons.save,
              onTap: () {
                if (_selectedEmployee == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please select an employee"),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                if (startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please select shift start and end time"),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                final shift = widget.shifts.firstWhere(
                  (s) => s.shiftName == selectedShift,
                  orElse: () => widget.shifts.first,
                );

                // Rebuild "time" display string so the card stays in sync
                final fmt = DateFormat('dd MMM yyyy h:mm a');
                final timeString =
                    "${fmt.format(startDate!)} - ${fmt.format(endDate!)}";

                final data = {
                  "userId":     _selectedEmployee!.id,
                  "name":       _selectedEmployee!.name,
                  "initials":   _selectedEmployee!.name
                      .trim()
                      .split(' ')
                      .where((e) => e.isNotEmpty)
                      .take(2)
                      .map((e) => e[0].toUpperCase())
                      .join(),
                  "mode":       trackingMode.toLowerCase(),
                  "shiftId":    shift.id,
                  "shift":      shift.shiftName,
                  "shiftStart": startDate,   // DateTime → for next edit
                  "shiftEnd":   endDate,     // DateTime → for next edit
                  "time":       timeString,  // string → card display
                  "status":     attendanceStatus.toLowerCase(),
                };

                widget.onSave(data);
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}