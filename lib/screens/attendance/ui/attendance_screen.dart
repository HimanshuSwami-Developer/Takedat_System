import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takedat_app/core/app_colors.dart';

import 'package:takedat_app/core/app_text.dart';

import 'package:takedat_app/models/attendance_model.dart';
import 'package:takedat_app/models/shift_model.dart';

import 'package:takedat_app/screens/attendance/bloc/attendance_bloc.dart';
import 'package:takedat_app/screens/attendance/bloc/attendance_event.dart';
import 'package:takedat_app/screens/attendance/bloc/attendance_state.dart';

import 'package:takedat_app/screens/attendance/widgets/attendance_cards.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_date_picker.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_dropdown.dart';
import 'package:takedat_app/screens/attendance/widgets/manage_attendance.dart';
import 'package:takedat_app/screens/attendance/widgets/manage_shift.dart';

import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_outlined_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/utils/app_utils.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ScrollController scrollController = ScrollController();
  Timer? _debounce;
  late AttendanceBloc attendanceBloc;
  DateTime? filterStartDate;
  DateTime? filterEndDate;
  String? filterStatus;

  bool get hasActiveFilter {
    return filterStartDate != null ||
        filterEndDate != null ||
        filterStatus != null;
  }

  @override
  void initState() {
    super.initState();

    attendanceBloc = context.read<AttendanceBloc>()
      ..add(LoadShiftsEvent())
      ..add(LoadAttendanceEvent());

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        attendanceBloc.add(LoadMoreAttendanceEvent());
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),

        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            List<ShiftModel> shifts = [];

            List<AttendanceModel> attendance = [];

            if (state is AttendanceLoaded) {
              shifts = state.shifts;

              attendance = state.attendance;
            }

            return Column(
              children: [
                /// =================================
                /// HEADER
                /// =================================
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

                    Container(
                      decoration: BoxDecoration(
                        color: hasActiveFilter
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,

                        borderRadius: BorderRadius.circular(10),

                        border: hasActiveFilter
                            ? Border.all(color: AppColors.primary)
                            : null,
                      ),

                      child: IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: hasActiveFilter ? AppColors.primary : Colors.black,
                        ),

                        onPressed: () => _openFilterSheet(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  child: CustomTextField(
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) {
                        _debounce!.cancel();
                      }

                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        context.read<AttendanceBloc>().add(
                          SearchAttendanceEvent(value),
                        );
                      });
                    },
                    label: "",
                    hint: "Search employee or ID or number or email",
                    icon: Icons.search,
                  ),
                ),

                const SizedBox(height: 12),

                /// =================================
                /// ACTION BUTTONS
                /// =================================
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

                    /// =========================
                    /// CREATE ATTENDANCE
                    /// =========================
                    Expanded(
                      child: CustomButton(
                        text: "Create",

                        icon: Icons.add,

                        isFullWidth: false,

                        onTap: () {
                          showModalBottomSheet(
                            context: context,

                            isScrollControlled: true,

                            backgroundColor: Colors.transparent,

                            builder: (_) {
                              return BlocProvider.value(
                                value: context.read<AttendanceBloc>(),
                                child: AddAttendanceShiftSheet(
                                  shifts: shifts,
                                  onSave: (data) {
                                    final model = AttendanceModel.fromLocalMap(
                                      data,
                                    );
                                    context.read<AttendanceBloc>().add(
                                      SaveAttendanceEvent(model),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// =========================
                    /// MANAGE SHIFT
                    /// =========================
                    Expanded(
                      child: CustomButton(
                        text: "Add Shift",

                        icon: Icons.schedule,

                        onTap: () {
                          showModalBottomSheet(
                            context: context,

                            isScrollControlled: true,

                            backgroundColor: Colors.transparent,

                            builder: (_) {
                              return BlocProvider.value(
                                value: context.read<AttendanceBloc>(),
                                child: ManageShiftSheet(shifts: shifts),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// =================================
                /// LOADING
                /// =================================
                if (state is AttendanceLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                /// =================================
                /// LIST
                /// =================================
                else
                  Expanded(
                    child: attendance.isEmpty
                        ? Center(
                            child: Text(
                              "No Attendance Found",

                              style: AppTextStyles.label.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            controller: scrollController,
                            child: Wrap(
                              spacing: 0,

                              runSpacing: 0,

                              children: attendance.map((item) {
                                final data = {
                                  "id": item.id,
                                  "userId":
                                      item.userId, // ✅ real UUID for Supabase
                                  "name": item.user?['full_name'] ?? "Employee",
                                  "empId":
                                      "EMP-${item.user?['emp_id'] ?? ""}", // display only
                                  "email": item.user?['email'] ?? "",
                                  "mode": item.mode,
                                  "shift": item.shift?['shift_name'] ?? "",
                                  "shiftId": item.shiftId, // ✅ real shift id
                                  "time":
                                      "${AppUtils.format(item.shiftStart.toString().split('.')[0])}"
                                      " - "
                                      "${AppUtils.format(item.shiftEnd.toString().split('.')[0])}",
                                  "shiftStart": item
                                      .shiftStart, // ✅ DateTime for pre-fill
                                  "shiftEnd":
                                      item.shiftEnd, // ✅ DateTime for pre-fill
                                  "status": item.status,
                                  "initials": AppUtils.getInitials(
                                    item.user?['full_name'] ?? "EM",
                                  ),
                                };

                                return AttendanceCard(
                                  item: data,
                                  shifts: shifts,
                                  onDelete: () => context
                                      .read<AttendanceBloc>()
                                      .add(DeleteAttendanceEvent(item.id ?? 0)),

                                  // For UPDATE (in AttendanceCard or wherever onUpdate is handled):
                                  onUpdate: (data) {
                                    final model = AttendanceModel.fromLocalMap({
                                      ...data,
                                      'id': item.id,
                                    });
                                    context.read<AttendanceBloc>().add(
                                      UpdateAttendanceEvent(model),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ===============================================
  /// FILTER SHEET
  /// ===============================================

void _openFilterSheet(BuildContext context) {
  DateTime? tempStartDate = filterStartDate;
  DateTime? tempEndDate = filterEndDate;
  String? tempStatus = filterStatus;

  // ✅ Capture bloc reference before entering the sheet's builder
  final bloc = context.read<AttendanceBloc>();

  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder( // ✅ Required for local state inside the sheet
        builder: (builderContext, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            maxChildSize: 0.65,
            minChildSize: 0.65,
            expand: false,
            builder: (_, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // HANDLE
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // HEADER
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
                          onPressed: () => Navigator.pop(sheetContext), // ✅ use sheetContext
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // FORM
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          CustomDateField(
                            label: "Start Shift",
                            hint: "Select start date",
                            icon: Icons.calendar_today,
                            showTime: true,
                            onDateSelected: (value) {
                              setSheetState(() => tempStartDate = value); // ✅ use setSheetState
                            },
                          ),
                          CustomDateField(
                            label: "End Shift",
                            hint: "Select end date",
                            icon: Icons.calendar_today,
                            showTime: true,
                            onDateSelected: (value) {
                              setSheetState(() => tempEndDate = value); // ✅
                            },
                          ),
                          CustomDropdown<String>(
                            label: "Status",
                            hint: "Select status",
                            icon: Icons.filter_alt,
                            items: const ["present", "absent", "half_day"],
                            onChanged: (value) {
                              setSheetState(() => tempStatus = value); // ✅
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // ACTIONS
                    Row(
                      children: [
                        Expanded(
                          child: CustomOutlinedButton(
                            text: "Reset",
                            onTap: () {
                              setState(() { // ✅ outer setState for the screen
                                filterStartDate = null;
                                filterEndDate = null;
                                filterStatus = null;
                              });
                              bloc.add(FilterAttendanceEvent()); // ✅ captured bloc
                              Navigator.pop(sheetContext);       // ✅ correct context
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: "Apply Filter",
                            onTap: () {
                              setState(() { // ✅ outer setState
                                filterStartDate = tempStartDate;
                                filterEndDate = tempEndDate;
                                filterStatus = tempStatus;
                              });
                              bloc.add(FilterAttendanceEvent(
                                startDate: tempStartDate,
                                endDate: tempEndDate,
                                status: tempStatus,
                              ));
                              Navigator.pop(sheetContext); // ✅ correct context
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
    },
  );
}
}
