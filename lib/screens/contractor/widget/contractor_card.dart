import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/contractor/ui/contractor_screen.dart';

class ContractorCard extends StatefulWidget {
  final ContractorModel contractor;

  final VoidCallback? onEdit;

  final VoidCallback? onDelete;

  const ContractorCard({
    super.key,
    required this.contractor,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<ContractorCard> createState() => _ContractorCardState();
}

class _ContractorCardState extends State<ContractorCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.contractor;

    return GestureDetector(
      onTap: () {
        setState(() {
          expanded = !expanded;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 10),

        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: Colors.grey.shade200),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [
            /// =========================
            /// TOP ROW
            /// =========================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                /// NAME + DATE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        item.name,

                        style: AppTextStyles.label.copyWith(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        DateFormat("dd MMM yyyy").format(item.payDate),

                        style: AppTextStyles.small.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                /// AMOUNT
                Text(
                  "£${item.amount.toStringAsFixed(2)}",

                  style: AppTextStyles.label.copyWith(
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// =========================
            /// EXPANDABLE SECTION
            /// =========================
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 10),

              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,

              firstChild: const SizedBox.shrink(),

              secondChild: Column(
                children: [
                  Divider(color: Colors.grey.shade200, height: 1),

                  const SizedBox(height: 12),
                  Column(
                    children: [
                      /// CONTACT
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),

                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Contact",

                                    style: AppTextStyles.small.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    item.phone,

                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: item.phone),
                                );
                              },

                              child: Container(
                                padding: const EdgeInsets.all(8),

                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,

                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(color: Colors.grey.shade200, height: 1),

                      /// EMAIL
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),

                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Email",

                                    style: AppTextStyles.small.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    item.email,

                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: item.email),
                                );
                              },

                              child: Container(
                                padding: const EdgeInsets.all(8),

                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,

                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),


                  /// ACTION BUTTONS
                  Row(
                    children: [
                      /// EDIT
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onEdit,

                          child: Container(
                            height: 42,

                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(.08),

                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(
                                color: AppColors.primary.withOpacity(.2),
                              ),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(
                                  Icons.edit_outlined,

                                  size: 18,

                                  color: AppColors.primary,
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  "Edit",

                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// DELETE
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onDelete,

                          child: Container(
                            height: 42,

                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(.08),

                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(
                                color: Colors.red.withOpacity(.2),
                              ),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                const Icon(
                                  Icons.delete_outline,

                                  size: 18,

                                  color: Colors.red,
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  "Delete",

                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// PAY SLIP BUTTON
                  CustomButton(
                    text: "View Pay Slip",

                    icon: Icons.receipt_long,

                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
