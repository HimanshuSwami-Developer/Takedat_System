import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:takedat_app/core/app_colors.dart';
import 'package:takedat_app/core/app_text.dart';
import 'package:takedat_app/models/payment_model.dart';
import 'package:takedat_app/screens/attendance/widgets/custom_date_picker.dart';
import 'package:takedat_app/screens/auth/widget/custom_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_outlined_button.dart';
import 'package:takedat_app/screens/auth/widget/custom_textfield.dart';
import 'package:takedat_app/screens/payment/bloc/payment_bloc.dart';
import 'package:takedat_app/screens/payment/bloc/payment_event.dart';
import 'package:takedat_app/screens/payment/bloc/payment_state.dart';
import 'package:takedat_app/screens/payment/widget/payment_card.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── Active filter state ──────────────────────────────
  String? _filterStatus;          // 'pending' | 'paid' | 'cancelled' | null
  DateTime? _filterShiftFrom;
  DateTime? _filterShiftTo;

  bool get _hasActiveFilter =>
      _filterStatus != null ||
      _filterShiftFrom != null ||
      _filterShiftTo != null;

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(const LoadPayments());
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      context
          .read<PaymentBloc>()
          .add(SearchPayments(_searchController.text.trim()));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PaymentBloc>().add(const LoadMorePayments());
    }
  }

  // =====================================================
  // CLIENT-SIDE FILTER
  // =====================================================

  List<PaymentTrackModel> _applyFilters(List<PaymentTrackModel> payments) {
    return payments.where((p) {
      // Status filter
      if (_filterStatus != null &&
          p.paymentStatus.toLowerCase() != _filterStatus) {
        return false;
      }

      // Shift from
      if (_filterShiftFrom != null) {
        final start = p.attendance?.shiftStart;
        if (start == null || start.isBefore(_filterShiftFrom!)) return false;
      }

      // Shift to — include entire end day
      if (_filterShiftTo != null) {
        final end = p.attendance?.shiftStart;
        final toEnd = DateTime(
          _filterShiftTo!.year,
          _filterShiftTo!.month,
          _filterShiftTo!.day,
          23, 59, 59,
        );
        if (end == null || end.isAfter(toEnd)) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listenWhen: (_, curr) =>
          curr is PaymentLoaded &&
          (curr.successMessage != null || curr.errorMessage != null),
      listener: (context, state) {
        if (state is PaymentLoaded) {
          if (state.successMessage != null) {
            _showSnackBar(state.successMessage!, isError: false);
          } else if (state.errorMessage != null) {
            _showSnackBar(state.errorMessage!, isError: true);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F5F2),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  // ── TITLE ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payments",
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      // FILTER BUTTON with active dot
                      GestureDetector(
                        onTap: () => _openFilterSheet(context),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _hasActiveFilter
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _hasActiveFilter
                                      ? AppColors.primary
                                      : Colors.grey.shade200,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: _hasActiveFilter
                                    ? AppColors.primary
                                    : Colors.grey,
                                size: 20,
                              ),
                            ),
                            if (_hasActiveFilter)
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── SEARCH ─────────────────────────
                  CustomTextField(
                    controller: _searchController,
                    label: "",
                    hint: "Search employee or ID",
                    icon: Icons.search,
                  ),

                  const SizedBox(height: 8),

                  // ── ACTIVE FILTER CHIPS ────────────
                  if (_hasActiveFilter) _buildFilterChips(),

                  const SizedBox(height: 6),

                  // ── LIST ───────────────────────────
                  Expanded(child: _buildBody(state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // FILTER CHIPS (active filters summary)
  // =====================================================

  Widget _buildFilterChips() {
    final fmt = DateFormat("MMM dd");
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (_filterStatus != null)
            _FilterChip(
              label: _filterStatus!.capitalize(),
              onRemove: () => setState(() => _filterStatus = null),
            ),
          if (_filterShiftFrom != null || _filterShiftTo != null)
            _FilterChip(
              label: [
                if (_filterShiftFrom != null) "From ${fmt.format(_filterShiftFrom!)}",
                if (_filterShiftTo != null) "To ${fmt.format(_filterShiftTo!)}",
              ].join("  ·  "),
              onRemove: () => setState(() {
                _filterShiftFrom = null;
                _filterShiftTo = null;
              }),
            ),
        ],
      ),
    );
  }

  // =====================================================
  // BODY
  // =====================================================

  Widget _buildBody(PaymentState state) {
    if (state is PaymentLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PaymentError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 52),
            const SizedBox(height: 12),
            Text(state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  context.read<PaymentBloc>().add(const LoadPayments()),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (state is PaymentLoaded) {
      final filtered = _applyFilters(state.payments);

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payments_outlined,
                  size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                _hasActiveFilter
                    ? "No payments match the filters"
                    : "No payments found",
                style: AppTextStyles.label
                    .copyWith(color: Colors.grey.shade400),
              ),
              if (_hasActiveFilter) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _filterStatus = null;
                    _filterShiftFrom = null;
                    _filterShiftTo = null;
                  }),
                  child: const Text("Clear filters"),
                ),
              ],
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<PaymentBloc>().add(const LoadPayments());
          await Future.doWhile(() async {
            await Future.delayed(const Duration(milliseconds: 100));
            return context.read<PaymentBloc>().state is PaymentLoading;
          });
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: filtered.length + 1,
          itemBuilder: (context, index) {
            if (index == filtered.length) {
              return _buildFooter(state);
            }
            final payment = filtered[index];
            return PaymentCard(
              payment: payment,
              onUpdate: () => _openUpdateSheet(payment),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFooter(PaymentLoaded state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            "All payments loaded",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ),
      );
    }
    return const SizedBox(height: 16);
  }

  // =====================================================
  // SNACK BAR
  // =====================================================

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // =====================================================
  // FILTER BOTTOM SHEET
  // =====================================================

void _openFilterSheet(BuildContext screenCtx) {

  String? tempStatus = _filterStatus;

  DateTime? tempFrom = _filterShiftFrom;

  DateTime? tempTo = _filterShiftTo;

  showModalBottomSheet(
    context: screenCtx,

    useRootNavigator: false,

    isScrollControlled: true,

    backgroundColor: Colors.transparent,

    builder: (sheetContext) {

      return StatefulBuilder(
        builder: (_, setSheetState) {

          return SafeArea(
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom:
                    MediaQuery.of(sheetContext)
                        .viewInsets
                        .bottom +
                    24,
              ),

              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),

                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    /// HANDLE
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,

                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,

                          borderRadius:
                              BorderRadius.circular(99),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// TITLE
                    Text(
                      "Filter Payments",

                      style:
                          AppTextStyles.label.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// =================================================
                    /// STATUS
                    /// =================================================

                    _SectionLabel(
                      label: "Payment Status",
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,

                      children: [

                        _StatusFilterChip(
                          label: "All",

                          color: Colors.grey.shade600,

                          isSelected:
                              tempStatus == null,

                          onTap: () {
                            setSheetState(() {
                              tempStatus = null;
                            });
                          },
                        ),

                        _StatusFilterChip(
                          label: "Pending",

                          color:
                              const Color(0xFFF59E0B),

                          isSelected:
                              tempStatus == 'pending',

                          onTap: () {
                            setSheetState(() {
                              tempStatus =
                                  'pending';
                            });
                          },
                        ),

                        _StatusFilterChip(
                          label: "Paid",

                          color:
                              const Color(0xFF22C55E),

                          isSelected:
                              tempStatus == 'paid',

                          onTap: () {
                            setSheetState(() {
                              tempStatus = 'paid';
                            });
                          },
                        ),

                      ],
                    ),

                    const SizedBox(height: 26),

                    /// =================================================
                    /// DATE RANGE
                    /// =================================================

                    _SectionLabel(
                      label: "Shift Date Range",
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        /// FROM
                        Expanded(
                          child: CustomDateField(
                            label: "From",

                            hint: "Select Date",

                            icon: Icons
                                .calendar_today_outlined,

                            initialDate: tempFrom,

                            onDateSelected:
                                (date) {
                              setSheetState(() {
                                tempFrom = date;

                                /// AUTO FIX
                                if (tempTo != null &&
                                    tempTo!
                                        .isBefore(
                                          date,
                                        )) {
                                  tempTo = null;
                                }
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// TO
                        Expanded(
                          child: CustomDateField(
                            label: "To",

                            hint: "Select Date",

                            icon: Icons
                                .calendar_today_outlined,

                            initialDate: tempTo,

                            onDateSelected:
                                (date) {
                              setSheetState(() {
                                tempTo = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    /// DATE VALIDATION
                    if (tempFrom != null &&
                        tempTo != null &&
                        tempTo!
                            .isBefore(tempFrom!))
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 10,
                        ),

                        child: Text(
                          "End date cannot be before start date",

                          style: AppTextStyles.small
                              .copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    /// =================================================
                    /// BUTTONS
                    /// =================================================

                    Row(
                      children: [

                        /// RESET
                        Expanded(
                          child:
                              CustomOutlinedButton(
                            text: "Reset",

                            onTap: () {

                              setState(() {

                                _filterStatus =
                                    null;

                                _filterShiftFrom =
                                    null;

                                _filterShiftTo =
                                    null;
                              });

                              Navigator.pop(
                                sheetContext,
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// APPLY
                        Expanded(
                          child: CustomButton(
                            text: "Apply",

                            icon: Icons.check,

                            onTap: () {

                              /// VALIDATION
                              if (tempFrom !=
                                      null &&
                                  tempTo !=
                                      null &&
                                  tempTo!
                                      .isBefore(
                                    tempFrom!,
                                  )) {
                                return;
                              }

                              setState(() {

                                _filterStatus =
                                    tempStatus;

                                _filterShiftFrom =
                                    tempFrom;

                                _filterShiftTo =
                                    tempTo;
                              });

                              Navigator.pop(
                                sheetContext,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

  // =====================================================
  // UPDATE BOTTOM SHEET
  // =====================================================

  void _openUpdateSheet(PaymentTrackModel payment) {
    final screenContext = context;

    final cashController =
        TextEditingController(text: payment.cashPayment.toString());
    final niController =
        TextEditingController(text: payment.niPayment.toString());
    final expenseController =
        TextEditingController(text: payment.expense.toString());
    String selectedStatus = payment.paymentStatus;

    showModalBottomSheet(
      context: screenContext,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Text(
                      "Update Payment",
                      style: AppTextStyles.label.copyWith(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (payment.user != null)
                      _EmployeeChip(payment: payment),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: cashController,
                            label: "Cash (\$)",
                            hint: "0.00",
                            icon: Icons.payments_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: niController,
                            label: "NI (\$)",
                            hint: "0.00",
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: expenseController,
                      label: "Expense (\$)",
                      hint: "0.00",
                      icon: Icons.receipt_long,
                    ),
                    const SizedBox(height: 14),
                    _StatusPickerTile(
                      current: selectedStatus,
                      onTap: () async {
                        FocusScope.of(sheetContext).unfocus();
                        final picked = await _showStatusPicker(
                          screenContext,
                          current: selectedStatus,
                        );
                        if (picked != null) {
                          setSheetState(() => selectedStatus = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomOutlinedButton(
                            text: "Cancel",
                            onTap: () => Navigator.of(sheetContext).pop(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: "Update",
                            icon: Icons.check,
                            onTap: () {
                              final updated = payment.copyWith(
                                cashPayment: double.tryParse(
                                        cashController.text.trim()) ??
                                    payment.cashPayment,
                                niPayment: double.tryParse(
                                        niController.text.trim()) ??
                                    payment.niPayment,
                                expense: double.tryParse(
                                        expenseController.text.trim()) ??
                                    payment.expense,
                                paymentStatus: selectedStatus,
                              );
                              screenContext
                                  .read<PaymentBloc>()
                                  .add(UpsertPayment(updated));
                              Navigator.of(sheetContext).pop();
                            },
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
      },
    );
  }

  // =====================================================
  // STATUS PICKER SHEET
  // =====================================================

  Future<String?> _showStatusPicker(
    BuildContext ctx, {
    required String current,
  }) {
    return showModalBottomSheet<String>(
      context: ctx,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (pickerContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Text(
                "Select Payment Status",
                style: AppTextStyles.label
                    .copyWith(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 16),
              _StatusOption(
                label: "Pending",
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFF59E0B),
                isSelected: current == 'pending',
                onTap: () => Navigator.of(pickerContext).pop('pending'),
              ),
              const SizedBox(height: 8),
              _StatusOption(
                label: "Paid",
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF22C55E),
                isSelected: current == 'paid',
                onTap: () => Navigator.of(pickerContext).pop('paid'),
              ),
             
            ],
          ),
        );
      },
    );
  }
}

// =========================================================
// SECTION LABEL
// =========================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// =========================================================
// STATUS FILTER CHIP (inside filter sheet)
// =========================================================

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? color : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// =========================================================
// ACTIVE FILTER CHIP (top of list)
// =========================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// EMPLOYEE CHIP
// =========================================================

class _EmployeeChip extends StatelessWidget {
  final PaymentTrackModel payment;
  const _EmployeeChip({required this.payment});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(payment.user!.fullName),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.user!.fullName,
                style: AppTextStyles.label
                    .copyWith(fontSize: 14, color: Colors.black),
              ),
              Text(
                payment.user!.empId,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================
// STATUS PICKER TILE
// =========================================================

class _StatusPickerTile extends StatelessWidget {
  final String current;
  final VoidCallback onTap;

  const _StatusPickerTile({required this.current, required this.onTap});

  Color get _color {
    switch (current.toLowerCase()) {
      case 'paid':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String get _label {
    if (current.isEmpty) return 'Pending';
    return current[0].toUpperCase() + current.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 0.2),
        ),
        child: Row(
          children: [
            Icon(Icons.flag_outlined, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 10),
            const Text(
              "Payment Status",
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _color,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// STATUS OPTION ROW
// =========================================================

class _StatusOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? color.withOpacity(0.4) : Colors.grey.shade100,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.black,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// STRING EXTENSION
// =========================================================

extension StringExt on String {
  String capitalize() =>
      isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
}