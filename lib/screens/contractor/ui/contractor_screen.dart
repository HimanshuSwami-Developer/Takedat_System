import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_date_picker.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_outlined_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/screens/contractor/widget/add_contract.dart';
import 'package:takedat_app/screens/contractor/widget/contractor_card.dart';

/// =======================================
/// MODEL
/// =======================================

class ContractorModel {
  final String name;
  final String email;
  final String phone;
  final double amount;
  final DateTime payDate;
  final String initials;
  final String company;
  final String status;

  ContractorModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.amount,
    required this.payDate,
    required this.initials,
    required this.company,
    required this.status,
  });
}

/// =======================================
/// DUMMY DATA
/// =======================================

final List<ContractorModel> contractorData = [
  ContractorModel(
    name: "Alex Rivera",
    email: "alex@example.com",
    phone: "+44 7700 900123",
    amount: 1200,
    payDate: DateTime(2023, 10, 12),
    initials: "AR",
    company: "Rivera Studio",
    status: "Paid",
  ),

  ContractorModel(
    name: "Sarah Miller",
    email: "s.miller@work.io",
    phone: "+44 7700 900555",
    amount: 2450,
    payDate: DateTime(2023, 10, 10),
    initials: "SM",
    company: "Creative Hub",
    status: "Pending",
  ),

  ContractorModel(
    name: "James Doe",
    email: "james.doe@contract.net",
    phone: "+44 7700 900888",
    amount: 980,
    payDate: DateTime(2023, 10, 8),
    initials: "JD",
    company: "JD Services",
    status: "Paid",
  ),
];

/// =======================================
/// SCREEN
/// =======================================

class ContractorScreen extends StatefulWidget {
  const ContractorScreen({super.key});

  @override
  State<ContractorScreen> createState() => _ContractorScreenState();
}

class _ContractorScreenState extends State<ContractorScreen> {
  final TextEditingController searchController = TextEditingController();

  Timer? _debounce;

  List<ContractorModel> filteredList = contractorData;

  double minAmount = 0;
  double maxAmount = 5000;

  DateTime? selectedPayDate;

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

  /// =======================================
  /// APPLY FILTERS
  /// =======================================

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      filteredList = contractorData.where((e) {
        /// SEARCH
        final searchMatch =
            query.isEmpty ||
            e.name.toLowerCase().contains(query) ||
            e.email.toLowerCase().contains(query) ||
            e.phone.toLowerCase().contains(query);

        /// AMOUNT
        final amountMatch = e.amount >= minAmount && e.amount <= maxAmount;

        /// DATE
        final dateMatch =
            selectedPayDate == null ||
            DateFormat('dd/MM/yyyy').format(e.payDate) ==
                DateFormat('dd/MM/yyyy').format(selectedPayDate!);

        return searchMatch && amountMatch && dateMatch;
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
            Container(
              padding: const EdgeInsets.only(top: 12),
              height: 50,
              width: double.infinity,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    "Contractor",

                    style: AppTextStyles.headline.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),

                  CustomButton(
                    text: "Add Contract",

                    onTap: () {
                      showModalBottomSheet(
                        context: context,

                        useRootNavigator: true,

                        isScrollControlled: true,

                        backgroundColor: Colors.transparent,

                        builder: (_) {
                          return AddContractSheet(
                            contractorList: contractorData,

                            onSave: (contract, index) {
                              setState(() {
                                if (index != null) {
                                  contractorData[index] = contract;
                                } else {
                                  contractorData.add(contract);
                                }

                                _applyFilters();
                              });
                            },
                          );
                        },
                      );
                    },

                    icon: Icons.add,

                    isFullWidth: false,
                  ),
                ],
              ),
            ),

            /// SEARCH + FILTER
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: CustomTextField(
                          controller: searchController,
                          label: "",
                          hint: "Search contractor",
                          icon: Icons.search,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _openFilterSheet,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(Icons.tune, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// LIST
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Text(
                        "No contractors found",
                        style: AppTextStyles.label.copyWith(color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 0,
                        runSpacing: 0,
                        children: filteredList.map((contractor) {
                          final originalIndex = contractorData.indexOf(
                            contractor,
                          );

                          return ContractorCard(
                            contractor: contractor,
                            onEdit: () {
                              showModalBottomSheet(
                                context: context,
                                useRootNavigator: true,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) {
                                  return AddContractSheet(
                                    contractor: contractor,
                                    index: originalIndex,
                                    contractorList: contractorData,
                                    onSave: (updated, index) {
                                      setState(() {
                                        contractorData[index!] = updated;
                                        _applyFilters();
                                      });
                                    },
                                  );
                                },
                              );
                            },
                            onDelete: () {
                              setState(() {
                                contractorData.remove(contractor);
                                _applyFilters();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================================
  /// FILTER SHEET
  /// =======================================

  void _openFilterSheet() {
    double tempMin = minAmount;
    double tempMax = maxAmount;

    DateTime? tempDate = selectedPayDate;

    showModalBottomSheet(
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

                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),

              child: Wrap(
                children: [
                  /// HANDLE
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,

                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TITLE
                  Text(
                    "Filter Contractors",

                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// RANGE VALUES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      _amountBox("Min Amount", tempMin.toInt()),

                      _amountBox("Max Amount", tempMax.toInt()),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// RANGE SLIDER
                  RangeSlider(
                    values: RangeValues(tempMin, tempMax),

                    min: 0,
                    max: 5000,

                    divisions: 100,

                    activeColor: AppColors.primary,

                    labels: RangeLabels(
                      tempMin.toInt().toString(),

                      tempMax.toInt().toString(),
                    ),

                    onChanged: (value) {
                      setModalState(() {
                        tempMin = value.start;

                        tempMax = value.end;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// DATE PICKER
                  CustomDateField(
                    label: "Date Of Pay",

                    hint: "Select Pay Date",

                    icon: Icons.calendar_today,

                    onDateSelected: (date) {
                      setModalState(() {
                        tempDate = date;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

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
                          text: "Apply",

                          icon: Icons.check,

                          onTap: () {
                            minAmount = tempMin;

                            maxAmount = tempMax;

                            selectedPayDate = tempDate;

                            _applyFilters();

                            Navigator.pop(context);
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

  /// =======================================
  /// AMOUNT BOX
  /// =======================================

  Widget _amountBox(String title, int value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              title,

              style: AppTextStyles.small.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 6),

            Text(
              "£$value",

              style: AppTextStyles.label.copyWith(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
