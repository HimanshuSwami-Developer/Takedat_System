import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/models/shift_model.dart';
import 'package:takedat_app/screens/attendance/widgets/manage_attendance.dart';

class AttendanceCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<ShiftModel> shifts;

  /// Called after user confirms delete — pass the attendance id up
  final VoidCallback? onDelete;

  /// Called after user saves updated data — pass updated map up
  final Function(Map<String, dynamic>)? onUpdate;

  const AttendanceCard({
    super.key,
    required this.item,
    required this.shifts,
    this.onDelete,
    this.onUpdate,
  });

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  bool isExpanded = false;

  // ─────────────────────────────────────────────────────────────
  // DELETE — show confirmation dialog, then fire callback
  // ─────────────────────────────────────────────────────────────
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ──────────────────────────────────────
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Title ─────────────────────────────────────
                Text(
                  "Delete Attendance?",
                  style: AppTextStyles.headline.copyWith(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                // ── Message ───────────────────────────────────
                Text(
                  "Are you sure you want to delete the attendance record for ${widget.item["name"] ?? "this employee"}? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Buttons ───────────────────────────────────
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          "Cancel",
                          style: AppTextStyles.label.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Delete
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "Delete",
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      widget.onDelete?.call();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // EDIT — open bottom sheet with pre-filled data
  // ─────────────────────────────────────────────────────────────
  void _openEdit() {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AddAttendanceShiftSheet(
          attendance: widget.item,
          shifts: widget.shifts,
          onSave: (updatedData) {
            widget.onUpdate?.call(updatedData);
            setState(() {});
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final String status = item["status"]?.toString() ?? "Absent";
    final bool isPresent = status.toLowerCase() == "present";

    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row ───────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      isPresent ? Colors.green.shade100 : Colors.red.shade100,
                  child: Text(
                    item["initials"] ?? "--",
                    style: TextStyle(
                      color: isPresent ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"] ?? "--",
                        style: AppTextStyles.label.copyWith(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Text("${item["empId"] ?? "--"}", style: AppTextStyles.small),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPresent
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item["status"]?.toString().toUpperCase() ?? "ABSENT",
                    style: TextStyle(
                      color: isPresent ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // ── Expandable ────────────────────────────────────
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
                      _infoText("Mode", item["mode"] ?? "--"),
                      _infoText("Shift", item["shift"] ?? "--"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item["time"] ?? "--",
                          style: AppTextStyles.small
                              .copyWith(color: Colors.black54),
                        ),
                      ),

                      // ── Action buttons ──────────────────────
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _openEdit,
                            child: _actionIcon(Icons.edit, Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _confirmDelete,
                            child: _actionIcon(Icons.delete, Colors.red),
                          ),
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

  Widget _infoText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.small.copyWith(color: Colors.grey)),
        Text(
          value,
          style: AppTextStyles.label.copyWith(color: Colors.black, fontSize: 13),
        ),
      ],
    );
  }

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