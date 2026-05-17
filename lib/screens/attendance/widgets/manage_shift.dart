import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';

import 'package:takedat_app/models/shift_model.dart';

import 'package:takedat_app/screens/attendance/bloc/attendance_bloc.dart';
import 'package:takedat_app/screens/attendance/bloc/attendance_event.dart';
import 'package:takedat_app/screens/attendance/bloc/attendance_state.dart';

import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';

import 'package:takedat_app/screens/attendance/widgets/custom_dropdown.dart';

class ManageShiftSheet extends StatefulWidget {
  final List<ShiftModel> shifts;

  const ManageShiftSheet({super.key, required this.shifts});

  @override
  State<ManageShiftSheet> createState() => _ManageShiftSheetState();
}

class _ManageShiftSheetState extends State<ManageShiftSheet> {

  /// =====================================================
  /// OPEN ADD / EDIT
  /// Pass the outer [bloc] explicitly so the modal's
  /// isolated context can still dispatch events.
  /// =====================================================
  Future<void> _openAddEditShiftSheet({ShiftModel? shift}) async {

    // ── Capture BLoC BEFORE entering the modal ──────────
    // Inside showModalBottomSheet the context has no BLoC ancestor.
    final bloc = context.read<AttendanceBloc>();

    final TextEditingController shiftController = TextEditingController(
      text: shift?.shiftName ?? "",
    );

    String selectedMode = shift?.shiftType ?? "static";

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Wrap(
                  children: [

                    /// ═════════════════════════════════
                    /// HANDLE
                    /// ═════════════════════════════════
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

                    /// ═════════════════════════════════
                    /// HEADER
                    /// ═════════════════════════════════
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          shift == null ? "Add Shift" : "Edit Shift",
                          style: AppTextStyles.label.copyWith(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          // ✅ Use modalContext to close only the modal
                          onPressed: () => Navigator.of(modalContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// ═════════════════════════════════
                    /// SHIFT NAME
                    /// ═════════════════════════════════
                    CustomTextField(
                      controller: shiftController,
                      hint: "Enter shift name",
                      label: "Shift Name",
                      icon: Icons.badge,
                    ),

                    const SizedBox(height: 14),

                    /// ═════════════════════════════════
                    /// MODE
                    /// ═════════════════════════════════
                    CustomDropdown<String>(
                      label: "Shift Mode",
                      hint: "Select Mode",
                      icon: Icons.schedule,
                      value: selectedMode.capitalize(),
                      items: const ["Static", "Event"],
                      onChanged: (value) {
                        setModalState(() {
                          selectedMode = value!.toLowerCase();
                        });
                      },
                    ),

                    const SizedBox(height: 22),

                    /// ═════════════════════════════════
                    /// SAVE BUTTON
                    /// ═════════════════════════════════
                    CustomButton(
                      text: shift == null ? "Save Shift" : "Update Shift",
                      icon: Icons.save,
                      onTap: () {

                        final name = shiftController.text.trim();

                        if (name.isEmpty) return; // basic guard

                        final model = ShiftModel(
                          id:        shift?.id,
                          shiftName: name,
                          shiftType: selectedMode,
                        );

                        if (shift != null) {
                          // ✅ Use captured [bloc], not context.read inside modal
                          bloc.add(UpdateShiftEvent(model));
                        } else {
                          bloc.add(SaveShiftEvent(model));
                        }

                        // ✅ Close modal with modalContext
                        Navigator.of(modalContext).pop();
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    shiftController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {

        List<ShiftModel> shifts = [];

        if (state is AttendanceLoaded) {
          shifts = state.shifts;
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [

              /// ═══════════════════════════════════════
              /// HANDLE
              /// ═══════════════════════════════════════
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 14),

              /// ═══════════════════════════════════════
              /// HEADER
              /// ═══════════════════════════════════════
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manage Shifts",
                        style: AppTextStyles.label.copyWith(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Create and manage shift modes",
                        style: AppTextStyles.small.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                  IconButton(
                    // ✅ Outer sheet closed with outer context
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// ═══════════════════════════════════════
              /// ADD SHIFT
              /// ═══════════════════════════════════════
              CustomButton(
                text: "Add Shift",
                icon: Icons.add,
                onTap: _openAddEditShiftSheet,
              ),

              const SizedBox(height: 18),

              /// ═══════════════════════════════════════
              /// SHIFT LIST
              /// ═══════════════════════════════════════
              Expanded(
                child: shifts.isEmpty
                    ? Center(
                        child: Text("No Shifts Found",
                            style: AppTextStyles.small),
                      )
                    : ListView.builder(
                        itemCount: shifts.length,
                        itemBuilder: (context, index) {
                          final shift = shifts[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [

                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.schedule,
                                      color: AppColors.primary),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shift.shiftName,
                                        style: AppTextStyles.label
                                            .copyWith(color: Colors.black),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        shift.shiftType.toUpperCase(),
                                        style: AppTextStyles.small
                                            .copyWith(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),

                                /// ═══════════════════
                                /// EDIT
                                /// ═══════════════════
                                IconButton(
                                  onPressed: () =>
                                      _openAddEditShiftSheet(shift: shift),
                                  icon: const Icon(Icons.edit_outlined),
                                ),

                                /// ═══════════════════
                                /// DELETE
                                /// ═══════════════════
                                IconButton(
                                  onPressed: () {
                                    context.read<AttendanceBloc>().add(
                                      DeleteShiftEvent(shift.id!),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// =======================================================
/// STRING EXTENSION
/// =======================================================
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}