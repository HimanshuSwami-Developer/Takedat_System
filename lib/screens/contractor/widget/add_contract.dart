import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_date_picker.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_outlined_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/screens/contractor/ui/contractor_screen.dart';

class AddContractSheet extends StatefulWidget {
  final ContractorModel? contractor;

  final int? index;

  final List<ContractorModel> contractorList;

  final Function(
    ContractorModel contractor,
    int? index,
  ) onSave;

  const AddContractSheet({
    super.key,
    this.contractor,
    this.index,
    required this.contractorList,
    required this.onSave,
  });

  @override
  State<AddContractSheet> createState() =>
      _AddContractSheetState();
}

class _AddContractSheetState
    extends State<AddContractSheet> {

  late TextEditingController contractorController;

  late TextEditingController amountController;

  late TextEditingController emailController;

  late TextEditingController phoneController;

  DateTime? selectedDate;

  ContractorModel? selectedContractor;

  File? selectedFile;

  @override
  void initState() {
    super.initState();

    contractorController =
        TextEditingController(
      text:
          widget.contractor?.name ?? "",
    );

    amountController =
        TextEditingController(
      text:
          widget.contractor?.amount
              .toString() ??
          "",
    );

    emailController =
        TextEditingController(
      text:
          widget.contractor?.email ?? "",
    );

    phoneController =
        TextEditingController(
      text:
          widget.contractor?.phone ?? "",
    );

    selectedDate =
        widget.contractor?.payDate;

    selectedContractor =
        widget.contractor;


    contractorController.addListener(() {

    });
  }

  /// ==============================
  /// PICK FILE
  /// ==============================

  Future<void> _pickFile() async {

  try {

    final ImagePicker picker =
        ImagePicker();

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      setState(() {

        selectedFile =
            File(image.path);
      });
    }

  } catch (e) {

    debugPrint(
      "Image Picker Error: $e",
    );
  }
}
  @override
  Widget build(BuildContext context) {

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
            top: Radius.circular(26),
          ),
        ),

        child: Wrap(
          children: [

            /// HANDLE
            Center(
              child: Container(
                width: 42,
                height: 4,

                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade300,

                  borderRadius:
                      BorderRadius.circular(
                    99,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// TITLE
            Text(
              widget.contractor == null
                  ? "Add Contract"
                  : "Edit Contract",

              style:
                  AppTextStyles.label
                      .copyWith(
                fontSize: 18,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 22),

            /// CONTRACTOR SEARCH
            CustomTextField(
              controller:
                  contractorController,

              label: "Contractor",

              hint:
                  "Enter Name",

              icon: Icons.search,
            ),

           
            const SizedBox(height: 10),

            /// EMAIL
            CustomTextField(
              controller:
                  emailController,

              label: "Email",

              hint:
                  "Enter email",

              icon:
                  Icons.email_outlined,
            ),

            const SizedBox(height: 10),

            /// CONTACT
            CustomTextField(
              controller:
                  phoneController,

              label: "Contact",

              hint:
                  "Enter contact number",

              icon:
                  Icons.call_outlined,
            ),

            const SizedBox(height: 10),

            /// PAY DATE
            CustomDateField(
              label: "Pay Date",

              hint:
                  "Select pay date",

              icon:
                  Icons.calendar_today,

              onDateSelected:
                  (date) {

                selectedDate = date;
              },
            ),

            const SizedBox(height: 10),

            /// PAY AMOUNT
            CustomTextField(
              controller:
                  amountController,

              label: "Pay Amount",

              hint:
                  "Enter amount",

              icon:
                  Icons.currency_pound,
            ),

            const SizedBox(height: 14),

            /// UPLOAD FILE
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  "Attachment",

                  style:
                      AppTextStyles
                          .label
                          .copyWith(
                    color:
                        Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _pickFile,

                  child: Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(
                      14,
                    ),

                    decoration:
                        BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),

                      border: Border.all(
                        color: Colors
                            .grey
                            .shade300,
                      ),
                    ),

                    child: Row(
                      children: [

                        Container(
                          padding:
                              const EdgeInsets
                                  .all(10),

                          decoration:
                              BoxDecoration(
                            color:
                                AppColors
                                    .primary
                                    .withOpacity(
                              .08,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),

                          child: Icon(
                            Icons.upload_file,

                            color:
                                AppColors
                                    .primary,
                          ),
                        ),

                        const SizedBox(
                            width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                selectedFile !=
                                        null
                                    ? selectedFile!
                                        .path
                                        .split(
                                            '/')
                                        .last
                                    : "Upload PDF or Image",

                                style:
                                    AppTextStyles
                                        .body
                                        .copyWith(
                                  color: Colors
                                      .black,
                                ),
                              ),

                              const SizedBox(
                                  height: 4),

                              Text(
                                "PDF, PNG, JPG",

                                style:
                                    AppTextStyles
                                        .small
                                        .copyWith(
                                  color: Colors
                                      .grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons
                              .arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            /// BUTTONS
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
                    text:
                        widget.contractor ==
                                null
                            ? "Save"
                            : "Update",

                    icon: Icons.check,

                    onTap: () {

                      final newContract =
                          ContractorModel(
                        name:
                            contractorController
                                .text,

                        email:
                            emailController
                                .text,

                        phone:
                            phoneController
                                .text,

                        initials:
                            contractorController
                                .text
                                .split(" ")
                                .map(
                                  (e) =>
                                      e[0],
                                )
                                .take(2)
                                .join(),

                        company:
                            selectedContractor
                                    ?.company ??
                                "Contractor",

                        status:
                            selectedContractor
                                    ?.status ??
                                "Pending",

                        amount:
                            double.tryParse(
                                  amountController
                                      .text,
                                ) ??
                                0,

                        payDate:
                            selectedDate ??
                                DateTime.now(),
                      );

                      widget.onSave(
                        newContract,
                        widget.index,
                      );

                      Navigator.pop(
                        context,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}