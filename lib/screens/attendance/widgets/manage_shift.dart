import 'package:flutter/material.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/attendance/ui/attendance_screen.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_dropdown.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';

class ManageShiftSheet extends StatefulWidget {
  final List<ShiftModel> shifts;

  const ManageShiftSheet({
    super.key,
    required this.shifts,
  });

  @override
  State<ManageShiftSheet> createState() =>
      _ManageShiftSheetState();
}

class _ManageShiftSheetState
    extends State<ManageShiftSheet> {

  /// OPEN ADD/EDIT SHEET
  Future<void> _openAddEditShiftSheet({
    ShiftModel? shift,
    int? index,
  }) async {

    final TextEditingController shiftController =
        TextEditingController(
      text: shift?.name ?? "",
    );

    String selectedMode =
        shift?.mode ?? "Static";

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context)
                        .viewInsets
                        .bottom,
              ),
              child: Container(
                padding:
                    const EdgeInsets.all(16),
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Wrap(
                  children: [

                    /// HANDLE
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey.shade400,
                          borderRadius:
                              BorderRadius
                                  .circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// HEADER
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          shift == null
                              ? "Add Shift"
                              : "Edit Shift",
                          style:
                              AppTextStyles
                                  .label
                                  .copyWith(
                            fontSize: 18,
                            color:
                                Colors.black,
                          ),
                        ),

                        IconButton(
                          onPressed: () =>
                              Navigator.pop(
                                  context),
                          icon: const Icon(
                              Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// NAME
                    CustomTextField(
                      controller:
                          shiftController,
                      hint:
                          "Enter shift name",
                      label: "Shift Name",
                      icon: Icons.badge,
                    ),

                    const SizedBox(height: 14),

                    /// MODE
                    CustomDropdown<String>(
                      label: "Shift Mode",
                      hint: "Select Mode",
                      icon: Icons.schedule,
                      value: selectedMode,
                      items: const [
                        "Static",
                        "Event"
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          selectedMode =
                              value!;
                        });
                      },
                    ),

                    const SizedBox(height: 22),

                    /// SAVE
                    CustomButton(
                      text: shift == null
                          ? "Save Shift"
                          : "Update Shift",
                      icon: Icons.save,
                      onTap: () {

                        if (shiftController
                            .text
                            .trim()
                            .isEmpty) {
                          return;
                        }

                        final newShift =
                            ShiftModel(
                          name:
                              shiftController
                                  .text
                                  .trim(),
                          mode:
                              selectedMode,
                        );

                        setState(() {

                          if (index != null) {
                            widget.shifts[index] =
                                newShift;
                          } else {
                            widget.shifts
                                .add(newShift);
                          }
                        });

                        Navigator.pop(
                            context);
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
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height:
          MediaQuery.of(context).size.height *
              0.72,

      padding: const EdgeInsets.all(16),

      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      child: Column(
        children: [

          /// HANDLE
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius:
                  BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 14),

          /// HEADER
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    "Manage Shifts",
                    style: AppTextStyles.label
                        .copyWith(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),

                  Text(
                    "Create and manage shift modes",
                    style: AppTextStyles.small
                        .copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              IconButton(
                onPressed: () =>
                    Navigator.pop(context),
                icon:
                    const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// ADD SHIFT BUTTON
          CustomButton(
            text: "Add Shift",
            icon: Icons.add,
            onTap: () {
              _openAddEditShiftSheet();
            },
          ),

          const SizedBox(height: 18),

          /// LIST
          Expanded(
            child: ListView.builder(
              itemCount: widget.shifts.length,

              itemBuilder: (context, index) {

                final shift =
                    widget.shifts[index];

                return Container(
                  margin:
                      const EdgeInsets.only(
                          bottom: 10),

                  padding:
                      const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                            18),

                    border: Border.all(
                      color:
                          Colors.grey.shade200,
                    ),
                  ),

                  child: Row(
                    children: [

                      Container(
                        padding:
                            const EdgeInsets
                                .all(12),

                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .primary
                              .withOpacity(.1),

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      12),
                        ),

                        child: Icon(
                          Icons.schedule,
                          color:
                              AppColors.primary,
                        ),
                      ),

                      const SizedBox(
                          width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              shift.name,
                              style:
                                  AppTextStyles
                                      .label
                                      .copyWith(
                                color:
                                    Colors
                                        .black,
                              ),
                            ),

                            const SizedBox(
                                height: 4),

                            Text(
                              shift.mode,
                              style:
                                  AppTextStyles
                                      .small
                                      .copyWith(
                                color: Colors
                                    .black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// EDIT
                      IconButton(
                        onPressed: () {
                          _openAddEditShiftSheet(
                            shift: shift,
                            index: index,
                          );
                        },

                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                      ),

                      /// DELETE
                      IconButton(
                        onPressed: () {

                          setState(() {
                            widget.shifts
                                .removeAt(
                                    index);
                          });
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
  }
}