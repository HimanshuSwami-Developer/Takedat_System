import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/payment/ui/payment_screen.dart';

/// =======================================
/// PAYMENT CARD
/// =======================================

class PaymentCard extends StatelessWidget {

  final PaymentModel payment;

  final VoidCallback onUpdate;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {

    final bool isPaid =
        payment.status == "Paid";

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border(
          left: BorderSide(
            color: isPaid
                ? Colors.green
                : Colors.red,

            width: 4,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.03),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          /// TOP
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(
                      payment.name,

                      style:
                          AppTextStyles
                              .label
                              .copyWith(
                        color:
                            Colors.black,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                        height: 4),

                    Text(
                      payment.employeeId,

                      style:
                          AppTextStyles
                              .small
                              .copyWith(
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration:
                    BoxDecoration(
                  color: isPaid
                      ? Colors.green
                      : Colors.red,

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Text(
                  payment.status,

                  style:
                      AppTextStyles
                          .small
                          .copyWith(
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// SHIFT
          Row(
            children: [

              Expanded(
                child: _detail(
                  "Shift Start",

                  DateFormat(
                    "MMM dd, hh:mm a",
                  ).format(
                    payment.shiftStart,
                  ),
                ),
              ),

              Expanded(
                child: _detail(
                  "Shift End",

                  DateFormat(
                    "MMM dd, hh:mm a",
                  ).format(
                    payment.shiftEnd,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// PAYMENT
          Row(
            children: [

              Expanded(
                child: _detail(
                  "Payment I & II",

                  "\$${payment.payment1.toStringAsFixed(2)} / \$${payment.payment2.toStringAsFixed(2)}",
                ),
              ),

              Expanded(
                child: _detail(
                  "Expense",

                  "\$${payment.expense.toStringAsFixed(2)}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// BUTTONS
          Row(
            children: [

              Expanded(
                child:
                    OutlinedButton(
                  onPressed: onUpdate,

                  style:
                      OutlinedButton.styleFrom(
                    minimumSize:
                        const Size
                            .fromHeight(
                      44,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  child: Text(
                    "Update",

                    style:
                        AppTextStyles
                            .label
                            .copyWith(
                      color:
                          AppColors
                              .primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: CustomButton(
                  text:
                      "Generate Slip",

                  onTap: () {},

                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(
    String title,
    String value,
  ) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style:
              AppTextStyles.small
                  .copyWith(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,

          style:
              AppTextStyles.body
                  .copyWith(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
