import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/attendance/ui/attendance_screen.dart';
import 'package:takedat_app/screens/attendance/widgets/manage_attendance.dart';

class AttendanceCard extends StatefulWidget {
  final Map<String, dynamic> item;

  const AttendanceCard({super.key, required this.item});

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final String status = item["status"]?.toString() ?? "Absent";

    final bool isPresent = status == "Present";

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 TOP ROW
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isPresent
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Text(
                    item["initials"],
                    style: TextStyle(
                      color: isPresent ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// NAME + ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        style: AppTextStyles.label.copyWith(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Text(item["empId"], style: AppTextStyles.small),
                    ],
                  ),
                ),

                /// STATUS CHIP
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPresent
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item["status"].toUpperCase(),
                    style: TextStyle(
                      color: isPresent ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            /// 🔥 EXPANDABLE PART
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(),
              secondChild: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoText("Mode", item["mode"]),
                      _infoText("Shift", item["shift"]),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item["time"],
                        style: AppTextStyles.small.copyWith(
                          color: Colors.black54,
                        ),
                      ),

                      /// ACTIONS
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                useRootNavigator: true,
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) {
                                  return AddAttendanceShiftSheet(
                                    attendance: item,

                                    shifts: shifts,

                                    onSave: (updatedData) {
                                      item.clear();
                                      item.addAll(updatedData);
                                      setState(() {});
                                    },
                                  );
                                },
                              );
                            },
                            child: _actionIcon(Icons.edit, Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          _actionIcon(Icons.delete, Colors.red),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 INFO TEXT
  Widget _infoText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.small.copyWith(color: Colors.grey)),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            color: Colors.black,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  /// 🔹 ACTION ICON
  Widget _actionIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
