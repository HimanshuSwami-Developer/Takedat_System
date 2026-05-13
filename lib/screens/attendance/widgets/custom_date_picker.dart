import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_outlined_button.dart';

class CustomDateField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? icon;

  final Function(DateTime)? onDateSelected;

  /// ✅ SHOW TIME PICKER FLAG
  final bool showTime;

  const CustomDateField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.onDateSelected,
    this.showTime = false,
  });

  @override
  State<CustomDateField> createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  DateTime? selectedDate;

  Future<void> _pickDate() async {
    final today = DateTime.now();

    final todayNormalized = DateTime(today.year, today.month, today.day);

    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,

      builder: (_) {
        DateTime currentMonth = DateTime(today.year, today.month, 1);

        DateTime? tempDate = selectedDate ?? todayNormalized;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final daysInMonth = DateTime(
              currentMonth.year,
              currentMonth.month + 1,
              0,
            ).day;

            final firstWeekday = DateTime(
              currentMonth.year,
              currentMonth.month,
              1,
            ).weekday;

            final offset = firstWeekday % 7;

            final totalCells = offset + daysInMonth;

            return Container(
              padding: const EdgeInsets.only(
                top: 8,
                left: 16,
                right: 16,
                bottom: 32,
              ),

              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),

                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  /// HANDLE
                  Container(
                    width: 40,
                    height: 4,

                    margin: const EdgeInsets.only(bottom: 16),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,

                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),

                  /// MONTH NAVIGATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      _NavButton(
                        icon: Icons.chevron_left,

                        onTap: () {
                          setModalState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month - 1,
                            );
                          });
                        },
                      ),

                      Text(
                        DateFormat('MMMM yyyy').format(currentMonth),

                        style: AppTextStyles.label.copyWith(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),

                      _NavButton(
                        icon: Icons.chevron_right,

                        onTap: () {
                          setModalState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// WEEK DAYS
                  Row(
                    children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                        .map(
                          (e) => Expanded(
                            child: Center(
                              child: Text(
                                e,

                                style: AppTextStyles.small.copyWith(
                                  fontSize: 11,
                                  color: Colors.grey,

                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 8),

                  /// CALENDAR GRID
                  GridView.builder(
                    shrinkWrap: true,

                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: totalCells,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),

                    itemBuilder: (_, index) {
                      if (index < offset) {
                        return const SizedBox.shrink();
                      }

                      final day = index - offset + 1;

                      final date = DateTime(
                        currentMonth.year,
                        currentMonth.month,
                        day,
                      );

                      final isToday =
                          date.year == todayNormalized.year &&
                          date.month == todayNormalized.month &&
                          date.day == todayNormalized.day;

                      final isSelected =
                          tempDate != null &&
                          date.year == tempDate!.year &&
                          date.month == tempDate!.month &&
                          date.day == tempDate!.day;

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            tempDate = date;
                          });
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),

                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,

                            borderRadius: BorderRadius.circular(8),

                            border: isToday && !isSelected
                                ? Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  )
                                : null,
                          ),

                          child: Stack(
                            alignment: Alignment.center,

                            children: [
                              Text(
                                '$day',

                                style: TextStyle(
                                  fontSize: 13,

                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,

                                  fontWeight: isToday || isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),

                              if (isToday && !isSelected)
                                Positioned(
                                  bottom: 4,

                                  child: Container(
                                    width: 4,
                                    height: 4,

                                    decoration: BoxDecoration(
                                      color: AppColors.primary,

                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 4),

                  Divider(color: Colors.grey.shade200, height: 24),

                  /// ACTIONS
                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlinedButton(
                          text: "Cancel",

                          onTap: () {
                            context.pop();
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: CustomButton(
                          text: "Apply",

                          onTap: () async {
                            if (tempDate != null) {
                              DateTime finalDate = tempDate!;

                              /// SHOW TIME PICKER
                              if (widget.showTime) {
                                final pickedTime = await showCustomTimePicker(
                                  context,
                                );

                                if (pickedTime != null) {
                                  finalDate = DateTime(
                                    tempDate!.year,
                                    tempDate!.month,
                                    tempDate!.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                }
                              }

                              setState(() {
                                selectedDate = finalDate;
                              });

                              widget.onDateSelected?.call(finalDate);
                            }

                            context.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<TimeOfDay?> showCustomTimePicker(BuildContext context) async {
    int selectedHour = 9;
    int selectedMinute = 0;
    String period = "AM";

    return await showModalBottomSheet<TimeOfDay>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),

              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),

                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  /// HANDLE
                  Container(
                    width: 40,
                    height: 4,

                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,

                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        "Select Time",

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

                  const SizedBox(height: 10),

                  /// TIME DISPLAY
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(color: Colors.grey.shade200),
                    ),

                    child: Text(
                      "${selectedHour.toString().padLeft(2, '0')}"
                      ":"
                      "${selectedMinute.toString().padLeft(2, '0')}"
                      " $period",

                      style: AppTextStyles.headline.copyWith(
                        color: Colors.black,
                        fontSize: 28,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// PICKERS
                  Row(
                    children: [
                      /// HOUR
                      Expanded(
                        child: SizedBox(
                          height: 180,

                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 45,

                            perspective: 0.003,

                            diameterRatio: 1.2,

                            physics: const FixedExtentScrollPhysics(),

                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedHour = index + 1;
                              });
                            },

                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 12,

                              builder: (context, index) {
                                final hour = index + 1;

                                final isSelected = selectedHour == hour;

                                return Center(
                                  child: Text(
                                    hour.toString().padLeft(2, '0'),

                                    style: TextStyle(
                                      fontSize: isSelected ? 26 : 18,

                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w400,

                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      /// MINUTE
                      Expanded(
                        child: SizedBox(
                          height: 180,

                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 45,

                            perspective: 0.003,

                            diameterRatio: 1.2,

                            physics: const FixedExtentScrollPhysics(),

                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedMinute = index;
                              });
                            },

                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 60,

                              builder: (context, index) {
                                final isSelected = selectedMinute == index;

                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),

                                    style: TextStyle(
                                      fontSize: isSelected ? 26 : 18,

                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w400,

                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      /// AM PM
                      Column(
                        children: [
                          _periodButton(
                            title: "AM",

                            selected: period == "AM",

                            onTap: () {
                              setModalState(() {
                                period = "AM";
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          _periodButton(
                            title: "PM",

                            selected: period == "PM",

                            onTap: () {
                              setModalState(() {
                                period = "PM";
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// ACTIONS
                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlinedButton(
                          text: "Cancel",

                          onTap: () {
                            context.pop();
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: CustomButton(
                          text: "Apply",

                          onTap: () {
                            int finalHour = selectedHour;

                            if (period == "PM" && finalHour != 12) {
                              finalHour += 12;
                            }

                            if (period == "AM" && finalHour == 12) {
                              finalHour = 0;
                            }

                            Navigator.pop(
                              context,

                              TimeOfDay(
                                hour: finalHour,
                                minute: selectedMinute,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _periodButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        width: 60,
        height: 46,

        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),

        child: Center(
          child: Text(
            title,

            style: AppTextStyles.label.copyWith(
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            widget.label,

            style: AppTextStyles.label.copyWith(color: Colors.black),
          ),

          const SizedBox(height: 6),

          GestureDetector(
            onTap: _pickDate,

            child: Container(
              height: 48,

              padding: const EdgeInsets.symmetric(horizontal: 12),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,

                borderRadius: BorderRadius.circular(14),

                border: Border.all(color: Colors.grey.shade300),
              ),

              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: Colors.grey),

                    const SizedBox(width: 10),
                  ],

                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? widget.showTime
                                ? DateFormat(
                                    'dd MMM yyyy • hh:mm a',
                                  ).format(selectedDate!)
                                : DateFormat(
                                    'dd MMM yyyy',
                                  ).format(selectedDate!)
                          : widget.hint,

                      style: selectedDate != null
                          ? AppTextStyles.body.copyWith(color: Colors.black)
                          : AppTextStyles.label.copyWith(color: Colors.grey),
                    ),
                  ),

                  const Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// NAV BUTTON
class _NavButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(8),

      child: Container(
        width: 32,
        height: 32,

        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),

          borderRadius: BorderRadius.circular(8),

          color: Colors.grey.shade100,
        ),

        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }
}
