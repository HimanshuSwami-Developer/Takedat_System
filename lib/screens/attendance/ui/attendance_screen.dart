import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/attendance/widgets/attendance_cards.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_date_picker.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_dropdown.dart';
import 'package:takedat_app/screens/attendance/widgets/manage_attendance.dart';
import 'package:takedat_app/screens/attendance/widgets/manage_shift.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_outlined_button.dart';

final List<Map<String, dynamic>> attendanceData = [
  {
    "name": "John Doe",
    "empId": "EMP-0842",
    "mode": "Static",
    "shift": "Morning Ops",
    "time": "08:00 AM - 05:00 PM",
    "status": "Present",
    "initials": "JD",
  },
  {
    "name": "Sarah Williams",
    "empId": "EMP-1159",
    "mode": "Event",
    "shift": "Night Watch",
    "time": "09:00 PM - 06:00 AM",
    "status": "Absent",
    "initials": "SW",
  },
];

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            /// 🔹 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Attendance",
                  style: AppTextStyles.headline.copyWith(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _openFilterSheet(context),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 🔹 ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Export",
                    icon: Icons.download,
                    isFullWidth: false,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: CustomButton(
                    text: "Create",
                    icon: Icons.add,
                    isFullWidth: false,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) {
                          return AddAttendanceShiftSheet(
                            shifts: shifts,

                            onSave: (data) {
                              attendanceData.add(data);

                              setState(() {});
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: CustomButton(
                    text: "Add Shift",
                    icon: Icons.schedule,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) {
                          return ManageShiftSheet(shifts: shifts);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          SizedBox(height: 12,),
            /// LIST
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  children: attendanceData.map((item) {
                    return AttendanceCard(item: item);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================
  /// 🔹 FILTER SHEET
  /// ============================

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 0.55,
          minChildSize: 0.55,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  /// 🔹 DRAG HANDLE
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Filter Attendance",
                            style: AppTextStyles.label.copyWith(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Refine your search results",
                            style: AppTextStyles.small.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// 🔹 FORM (SCROLLABLE)
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        CustomDateField(
                          label: "Start Shift",
                          hint: "Select start date",
                          icon: Icons.calendar_today,
                        ),

                        CustomDateField(
                          label: "End Shift",
                          hint: "Select end date",
                          icon: Icons.calendar_today,
                        ),

                        CustomDropdown<String>(
                          label: "Status",
                          hint: "Select status",
                          icon: Icons.filter_alt,
                          items: ["Present", "Absent"],
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  /// 🔹 ACTIONS (STICKY)
                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlinedButton(
                          text: "Reset",

                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: "Apply Filter",
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

final List<ShiftModel> shifts = [
  ShiftModel(name: "Morning Shift", mode: "Static"),
  ShiftModel(name: "Night Event", mode: "Event"),
];

class ShiftModel {
  String name;
  String mode;

  ShiftModel({required this.name, required this.mode});
}
