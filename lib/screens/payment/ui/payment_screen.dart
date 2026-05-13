import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_outlined_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/screens/payment/widget/payment_card.dart';

/// =======================================
/// MODEL
/// =======================================

class PaymentModel {
  final String name;
  final String employeeId;

  final DateTime shiftStart;
  final DateTime shiftEnd;

  final double payment1;
  final double payment2;
  final double expense;

  final String status;

  PaymentModel({
    required this.name,
    required this.employeeId,
    required this.shiftStart,
    required this.shiftEnd,
    required this.payment1,
    required this.payment2,
    required this.expense,
    required this.status,
  });
}

/// =======================================
/// DUMMY DATA
/// =======================================

final List<PaymentModel> paymentData = [
  PaymentModel(
    name: "Marcus Thorne",
    employeeId: "EMP-90234",
    shiftStart: DateTime(2024, 10, 24, 8),
    shiftEnd: DateTime(2024, 10, 24, 17),
    payment1: 450,
    payment2: 120,
    expense: 15.50,
    status: "Paid",
  ),
  PaymentModel(
    name: "Elena Rodriguez",
    employeeId: "EMP-77102",
    shiftStart: DateTime(2024, 10, 25, 9),
    shiftEnd: DateTime(2024, 10, 25, 18),
    payment1: 380,
    payment2: 90,
    expense: 42,
    status: "Pending",
  ),
];

/// =======================================
/// SCREEN
/// =======================================

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController searchController = TextEditingController();

  Timer? _debounce;

  List<PaymentModel> filteredList = paymentData;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      if (_debounce?.isActive ?? false) {
        _debounce?.cancel();
      }
      _debounce = Timer(const Duration(milliseconds: 500), _applyFilters);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      filteredList = paymentData.where((e) {
        return query.isEmpty ||
            e.name.toLowerCase().contains(query) ||
            e.employeeId.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F2),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// TITLE
            Container(
              padding: const EdgeInsets.only(top: 12, bottom: 0),

              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payments",
                    style: AppTextStyles.headline.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(Icons.tune, color: AppColors.primary),
                  ),
                ],
              ),
            ),

           SizedBox(height: 12,),
            /// SEARCH
            Container(
              width: double.infinity,
              child: CustomTextField(
                controller: searchController,
                label: "",
                hint: "Search employee or ID",
                icon: Icons.search,
              ),
            ),
           SizedBox(height: 12,),
            /// LIST
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: filteredList
                      .map(
                        (payment) => PaymentCard(
                          payment: payment,
                          onUpdate: () => _openUpdateSheet(payment),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================================
  /// UPDATE SHEET
  /// =======================================

  void _openUpdateSheet(PaymentModel payment) {
    final payment1Controller = TextEditingController(
      text: payment.payment1.toString(),
    );
    final payment2Controller = TextEditingController(
      text: payment.payment2.toString(),
    );
    final expenseController = TextEditingController(
      text: payment.expense.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Wrap(
              runSpacing: 16,
              children: [
                /// HANDLE
                SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),

                /// TITLE
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Update Payment",
                    style: AppTextStyles.label.copyWith(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),

                /// FIELDS
                CustomTextField(
                  controller: payment1Controller,
                  label: "Payment I (\$)",
                  hint: "Enter amount",
                  icon: Icons.payments_outlined,
                ),

                CustomTextField(
                  controller: payment2Controller,
                  label: "Payment II (\$)",
                  hint: "Enter amount",
                  icon: Icons.payments_outlined,
                ),

                CustomTextField(
                  controller: expenseController,
                  label: "Expense (\$)",
                  hint: "Enter expense",
                  icon: Icons.receipt_long,
                ),

                /// BUTTONS
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomOutlinedButton(
                          text: "Cancel",
                          onTap: () => context.pop(),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: CustomButton(
                          text: "Update",
                          icon: Icons.check,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
