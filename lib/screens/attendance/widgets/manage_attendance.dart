import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/attendance/ui/attendance_screen.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_date_picker.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_dropdown.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';

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
  late TextEditingController employeeController;

  String trackingMode = "Static";

  String? selectedShift;

  String attendanceStatus = "Present";

  DateTime? startDate;

  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    employeeController = TextEditingController(
      text: widget.attendance?["name"] ?? "",
    );

    trackingMode = widget.attendance?["mode"] ?? "Static";

    final availableShifts = widget.shifts
        .where(
          (shift) => shift.mode.toLowerCase() == trackingMode.toLowerCase(),
        )
        .toList();

    selectedShift =
        widget.attendance?["shift"] ??
        (availableShifts.isNotEmpty ? availableShifts.first.name : null);

    attendanceStatus = widget.attendance?["status"] ?? "Present";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),

          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),

        child: Wrap(
          children: [
            /// HANDLE
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

            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  widget.attendance == null
                      ? "Add Attendance"
                      : "Edit Attendance",

                  style: AppTextStyles.label.copyWith(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),

                IconButton(
                  onPressed: () => Navigator.pop(context),

                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// EMPLOYEE SEARCH
            CustomTextField(
              controller: employeeController,

              hint: "Search employee",

              label: "Employee",

              icon: Icons.search,
            ),

            const SizedBox(height: 14),

            /// TRACKING MODE
            CustomDropdown<String>(
              label: "Tracking Mode",

              hint: "Select Tracking Mode",

              icon: Icons.track_changes,

              value: trackingMode,

              items: const ["Static", "Event"],

              onChanged: (value) {
                final mode = value!;

                /// FILTER SHIFTS
                final filteredShifts = widget.shifts
                    .where(
                      (shift) => shift.mode.toLowerCase() == mode.toLowerCase(),
                    )
                    .toList();

                setState(() {
                  trackingMode = mode;

                  /// AUTO SELECT FIRST SHIFT
                  selectedShift = filteredShifts.isNotEmpty
                      ? filteredShifts.first.name
                      : null;
                });
              },
            ),

            const SizedBox(height: 14),

            /// SHIFT NAME
            CustomDropdown<String>(
              label: "Shift Name",

              hint: "Select Shift",

              icon: Icons.schedule,

              value: selectedShift,

              items: widget.shifts
                  .where(
                    (shift) =>
                        shift.mode.toLowerCase() == trackingMode.toLowerCase(),
                  )
                  .map((e) => e.name)
                  .toList(),

              onChanged: (value) {
                setState(() {
                  selectedShift = value!;
                });
              },
            ),

            const SizedBox(height: 14),

            /// START DATE
            CustomDateField(
              label: "Shift Start",

              hint: "Select start date",

              icon: Icons.calendar_today,
              showTime: true,
              onDateSelected: (date) {
                setState(() {
                  startDate = date;
                });
              },
            ),

            const SizedBox(height: 14),

            /// END DATE
            CustomDateField(
              label: "Shift End",

              hint: "Select end date",
              showTime: true,
              icon: Icons.calendar_today,

              onDateSelected: (date) {
                setState(() {
                  endDate = date;
                });
              },
            ),

            const SizedBox(height: 14),

            /// ATTENDANCE STATUS
            CustomDropdown<String>(
              label: "Attendance Status",

              hint: "Select Status",

              icon: Icons.check_circle,

              value: attendanceStatus,

              items: const ["Present", "Absent"],

              onChanged: (value) {
                setState(() {
                  attendanceStatus = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            /// SAVE
            CustomButton(
              text: widget.attendance == null
                  ? "Save Attendance"
                  : "Update Attendance",

              icon: Icons.save,

              onTap: () {
                final data = {
                  "name": employeeController.text.trim(),

                  "empId":
                      widget.attendance?["empId"] ??
                      "EMP-${DateTime.now().millisecondsSinceEpoch}",

                  "initials": employeeController.text
                      .trim()
                      .split(" ")
                      .where((e) => e.isNotEmpty)
                      .map((e) => e[0])
                      .take(2)
                      .join(),

                  "mode": trackingMode,

                  "shift": selectedShift ?? "--",

                  "status": attendanceStatus,

                  "time":
                      "${startDate != null ? startDate.toString().split(' ')[0] : '--'}"
                      " - "
                      "${endDate != null ? endDate.toString().split(' ')[0] : '--'}",
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
